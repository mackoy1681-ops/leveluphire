import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _webCtrl = TextEditingController();
  bool _loading = false;
  bool _populated = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _bioCtrl.dispose();
    _locCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  void _populate(UserModel profile) {
    // Only lock the population once we have actual data to show
    if (_populated) return;
    if (profile.displayName.isEmpty && profile.username.isEmpty) return;

    _nameCtrl.text = profile.displayName;
    _userCtrl.text = profile.username;
    _bioCtrl.text = profile.bio;
    _locCtrl.text = profile.location;
    _webCtrl.text = profile.website;
    _populated = true;
  }

  Future<void> _pickAvatar(UserModel current) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, imageQuality: 80);
    if (file == null) return;
    setState(() => _loading = true);
    try {
      final bytes = await file.readAsBytes();
      final userId = current.id;
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
      final updated = current.copyWith(avatarUrl: url);
      await ref.read(userProfileProvider.notifier).updateProfile(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(UserModel current) async {
    final name = _nameCtrl.text.trim();
    var username = _userCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name cannot be empty')),
      );
      return;
    }

    if (username.isEmpty) {
      username = UserModel.suggestUsername(name);
    }

    setState(() => _loading = true);
    try {
      final updated = current.copyWith(
        displayName: name,
        username: username,
        bio: _bioCtrl.text.trim(),
        location: _locCtrl.text.trim(),
        website: _webCtrl.text.trim(),
        isProfileComplete: true,
      );
      await ref.read(userProfileProvider.notifier).updateProfile(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved!'),
          backgroundColor: kSuccess,
        ),
      );
      Navigator.pop(context); // Go back to the wrapper, which shows profile tab
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        title: const Text('Edit Profile', style: TextStyle(color: kPrimaryText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          profileAsync.whenOrNull(
            data: (profile) => TextButton(
              onPressed:
                  _loading ? null : () => _save(profile ?? UserModel.empty(AuthService.currentUser!.id)),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: kAccentBlue, strokeWidth: 2),
                    )
                  : const Text('Save',
                      style: TextStyle(
                          color: kAccentBlue, fontWeight: FontWeight.bold)),
            ),
          ) ?? const SizedBox.shrink(),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: kAccentBlue)),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: const TextStyle(color: kError))),
        data: (profile) {
          final p = profile ?? UserModel.empty(AuthService.currentUser?.id ?? '');
          _populate(p);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(kPadL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar ──────────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => _pickAvatar(p),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: kSurface,
                          backgroundImage: p.avatarUrl.isNotEmpty
                              ? CachedNetworkImageProvider(p.avatarUrl)
                              : null,
                          child: p.avatarUrl.isEmpty
                              ? const Icon(Icons.person,
                                  color: kSecondaryText, size: 44)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
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
                ),
                const SizedBox(height: 28),

                // ── Stats Row ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: kPadM),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stat(p.assessmentsTaken.toString(), 'Assessments'),
                      _divider(),
                      _stat(p.interviewsCompleted.toString(), 'Interviews'),
                      _divider(),
                      _stat(p.resumesCreated.toString(), 'Resumes'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Fields ──────────────────────────────────────────────
                _label('Display Name'),
                _field(_nameCtrl, 'Your display name', Icons.badge_outlined),
                const SizedBox(height: 16),
                _label('Username'),
                _field(_userCtrl, '@username', Icons.alternate_email),
                const SizedBox(height: 16),
                _label('Bio'),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: kPrimaryText),
                  decoration: InputDecoration(
                    hintText: 'Tell us about yourself...',
                    hintStyle: const TextStyle(color: kSecondaryText),
                    filled: true,
                    fillColor: kSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kRadiusInput),
                      borderSide: const BorderSide(color: kBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kRadiusInput),
                      borderSide: const BorderSide(color: kBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kRadiusInput),
                      borderSide:
                          const BorderSide(color: kAccentBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _label('Location'),
                _field(_locCtrl, 'City, Country', Icons.location_on_outlined),
                const SizedBox(height: 16),
                _label('Website'),
                _field(_webCtrl, 'https://yoursite.com', Icons.link),
                const SizedBox(height: 32),

                // ── Save Button ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _save(p),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save Profile'),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Sign Out ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kError),
                      foregroundColor: kError,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    onPressed: () async {
                      await AuthService.signOut();
                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, kRouteLogin);
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: kSecondaryText,
                fontSize: kFontSmall,
                fontWeight: FontWeight.w500)),
      );

  Widget _field(
          TextEditingController ctrl, String hint, IconData icon) =>
      TextFormField(
        controller: ctrl,
        style: const TextStyle(color: kPrimaryText),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: kSecondaryText),
        ),
      );

  Widget _stat(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: kPrimaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  const TextStyle(color: kSecondaryText, fontSize: kFontTiny)),
        ],
      );

  Widget _divider() => Container(
      width: 1, height: 36, color: kBorderColor);
}
