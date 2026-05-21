import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/resume_model.dart';
import '../services/pdf_service.dart';
import '../utils/constants.dart';
import '../widgets/resume_templates/templates/templates.dart';

class PrintPreviewScreen extends StatefulWidget {
  final ResumeModel resume;
  final String selectedTemplateId;

  const PrintPreviewScreen({
    super.key,
    required this.resume,
    required this.selectedTemplateId,
  });

  @override
  State<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends State<PrintPreviewScreen> {
  bool _isExporting = false;

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final bytes = await PdfService.generateResumePdf(widget.resume);
      await PdfService.sharePdf(bytes, widget.resume.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF ready to share!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildResumePreview() {
    switch (widget.selectedTemplateId) {
      case 'template_1': return ResumeTemplate1(resume: widget.resume);
      case 'template_2': return ResumeTemplate2(resume: widget.resume);
      case 'template_3': return ResumeTemplate3(resume: widget.resume);
      case 'template_4': return ResumeTemplate4(resume: widget.resume);
      case 'template_5': return ResumeTemplate5(resume: widget.resume);
      case 'template_6': return ResumeTemplate6(resume: widget.resume);
      case 'template_7': return ResumeTemplate7(resume: widget.resume);
      case 'template_8': return ResumeTemplate8(resume: widget.resume);
      case 'template_9': return ResumeTemplate9(resume: widget.resume);
      default: return ResumeTemplate1(resume: widget.resume);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Print Preview', style: TextStyle(color: kPrimaryText)),
        backgroundColor: kBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Editor',
        ),
        actions: [
          // Export PDF button (text button)
          TextButton.icon(
            onPressed: _isExporting ? null : _exportPdf,
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf, color: kAccentBlue),
            label: const Text('Export PDF', style: TextStyle(color: kAccentBlue)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Info banner (simplified, no page counter)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: kAccentBlue.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: kAccentBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Actual A4 size • Pinch to zoom • Drag to pan',
                      style: TextStyle(fontSize: 12, color: kAccentBlue),
                    ),
                  ],
                ),
              ),
              // Interactive preview
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 2.5,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: Center(
                    child: Container(
                      width: 595,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildResumePreview(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Zoom hint at bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pinch, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Pinch to zoom • Drag to pan',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}