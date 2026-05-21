import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  String? _avatarUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingProfile());
  }

  Future<void> _loadExistingProfile() async {
    try {
      final profile = await ref.read(userProfileProvider.future);
      if (!mounted || profile == null) return;
      if (profile.displayName.isNotEmpty) {
        _nameCtrl.text = profile.displayName;
      }
      if (profile.avatarUrl.isNotEmpty) {
        setState(() => _avatarUrl = profile.avatarUrl);
      }
    } catch (_) {
      // Ignore — user may be completing setup for the first time.
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, imageQuality: 80);
    if (file == null) return;
    setState(() => _loading = true);
    try {
      final bytes = await file.readAsBytes();
      final userId = AuthService.currentUser!.id;
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';
      
      await Supabase.instance.client.storage
          .from('resume_photos')
          .uploadBinary(path, bytes,
              fileOptions: const FileOptions(
                upsert: false,
                contentType: 'image/jpeg',
              ));
      final url = Supabase.instance.client.storage
          .from('resume_photos')
          .getPublicUrl(path);
      setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avatar upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your display name')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = AuthService.currentUser!;
      final name = _nameCtrl.text.trim();
      final username = UserModel.suggestUsername(name);

      final profile = UserModel(
        id: user.id,
        displayName: name,
        username: username,
        avatarUrl: _avatarUrl ?? '',
        isProfileComplete: true,
      );
      await ref.read(userProfileProvider.notifier).updateProfile(profile);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, kRouteHome);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kPadXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const Text(
                'Set up your profile',
                style: TextStyle(
                    color: kPrimaryText,
                    fontSize: kFontHeading,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us a bit about yourself to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kSecondaryText, fontSize: kFontBase),
              ),
              const SizedBox(height: 36),

              // Avatar picker
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: kSurface,
                      backgroundImage: _avatarUrl != null 
                          ? CachedNetworkImageProvider(_avatarUrl!) as ImageProvider
                          : null,
                      child: _avatarUrl == null
                          ? const Icon(Icons.person,
                              color: kSecondaryText, size: 48)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: kAccentBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap to add photo',
                  style:
                      TextStyle(color: kSecondaryText, fontSize: kFontSmall)),
              const SizedBox(height: 32),

              // Display name
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: kPrimaryText),
                decoration: const InputDecoration(
                  labelText: 'Display Name *',
                  prefixIcon:
                      Icon(Icons.badge_outlined, color: kSecondaryText),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
