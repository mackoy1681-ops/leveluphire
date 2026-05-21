import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resume_model.dart';
import '../providers/resume_provider.dart';
import '../services/pdf_service.dart';
import '../utils/constants.dart';
import '../widgets/resume_templates/templates/templates.dart';

class ResumeViewScreen extends ConsumerStatefulWidget {
  final ResumeModel resume;
  final bool isFromMyResumes;

  const ResumeViewScreen({
    super.key,
    required this.resume,
    this.isFromMyResumes = false,
  });

  @override
  ConsumerState<ResumeViewScreen> createState() => _ResumeViewScreenState();
}

class _ResumeViewScreenState extends ConsumerState<ResumeViewScreen> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final bytes = await PdfService.generateResumePdf(widget.resume);
      await PdfService.sharePdf(bytes, widget.resume.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kBackground,
        title: Text(widget.resume.title, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: kPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.isFromMyResumes)
            TextButton.icon(
              onPressed: () {
                ref.read(currentResumeProvider.notifier).state = widget.resume;
                Navigator.pushReplacementNamed(context, kRouteResumeEditor);
              },
              icon: const Icon(Icons.edit_outlined, size: 18, color: kAccentBlue),
              label: const Text('Edit', style: TextStyle(color: kAccentBlue)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kPadL),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _buildTemplate(),
                ),
              ),
            ),
          ),
          
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(kPadL),
            decoration: BoxDecoration(
              color: kBackground,
              border: const Border(top: BorderSide(color: kBorderColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exporting ? null : _exportPdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _exporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf),
                      label: const Text('Export as PDF',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplate() {
    switch (widget.resume.templateId) {
      case 'template_1': return ResumeTemplate1(resume: widget.resume);
      case 'template_2': return ResumeTemplate2(resume: widget.resume);
      case 'template_3': return ResumeTemplate3(resume: widget.resume);
      case 'template_4': return ResumeTemplate4(resume: widget.resume);
      case 'template_5': return ResumeTemplate5(resume: widget.resume);
      case 'template_6': return ResumeTemplate6(resume: widget.resume);
      case 'template_7': return ResumeTemplate7(resume: widget.resume);
      case 'template_8': return ResumeTemplate8(resume: widget.resume);
      case 'template_9': return ResumeTemplate9(resume: widget.resume);
      case 'template_10': return ResumeTemplate10(resume: widget.resume);
      case 'template_11': return ResumeTemplate11(resume: widget.resume);
      default: return Container(
        width: 595,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file_outlined, size: 64, color: kSecondaryText),
              const SizedBox(height: 16),
              Text(
                'Template not found',
                style: TextStyle(
                  fontSize: kFontBase,
                  color: kSecondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add templates to view resumes',
                style: TextStyle(
                  fontSize: kFontSmall,
                  color: kSecondaryText,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
