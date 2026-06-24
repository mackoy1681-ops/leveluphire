import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resume_provider.dart';
import '../providers/tab_provider.dart';
import '../models/resume_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';
import 'resume_view_screen.dart';

class ResumeScreen extends ConsumerWidget {
  const ResumeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsync = ref.watch(resumeListProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('My Resumes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Home',
          onPressed: () {
            // If this screen was pushed as a route (web/mobile), pop it.
            // Otherwise fall back to switching the main tab.
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            } else {
              ref.read(mainTabIndexProvider.notifier).state = 0;
            }
          },
        ),
      ),
      body: Stack(
        children: [
          resumesAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: kAccentBlue)),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: kError))),
            data: (resumes) => resumes.isEmpty
                ? _EmptyState(onCreateTap: () => _openEditor(context, ref, null))
                : ListView.separated(
                    padding: const EdgeInsets.only(
                        top: 12, bottom: 100, left: 16, right: 16),
                    itemCount: resumes.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ResumeCard(
                      resume: resumes[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResumeViewScreen(
                            resume: resumes[i],
                            isFromMyResumes: true,
                          ),
                        ),
                      ),
                      onDelete: () => _confirmDelete(context, ref, resumes[i].id),
                    ),
                  ),
          ),

          Positioned(
            right: 20,
            bottom: 110, // raised above floating bottom nav
            child: FloatingActionButton.extended(
              backgroundColor: kAccentBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Resume',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _openEditor(context, ref, null),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext ctx, WidgetRef ref, ResumeModel? resume) {
    final userId = AuthService.currentUser?.id ?? '';
    ref.read(currentResumeProvider.notifier).state =
        resume ?? ResumeModel.empty(userId);
    Navigator.pushNamed(ctx, kRouteResumeEditor);
  }

  Future<void> _confirmDelete(
      BuildContext ctx, WidgetRef ref, String id) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Delete Resume?',
            style: TextStyle(color: kPrimaryText)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: kSecondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: kError)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(resumeListProvider.notifier).delete(id);
    }
  }
}

class _ResumeCard extends StatelessWidget {
  final ResumeModel resume;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ResumeCard(
      {required this.resume, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final updated = resume.updatedAt != null
        ? DateFormat('MMM d, yyyy').format(resume.updatedAt!)
        : '';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(kPadL),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(color: kBorderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kAccentBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_rounded,
                  color: kAccentBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resume.title,
                      style: const TextStyle(
                          color: kPrimaryText,
                          fontSize: kFontBase,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(
                    '${_templateLabel(resume.templateId)}  ·  $updated',
                    style: const TextStyle(
                        color: kSecondaryText, fontSize: kFontSmall),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: kError, size: 20),
              onPressed: onDelete,
            ),
            const Icon(Icons.chevron_right, color: kSecondaryText),
          ],
        ),
      ),
    );
  }

  String _templateLabel(String id) {
    const map = {
      'template_1': 'Classic',
    };
    return map[id] ?? 'Classic';
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_outlined,
              color: kSecondaryText, size: 64),
          const SizedBox(height: 16),
          const Text('No resumes yet',
              style: TextStyle(
                  color: kPrimaryText,
                  fontSize: kFontTitle,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Create your first resume to get started.',
              style: TextStyle(color: kSecondaryText)),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Resume'),
              onPressed: onCreateTap,
            ),
          ),
        ],
      ),
    );
  }
}
