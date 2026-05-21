// lib/screens/likes_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../providers/tab_provider.dart';

class LikesPopup extends StatefulWidget {
  final String targetId;
  final String targetType;

  const LikesPopup({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  @override
  State<LikesPopup> createState() => _LikesPopupState();
}

class _LikesPopupState extends State<LikesPopup> {
  List<Map<String, dynamic>> _likes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('discussion_likes')
          .select('''
            user_id,
            profiles:user_id(display_name, avatar_url, username)
          ''')
          .eq('target_id', widget.targetId)
          .eq('target_type', widget.targetType)
          .order('created_at', ascending: false);

      setState(() {
        _likes = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading likes: $e');
      setState(() => _isLoading = false);
    }
  }

  void _goToProfile(String userId) {
    Navigator.pop(context); // Close the popup
    // Navigate to profile page
    // You can implement this based on your app's navigation
    // For now, we'll just switch to profile tab
    // If you have a user profile screen, push it here
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Liked by (${_likes.length})',
                      style: const TextStyle(
                        color: kPrimaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: kSecondaryText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: kBorderColor, height: 1),
              
              // List of likes
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: kAccentBlue),
                      )
                    : _likes.isEmpty
                        ? const Center(
                            child: Text(
                              'No likes yet',
                              style: TextStyle(color: kSecondaryText),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _likes.length,
                            itemBuilder: (context, index) {
                              final like = _likes[index];
                              final userId = like['user_id'];
                              final profile = like['profiles'];
                              
                              final displayName = profile != null
                                  ? (profile['display_name'] as String?)?.isNotEmpty == true
                                      ? profile['display_name']
                                      : (profile['username'] as String?) ?? 'User'
                                  : 'User';
                              
                              final avatarUrl = profile != null
                                  ? profile['avatar_url'] as String?
                                  : null;
                              
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: kBorderColor,
                                  backgroundImage: avatarUrl != null
                                      ? CachedNetworkImageProvider(avatarUrl)
                                      : null,
                                  child: avatarUrl == null
                                      ? const Icon(Icons.person, color: kSecondaryText)
                                      : null,
                                ),
                                title: Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: kPrimaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: kSecondaryText,
                                ),
                                onTap: () => _goToProfile(userId),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}