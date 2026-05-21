import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_model.dart';
import 'pdf_download_stub.dart'
    if (dart.library.html) 'pdf_download_web.dart';

class PdfService {
  /// Generates a PDF from [resume] using the selected template.
  static Future<Uint8List> generateResumePdf(ResumeModel resume, {bool isPrinterFriendly = true}) async {
    // Load a Unicode-compatible font (Inter) to prevent errors with dashes and special characters
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    );

    // Fetch photo if available
    pw.ImageProvider? profileImage;
    final photoUrl = resume.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      try {
        profileImage = await networkImage(photoUrl);
      } catch (e) {
        print('Failed to load profile image for PDF: $e');
      }
    }

    switch (resume.templateId) {
      case 'template_1':
        return _buildTemplate1(resume, isPrinterFriendly, theme, profileImage);
      case 'template_2':
        return _buildTemplate2(resume, isPrinterFriendly, theme, profileImage);
      case 'template_3':
        return _buildTemplate3(resume, isPrinterFriendly, theme, profileImage);
      case 'template_4':
        return _buildTemplate4(resume, isPrinterFriendly, theme, profileImage);
      case 'template_5':
        return _buildTemplate5(resume, isPrinterFriendly, theme, profileImage);
      case 'template_6':
        return _buildTemplate6(resume, isPrinterFriendly, theme, profileImage);
      case 'template_7':
        return _buildTemplate7(resume, isPrinterFriendly, theme, profileImage);
      case 'template_8':
        return _buildTemplate8(resume, isPrinterFriendly, theme, profileImage);
      case 'template_9':
        return _buildTemplate9(resume, isPrinterFriendly, theme, profileImage);
      case 'template_11':
        return _buildTemplate11(resume, isPrinterFriendly, theme, profileImage);
      default:
        return _buildTemplate1(resume, isPrinterFriendly, theme, profileImage);
    }
  }

  // ─── Template 8: Corporate Sidebar (Two Column Blue) ───────────────────────

  static Future<Uint8List> _buildTemplate8(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.FullPage(
          ignoreMargins: true,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Left Sidebar
              pw.Container(
                width: 170,
                color: const PdfColor.fromInt(0xFF1A3A5C),
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (image != null) 
                      pw.Center(child: _buildCircularImage(image, 100)),
                    pw.SizedBox(height: 24),
                    pw.Text('CONTACT', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 1)),
                    pw.SizedBox(height: 8),
                    if (r.email.isNotEmpty) _sidebarInfo(r.email),
                    if (r.phone.isNotEmpty) _sidebarInfo(r.phone),
                    if (r.location.isNotEmpty) _sidebarInfo(r.location),
                    pw.SizedBox(height: 20),
                    
                    if (r.skills.isNotEmpty) ...[
                      pw.Text('SKILLS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 1)),
                      pw.SizedBox(height: 8),
                      ...r.skills.map((s) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 4), child: pw.Text('• $s', style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)))),
                    ],

                    if (r.languages.isNotEmpty) ...[
                      pw.SizedBox(height: 20),
                      pw.Text('LANGUAGES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 1)),
                      pw.SizedBox(height: 8),
                      ...r.languages.map((l) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 4), child: pw.Text('${l.name} (${l.proficiency})', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white)))),
                    ],
                  ],
                ),
              ),
              // Main Body
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(24),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(r.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1A3A5C))),
                      pw.SizedBox(height: 8),
                      if (r.summary.isNotEmpty)
                        pw.Text(r.summary, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 20),

                      ...r.sectionOrder.map((sectionId) {
                        switch (sectionId) {
                          case 'work':
                            if (r.workExperience.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _mainTitle('WORK EXPERIENCE'),
                              ...r.workExperience.map((job) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 14),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(job.role, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(job.company, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                    pw.Text('${job.startDate} - ${job.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                                    pw.SizedBox(height: 4),
                                    pw.Text(job.description, style: const pw.TextStyle(fontSize: 9)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'education':
                            if (r.education.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _mainTitle('EDUCATION'),
                              ...r.education.map((edu) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 10),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(edu.degree, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(edu.institution, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'certifications':
                            if (r.certifications.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _mainTitle('CERTIFICATIONS'),
                              ...r.certifications.map((c) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 10),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(c.name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(c.issuer, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'licenses':
                            if (r.licenses.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _mainTitle('LICENSES'),
                              ...r.licenses.map((l) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 10),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(l.licenseName, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(l.issuingAuthority, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                    pw.Text('License No: ${l.licenseNumber} • Issued: ${l.issueDate} • Expires: ${l.expiryDate}', 
                                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'awards':
                            if (r.awards.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _mainTitle('AWARDS'),
                              ...r.awards.map((a) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 10),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(a.title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(a.organization, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          default:
                            return pw.SizedBox.shrink();
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
    return doc.save();
  }

  static pw.Widget _sidebarInfo(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white)),
  );

  static pw.Widget _mainTitle(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8, top: 8),
    child: pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1A3A5C), letterSpacing: 1)),
  );


  // ─── Template 7: Minimalist Sans (Helvetica Style) ─────────────────────────

  static Future<Uint8List> _buildTemplate7(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(45),
      build: (ctx) => [
        // Header
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (image != null) 
              _buildCircularImage(image, 60),
            if (image != null) pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(r.name, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.normal, letterSpacing: -0.5)),
                  pw.SizedBox(height: 8),
                  if (r.summary.isNotEmpty)
                    pw.Text(r.summary, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.Divider(thickness: 0.5, color: PdfColors.grey300),
        pw.SizedBox(height: 16),

        ...r.sectionOrder.map((sectionId) {
          switch (sectionId) {
            case 'work':
              if (r.workExperience.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _template7Label('Experience'),
                ...r.workExperience.map((job) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(job.role, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${job.startDate} - ${job.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                        ],
                      ),
                      pw.Text(job.company, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 6),
                      pw.Text(job.description, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ),
                )),
              ]);
            case 'education':
              if (r.education.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.SizedBox(height: 8),
                _template7Label('Education'),
                ...r.education.map((edu) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(edu.degree, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${edu.startDate} - ${edu.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                        ],
                      ),
                      pw.Text(edu.institution, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                )),
              ]);
            case 'certifications':
              if (r.certifications.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.SizedBox(height: 8),
                _template7Label('Certifications'),
                ...r.certifications.map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(c.name, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(c.issuer, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                )),
              ]);
            case 'licenses':
              if (r.licenses.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.SizedBox(height: 8),
                _template7Label('Licenses'),
                ...r.licenses.map((l) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(l.licenseName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(l.issuingAuthority, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text('No: ${l.licenseNumber} | ${l.issueDate} - ${l.expiryDate}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                    ],
                  ),
                )),
              ]);
            case 'awards':
              if (r.awards.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.SizedBox(height: 8),
                _template7Label('Awards'),
                ...r.awards.map((a) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(a.title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(a.organization, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                )),
              ]);
            case 'languages':
              if (r.languages.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.SizedBox(height: 8),
                _template7Label('Languages'),
                pw.Text(r.languages.map((l) => '${l.name} (${l.proficiency})').join('  ·  '), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
              ]);
            case 'skills':
              if (r.skills.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.SizedBox(height: 8),
                _template7Label('Skills'),
                pw.Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: r.skills.map((skill) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    color: PdfColors.grey100,
                    child: pw.Text(skill, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900)),
                  )).toList(),
                ),
              ]);
            default:
              return pw.SizedBox.shrink();
          }
        }),
      ],
    ));
    return doc.save();
  }

  static pw.Widget _template7Label(String label) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 12),
    child: pw.Text(label, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: PdfColors.grey500)),
  );


  // ─── Template 6: Professional Classic (Times New Roman Style) ──────────────

  static Future<Uint8List> _buildTemplate6(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => [
        // Header
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (image != null) 
              _buildCircularImage(image, 70),
            if (image != null) pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(r.name.toUpperCase(), 
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                  pw.SizedBox(height: 6),
                  pw.Text([r.email, r.phone, r.location].where((s) => s.isNotEmpty).join('  •  '),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 16),

        if (r.summary.isNotEmpty) ...[
          _template6Title('Professional Summary'),
          pw.Text(r.summary, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 12),
        ],

        ...r.sectionOrder.map((sectionId) {
          switch (sectionId) {
            case 'work':
              if (r.workExperience.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _template6Title('WORK EXPERIENCE'),
                ...r.workExperience.map((job) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(job.role, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(job.company, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                      pw.Text('${job.startDate} - ${job.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      pw.SizedBox(height: 4),
                      pw.Text(job.description, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                )),
              ]);
            case 'education':
              if (r.education.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _template6Title('EDUCATION'),
                ...r.education.map((edu) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(edu.degree, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(edu.institution, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                      pw.Text('${edu.startDate} - ${edu.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                )),
              ]);
            case 'certifications':
              if (r.certifications.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _template6Title('CERTIFICATIONS'),
                ...r.certifications.map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(c.name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text('${c.issuer} | ${c.dateIssued ?? ""}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ),
                )),
              ]);
            case 'licenses':
              if (r.licenses.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _template6Title('LICENSES'),
                ...r.licenses.map((l) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(l.licenseName, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text(l.issuingAuthority, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                      pw.Text('License No: ${l.licenseNumber}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      pw.Text('Issued: ${l.issueDate} | Expires: ${l.expiryDate}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                    ],
                  ),
                )),
              ]);
            case 'awards':
              if (r.awards.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _template6Title('AWARDS'),
                ...r.awards.map((a) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(a.title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text('${a.organization} | ${a.year ?? ""}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ),
                )),
              ]);
            case 'languages':
              if (r.languages.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _template6Title('LANGUAGES'),
                pw.Text(r.languages.map((l) => '${l.name} (${l.proficiency})').join('  ·  '), style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 12),
              ]);
            case 'skills':
              if (r.skills.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _template6Title('SKILLS'),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: r.skills.map((skill) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                    ),
                    child: pw.Text(skill, style: const pw.TextStyle(fontSize: 9)),
                  )).toList(),
                ),
              ]);
            default:
              return pw.SizedBox.shrink();
          }
        }),
      ],
    ));
    return doc.save();
  }

  static pw.Widget _template6Title(String title) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
      pw.SizedBox(height: 8),
    ],
  );


  /// Downloads the PDF on web, or opens the share sheet on mobile.
  static Future<void> sharePdf(Uint8List bytes, String userFullName) async {
    final year = DateTime.now().year;
    final safeName = userFullName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final fileName = '${safeName}_Resume_$year.pdf';

    if (kIsWeb) {
      await triggerWebDownload(bytes, fileName);
    } else {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    }
  }

  // ─── Shared Section Builders for order ──────────────────────────────────

  static List<pw.Widget> _buildOrderedSections(ResumeModel r) {
    List<pw.Widget> sections = [];
    for (final sectionId in r.sectionOrder) {
      switch (sectionId) {
        case 'work':
          if (r.workExperience.isNotEmpty) {
            sections.add(_sectionTitle('Work Experience'));
            sections.addAll(r.workExperience.map(_workEntry));
          }
          break;
        case 'education':
          if (r.education.isNotEmpty) {
            sections.add(_sectionTitle('Education'));
            sections.addAll(r.education.map(_eduEntry));
          }
          break;
        case 'certifications':
          if (r.certifications.isNotEmpty) {
            sections.add(_sectionTitle('Certifications'));
            sections.addAll(r.certifications.map(_certEntry));
          }
          break;
        case 'licenses':
          if (r.licenses.isNotEmpty) {
            sections.add(_sectionTitle('Licenses'));
            sections.addAll(r.licenses.map(_licenseEntry));
          }
          break;
        case 'awards':
          if (r.awards.isNotEmpty) {
            sections.add(_sectionTitle('Awards'));
            sections.addAll(r.awards.map(_awardEntry));
          }
          break;
        case 'languages':
          if (r.languages.isNotEmpty) {
            sections.add(_sectionTitle('Languages'));
            sections.add(pw.Wrap(
              spacing: 12,
              children: r.languages.map((l) => pw.Text('${l.name} (${l.proficiency})', style: const pw.TextStyle(fontSize: 10))).toList(),
            ));
            sections.add(pw.SizedBox(height: 10));
          }
          break;
        case 'skills':
          if (r.skills.isNotEmpty) {
            sections.add(_sectionTitle('Skills'));
            sections.add(pw.Text(r.skills.join('  ·  '), style: const pw.TextStyle(fontSize: 10)));
            sections.add(pw.SizedBox(height: 10));
          }
          break;
      }
    }
    return sections;
  }

  // ─── Template 1: Classic Single Column ───────────────────────────────────

  static Future<Uint8List> _buildTemplate1(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        // Header
        pw.Container(
          width: double.infinity,
          color: const PdfColor.fromInt(0xFF1A1A2E),
          padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Photo
              pw.Container(
                width: 80,
                height: 80,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.white, width: 2.5),
                  color: const PdfColor.fromInt(0xFF2D2D44),
                ),
                child: image != null
                    ? pw.ClipOval(
                        child: pw.Image(image, fit: pw.BoxFit.cover, width: 80, height: 80),
                      )
                    : null,
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (r.name.isNotEmpty)
                      pw.Text(
                        r.name,
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    if (r.summary.isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      pw.Text(
                        r.summary,
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColor.fromInt(0xFFBBBBCC),
                          lineSpacing: 1.5,
                        ),
                        maxLines: 3,
                      ),
                    ],
                    pw.SizedBox(height: 10),
                    // Contact row
                    pw.Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (r.email.isNotEmpty) _contactItem1(r.email),
                        if (r.phone.isNotEmpty) _contactItem1(r.phone),
                        if (r.location.isNotEmpty) _contactItem1(r.location),
                        if (r.website.isNotEmpty) _contactItem1(r.website),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Body
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (r.workExperience.isNotEmpty) ...[
                _sectionTitle1('Work Experience'),
                ...r.workExperience.map((job) => _workItem1(job)),
                pw.SizedBox(height: 8),
              ],
              if (r.education.isNotEmpty) ...[
                _sectionTitle1('Education'),
                ...r.education.map((edu) => _eduItem1(edu)),
                pw.SizedBox(height: 8),
              ],
              if (r.licenses.isNotEmpty) ...[
                _sectionTitle1('Professional Licenses'),
                ...r.licenses.map((lic) => _licenseItem1(lic)),
                pw.SizedBox(height: 8),
              ],
              if (r.certifications.isNotEmpty) ...[
                _sectionTitle1('Certifications'),
                ...r.certifications.map((cert) => _certItem1(cert)),
                pw.SizedBox(height: 8),
              ],
              if (r.awards.isNotEmpty) ...[
                _sectionTitle1('Awards & Achievements'),
                ...r.awards.map((award) => _awardItem1(award)),
                pw.SizedBox(height: 8),
              ],
              if (r.skills.isNotEmpty) ...[
                _sectionTitle1('Skills'),
                pw.SizedBox(height: 8),
                pw.Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: r.skills
                      .map((s) => pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: const PdfColor.fromInt(0xFFF0F0F5),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              border: pw.Border.all(color: const PdfColor.fromInt(0xFFDDDDEE)),
                            ),
                            child: pw.Text(s,
                                style: const pw.TextStyle(
                                    fontSize: 10, color: PdfColor.fromInt(0xFF333355))),
                          ))
                      .toList(),
                ),
                pw.SizedBox(height: 16),
              ],
              if (r.languages.isNotEmpty) ...[
                _sectionTitle1('Languages'),
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: r.languages
                      .map((lang) => pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Container(
                                width: 4, height: 4,
                                decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1A1A2E), shape: pw.BoxShape.circle)
                              ),
                              pw.SizedBox(width: 5),
                              pw.Text(
                                '${lang.name}  ',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: const PdfColor.fromInt(0xFF1A1A1A)),
                              ),
                              pw.Text(
                                lang.proficiency,
                                style: const pw.TextStyle(
                                    fontSize: 10, color: PdfColor.fromInt(0xFF666666)),
                              ),
                            ],
                          ))
                      .toList(),
                ),
                pw.SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    ));
    return doc.save();
  }

  static pw.Widget _sectionTitle1(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: const PdfColor.fromInt(0xFF1A1A2E),
            letterSpacing: 1.2,
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 12),
          height: 1.5,
          color: const PdfColor.fromInt(0xFF1A1A2E),
        ),
      ],
    );
  }

  static pw.Widget _contactItem1(String text) {
    return pw.Text(text, style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFFCCCCDD)));
  }

  static pw.Widget _workItem1(WorkExperience job) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  job.role,
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF1A1A1A)),
                ),
              ),
              if (job.startDate.isNotEmpty || job.endDate.isNotEmpty)
                pw.Text(
                  '${job.startDate}${job.endDate.isNotEmpty ? ' – ${job.endDate}' : ''}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF888888)),
                ),
            ],
          ),
          if (job.company.isNotEmpty)
            pw.Text(job.company,
                style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor.fromInt(0xFF555566),
                    )),
          if (job.description.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(job.description,
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColor.fromInt(0xFF444444), lineSpacing: 1.5)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _eduItem1(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  edu.degree,
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF1A1A1A)),
                ),
              ),
              if (edu.startDate.isNotEmpty || edu.endDate.isNotEmpty)
                pw.Text(
                  '${edu.startDate}${edu.endDate.isNotEmpty ? ' – ${edu.endDate}' : ''}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF888888)),
                ),
            ],
          ),
          if (edu.institution.isNotEmpty)
            pw.Text(edu.institution,
                style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor.fromInt(0xFF555566),
                    )),
          if (edu.field.isNotEmpty)
            pw.Text(edu.field,
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColor.fromInt(0xFF666666))),
        ],
      ),
    );
  }

  static pw.Widget _certItem1(Certification cert) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(cert.name,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF1A1A1A))),
          pw.Text(
            [
              if (cert.issuer.isNotEmpty) cert.issuer,
              if (cert.dateIssued != null && cert.dateIssued!.isNotEmpty)
                cert.dateIssued!,
            ].join(' · '),
            style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF777777)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _licenseItem1(License lic) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(lic.licenseName,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF1A1A1A))),
          pw.Text(
            [
              if (lic.issuingAuthority.isNotEmpty) lic.issuingAuthority,
              if (lic.licenseNumber.isNotEmpty) 'No. ${lic.licenseNumber}',
              if (lic.issueDate.isNotEmpty) lic.issueDate,
            ].join(' · '),
            style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF777777)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _awardItem1(Award award) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(award.title,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF1A1A1A))),
          pw.Text(
            [
              if (award.organization.isNotEmpty) award.organization,
              if (award.year != null && award.year!.isNotEmpty) award.year!,
            ].join(' · '),
            style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF777777)),
          ),
          if (award.description != null && award.description!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(award.description!,
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColor.fromInt(0xFF555555), lineSpacing: 1.4)),
          ],
        ],
      ),
    );
  }


  // ─── Template 2: Modern with Blue Header ─────────────────────────────────

  static Future<Uint8List> _buildTemplate2(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.Container(
          width: double.infinity,
          color: isPrinterFriendly ? PdfColors.white : const PdfColor.fromInt(0xFF1565C0),
          padding: const pw.EdgeInsets.all(24),
          child: pw.Row(
            children: [
              if (image != null) 
                _buildCircularImage(image, 60),
              if (image != null) pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(r.name, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: isPrinterFriendly ? PdfColors.black : PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text([r.email, r.phone, r.location].where((s) => s.isNotEmpty).join('  |  '), 
                      style: pw.TextStyle(fontSize: 10, color: isPrinterFriendly ? PdfColors.grey700 : const PdfColor.fromInt(0xFFBBDEFB))),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (r.summary.isNotEmpty) ...[
                _template2Section('About Me'),
                pw.Text(r.summary, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 12),
              ],
              
              ...r.sectionOrder.map((sectionId) {
                switch (sectionId) {
                  case 'work':
                    if (r.workExperience.isEmpty) return pw.SizedBox.shrink();
                    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      _template2Section('Experience'),
                      ...r.workExperience.map((w) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(w.role, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(w.company, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                pw.Text('${w.startDate} - ${w.endDate}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                              ],
                            ),
                            if (w.description.isNotEmpty)
                              pw.Text(w.description, style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      )),
                    ]);
                  case 'education':
                    if (r.education.isEmpty) return pw.SizedBox.shrink();
                    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      _template2Section('Education'),
                      ...r.education.map((e) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('${e.degree} in ${e.field}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.Text(e.institution, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          ],
                        ),
                      )),
                    ]);
                  case 'certifications':
                    if (r.certifications.isEmpty) return pw.SizedBox.shrink();
                    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      _template2Section('Certifications'),
                      ...r.certifications.map((c) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(c.name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.Text('${c.issuer} ${c.dateIssued != null ? "(${c.dateIssued})" : ""}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          ],
                        ),
                      )),
                    ]);
                  case 'licenses':
                    if (r.licenses.isEmpty) return pw.SizedBox.shrink();
                    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      _template2Section('Licenses'),
                      ...r.licenses.map((l) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(l.licenseName, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.Text(l.issuingAuthority, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                            pw.Text('No: ${l.licenseNumber}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                          ],
                        ),
                      )),
                    ]);
                  case 'awards':
                    if (r.awards.isEmpty) return pw.SizedBox.shrink();
                    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      _template2Section('Awards'),
                      ...r.awards.map((a) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(a.title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            pw.Text('${a.organization} ${a.year != null ? "(${a.year})" : ""}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          ],
                        ),
                      )),
                    ]);
                  case 'languages':
                    if (r.languages.isEmpty) return pw.SizedBox.shrink();
                    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      _template2Section('Languages'),
                      pw.Text(r.languages.map((l) => '${l.name} (${l.proficiency})').join('  ·  '), style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 8),
                    ]);
                  case 'skills':
                    if (r.skills.isEmpty) return pw.SizedBox.shrink();
                    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      _template2Section('Skills'),
                      pw.Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: r.skills.map((s) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE3F2FD)),
                          child: pw.Text(s, style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF1565C0))),
                        )).toList(),
                      ),
                    ]);
                  default:
                    return pw.SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      ],
    ));
    return doc.save();
  }

  static pw.Widget _template2Section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1565C0))),
        pw.Container(height: 1.5, color: const PdfColor.fromInt(0xFF1565C0)),
        pw.SizedBox(height: 4),
      ],
    ),
  );


  // ─── Template 3: Two Column Sidebar ───────────────────────────────────────

  static Future<Uint8List> _buildTemplate3(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.FullPage(
          ignoreMargins: true,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                width: 150,
                color: const PdfColor.fromInt(0xFF263238),
                padding: const pw.EdgeInsets.all(14),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (image != null) 
                      pw.Center(child: _buildCircularImage(image, 90)),
                    if (image != null) pw.SizedBox(height: 16),
                    pw.Text(r.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 10),
                    if (r.email.isNotEmpty) _sidebarLabel('EMAIL', r.email),
                    if (r.phone.isNotEmpty) _sidebarLabel('PHONE', r.phone),
                    if (r.location.isNotEmpty) _sidebarLabel('LOCATION', r.location),
                    if (r.skills.isNotEmpty) ...[
                      pw.SizedBox(height: 12),
                      pw.Text('SKILLS', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF78909C), letterSpacing: 1)),
                      pw.SizedBox(height: 4),
                      ...r.skills.map((s) => pw.Text('• $s', style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFB0BEC5)))),
                    ],
                    if (r.languages.isNotEmpty) ...[
                      pw.SizedBox(height: 12),
                      pw.Text('LANGUAGES', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF78909C), letterSpacing: 1)),
                      pw.SizedBox(height: 4),
                      ...r.languages.map((l) => pw.Text('${l.name} (${l.proficiency})', style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFFB0BEC5)))),
                    ],
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.all(14),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (r.summary.isNotEmpty) ...[
                        _template3Section('Profile'),
                        pw.Text(r.summary, style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 8),
                      ],
                      
                      ...r.sectionOrder.map((sectionId) {
                        switch (sectionId) {
                          case 'work':
                            if (r.workExperience.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template3Section('Experience'),
                              ...r.workExperience.map((w) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 7),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(w.role, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text('${w.company}  •  ${w.startDate} - ${w.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                                    if (w.description.isNotEmpty)
                                      pw.Text(w.description, style: const pw.TextStyle(fontSize: 9)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'education':
                            if (r.education.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template3Section('Education'),
                              ...r.education.map((e) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('${e.degree} in ${e.field}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(e.institution, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'certifications':
                            if (r.certifications.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template3Section('Certifications'),
                              ...r.certifications.map((c) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(c.name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text('${c.issuer} ${c.dateIssued ?? ""}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'licenses':
                            if (r.licenses.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template3Section('Licenses'),
                              ...r.licenses.map((l) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(l.licenseName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(l.issuingAuthority, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                    pw.Text('No: ${l.licenseNumber}', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'awards':
                            if (r.awards.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template3Section('Awards'),
                              ...r.awards.map((a) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(a.title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text('${a.organization} ${a.year ?? ""}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          default:
                            return pw.SizedBox.shrink();
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
    return doc.save();
  }

  // ─── Template 4: Minimalist Centered ───────────────────────────────────────

  static Future<Uint8List> _buildTemplate4(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      build: (ctx) => [
        pw.Center(
          child: pw.Column(children: [
            if (image != null) ...[
              _buildCircularImage(image, 80),
              pw.SizedBox(height: 16),
            ],
            pw.Text(r.name.toUpperCase(), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, letterSpacing: 4)),
            pw.SizedBox(height: 4),
            pw.Text([r.email, r.phone, r.location].where((s) => s.isNotEmpty).join('  ·  '), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ]),
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 2, color: PdfColors.black),
        pw.SizedBox(height: 4),
        pw.Container(height: 0.5, color: PdfColors.grey700),
        if (r.summary.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text(r.summary, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey800)),
          pw.Divider(color: PdfColors.grey400),
        ],
        
        ...r.sectionOrder.map((sectionId) {
          switch (sectionId) {
            case 'work':
              if (r.workExperience.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(children: [
                _template4Section('Experience'),
                ...r.workExperience.map((w) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(children: [
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Text(w.role, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('${w.startDate} - ${w.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ]),
                    pw.Text(w.company, style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                    if (w.description.isNotEmpty)
                      pw.Text(w.description, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9)),
                  ]),
                )),
              ]);
            case 'education':
              if (r.education.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(children: [
                _template4Section('Education'),
                ...r.education.map((e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(children: [
                    pw.Text('${e.degree} in ${e.field}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(e.institution, style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                  ]),
                )),
              ]);
            case 'certifications':
              if (r.certifications.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(children: [
                _template4Section('Certifications'),
                ...r.certifications.map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(children: [
                    pw.Text(c.name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${c.issuer} ${c.dateIssued ?? ""}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ]),
                )),
              ]);
            case 'licenses':
              if (r.licenses.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(children: [
                _template4Section('Licenses'),
                ...r.licenses.map((l) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(children: [
                    pw.Text(l.licenseName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(l.issuingAuthority, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ]),
                )),
              ]);
            case 'awards':
              if (r.awards.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(children: [
                _template4Section('Awards'),
                ...r.awards.map((a) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(children: [
                    pw.Text(a.title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${a.organization} ${a.year ?? ""}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ]),
                )),
              ]);
            case 'languages':
              if (r.languages.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(children: [
                _template4Section('Languages'),
                pw.Text(r.languages.map((l) => '${l.name} (${l.proficiency})').join('  ·  '), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
              ]);
            case 'skills':
              if (r.skills.isEmpty) return pw.SizedBox.shrink();
              return pw.Column(children: [
                _template4Section('Skills'),
                pw.Text(r.skills.join('  ·  '), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
              ]);
            default:
              return pw.SizedBox.shrink();
          }
        }),
      ],
    ));
    return doc.save();
  }

  // ─── Template 5: Dark Accent Sidebar ───────────────────────────────────────

  static Future<Uint8List> _buildTemplate5(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.FullPage(
          ignoreMargins: true,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                width: 150,
                color: const PdfColor.fromInt(0xFF1A1A2E),
                padding: const pw.EdgeInsets.all(14),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (image != null) 
                      pw.Center(child: _buildCircularImage(image, 90)),
                    if (image != null) pw.SizedBox(height: 10),
                    pw.Center(child: pw.Text(r.name, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                    pw.SizedBox(height: 14),
                    if (r.email.isNotEmpty) _sidebarLabel5('EMAIL', r.email),
                    if (r.phone.isNotEmpty) _sidebarLabel5('PHONE', r.phone),
                    if (r.location.isNotEmpty) _sidebarLabel5('LOCATION', r.location),
                    if (r.skills.isNotEmpty) ...[
                      pw.SizedBox(height: 12),
                      _sidebarLabel5('SKILLS', ''),
                      ...r.skills.map((s) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 3),
                        child: pw.Row(children: [
                          pw.Text('› ', style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF00BCD4))),
                          pw.Expanded(child: pw.Text(s, style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFB0BEC5)))),
                        ]),
                      )),
                    ],
                    if (r.languages.isNotEmpty) ...[
                      pw.SizedBox(height: 12),
                      _sidebarLabel5('LANGUAGES', ''),
                      ...r.languages.map((l) => pw.Text('${l.name} (${l.proficiency})', style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFFB0BEC5)))),
                    ],
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  color: const PdfColor.fromInt(0xFFF5F5F5),
                  padding: const pw.EdgeInsets.all(14),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (r.summary.isNotEmpty) ...[
                        _template5Section('Summary'),
                        pw.Text(r.summary, style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 8),
                      ],
                      
                      ...r.sectionOrder.map((sectionId) {
                        switch (sectionId) {
                          case 'work':
                            if (r.workExperience.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template5Section('Experience'),
                              ...r.workExperience.map((w) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 7),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(w.role, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text('${w.company}  •  ${w.startDate} - ${w.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                                    if (w.description.isNotEmpty)
                                      pw.Text(w.description, style: const pw.TextStyle(fontSize: 9)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'education':
                            if (r.education.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template5Section('Education'),
                              ...r.education.map((e) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('${e.degree} in ${e.field}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(e.institution, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'certifications':
                            if (r.certifications.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template5Section('Certifications'),
                              ...r.certifications.map((c) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(c.name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text('${c.issuer} ${c.dateIssued ?? ""}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'licenses':
                            if (r.licenses.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template5Section('Licenses'),
                              ...r.licenses.map((l) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(l.licenseName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(l.issuingAuthority, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          case 'awards':
                            if (r.awards.isEmpty) return pw.SizedBox.shrink();
                            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              _template5Section('Awards'),
                              ...r.awards.map((a) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(a.title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.Text('${a.organization} ${a.year ?? ""}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                  ],
                                ),
                              )),
                            ]);
                          default:
                            return pw.SizedBox.shrink();
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
    return doc.save();
  }

  static pw.Widget _sidebarLabel5(String label, String val) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF00BCD4), letterSpacing: 1)),
      if (val.isNotEmpty) pw.Text(val, style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFCFD8DC))),
      pw.SizedBox(height: 8),
    ],
  );

  static pw.Widget _template5Section(String title) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5, color: const PdfColor.fromInt(0xFF1A1A2E))),
      pw.Container(height: 1.5, color: const PdfColor.fromInt(0xFF1A1A2E)),
      pw.SizedBox(height: 4),
    ],
  );


  // ─── Template 9: Modern Minimal (Clean & Professional) ───────────────────────

  static Future<Uint8List> _buildTemplate9(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    doc.addPage(pw.Page(
      margin: const pw.EdgeInsets.all(72),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with name and divider
            pw.Text(r.name, style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.normal, letterSpacing: 2, color: const PdfColor.fromInt(0xFF1A1A1A))),
            pw.Container(height: 2, color: const PdfColor.fromInt(0xFF1A1A1A), width: 50, margin: const pw.EdgeInsets.symmetric(vertical: 12)),
            if (r.summary.isNotEmpty) pw.Text(r.summary, style: pw.TextStyle(fontSize: 11, color: const PdfColor.fromInt(0xFF666666))),
            pw.SizedBox(height: 20),
            
            // Two column layout (info + photo on same row)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (r.email.isNotEmpty || r.phone.isNotEmpty || r.location.isNotEmpty) ...[
                        pw.Text('CONTACT', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: const PdfColor.fromInt(0xFF1A1A1A))),
                        pw.SizedBox(height: 8),
                        if (r.email.isNotEmpty) pw.Text(r.email, style: pw.TextStyle(fontSize: 9, color: const PdfColor.fromInt(0xFF666666))),
                        if (r.phone.isNotEmpty) pw.Text(r.phone, style: pw.TextStyle(fontSize: 9, color: const PdfColor.fromInt(0xFF666666))),
                        if (r.location.isNotEmpty) pw.Text(r.location, style: pw.TextStyle(fontSize: 9, color: const PdfColor.fromInt(0xFF666666))),
                        pw.SizedBox(height: 20),
                      ],
                      if (r.skills.isNotEmpty) ...[
                        pw.Text('SKILLS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: const PdfColor.fromInt(0xFF1A1A1A))),
                        pw.SizedBox(height: 8),
                        ...r.skills.map((s) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 4), child: pw.Text('• $s', style: pw.TextStyle(fontSize: 9, color: const PdfColor.fromInt(0xFF666666))))).toList(),
                      ],
                      if (r.languages.isNotEmpty) ...[
                        pw.SizedBox(height: 20),
                        pw.Text('LANGUAGES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: const PdfColor.fromInt(0xFF1A1A1A))),
                        pw.SizedBox(height: 8),
                        ...r.languages.map((l) => pw.Text('${l.name} (${l.proficiency})', style: pw.TextStyle(fontSize: 9, color: const PdfColor.fromInt(0xFF666666)))),
                      ],
                      if (r.licenses.isNotEmpty) ...[
                        pw.SizedBox(height: 20),
                        pw.Text('LICENSES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: const PdfColor.fromInt(0xFF1A1A1A))),
                        pw.SizedBox(height: 8),
                        ...r.licenses.map((l) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(l.licenseName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            pw.Text(l.issuingAuthority, style: pw.TextStyle(fontSize: 8, color: const PdfColor.fromInt(0xFF666666))),
                            pw.Text('No: ${l.licenseNumber}', style: pw.TextStyle(fontSize: 7, color: const PdfColor.fromInt(0xFF999999))),
                            pw.SizedBox(height: 4),
                          ],
                        )),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 30),
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (image != null)
                        pw.Center(
                          child: pw.ClipRRect(
                            horizontalRadius: 50,
                            verticalRadius: 50,
                            child: pw.Image(image, width: 100, height: 100),
                          ),
                        ),
                      pw.SizedBox(height: 16),
                      if (r.workExperience.isNotEmpty) ...[
                        pw.Text('EXPERIENCE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: const PdfColor.fromInt(0xFF1A1A1A))),
                        pw.SizedBox(height: 10),
                        ...r.workExperience.map((job) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 14),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(job.role, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                              pw.Text(job.company, style: pw.TextStyle(fontSize: 10, color: const PdfColor.fromInt(0xFF666666))),
                              pw.Text('${job.startDate} - ${job.endDate}', style: pw.TextStyle(fontSize: 8, color: const PdfColor.fromInt(0xFF999999))),
                              pw.SizedBox(height: 4),
                              pw.Text(job.description, style: pw.TextStyle(fontSize: 9, height: 1.3)),
                            ],
                          ),
                        )),
                      ],
                      if (r.education.isNotEmpty) ...[
                        pw.Text('EDUCATION', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: const PdfColor.fromInt(0xFF1A1A1A))),
                        pw.SizedBox(height: 10),
                        ...r.education.map((edu) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(edu.degree, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal)),
                              pw.Text(edu.institution, style: pw.TextStyle(fontSize: 9, color: const PdfColor.fromInt(0xFF666666))),
                            ],
                          ),
                        )),
                      ],
                      if (r.certifications.isNotEmpty) ...[
                        pw.Text('CERTIFICATIONS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1, color: const PdfColor.fromInt(0xFF1A1A1A))),
                        pw.SizedBox(height: 10),
                        ...r.certifications.map((cert) => pw.Text('• ${cert.name} - ${cert.issuer}', style: pw.TextStyle(fontSize: 9, color: const PdfColor.fromInt(0xFF666666)))),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }));
    return doc.save();
  }

  // ─── Shared Helpers ───────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 8),
          pw.Text(title.toUpperCase(),
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800)),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.SizedBox(height: 4),
        ],
      );

  static pw.Widget _workEntry(WorkExperience w) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(w.role, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('${w.startDate} - ${w.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
            pw.Text(w.company, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            if (w.description.isNotEmpty)
              pw.Text(w.description, style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      );

  static pw.Widget _eduEntry(Education e) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${e.degree} in ${e.field}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('${e.startDate} - ${e.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
            pw.Text(e.institution, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
      );

  static pw.Widget _certEntry(Certification c) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(c.name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text('${c.issuer}${c.dateIssued != null ? ' | ${c.dateIssued}' : ''}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
      );

  static pw.Widget _licenseEntry(License l) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(l.licenseName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text(l.issuingAuthority, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.Text('No: ${l.licenseNumber} • Issued: ${l.issueDate} • Expires: ${l.expiryDate}', 
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          ],
        ),
      );

  static pw.Widget _awardEntry(Award a) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(a.title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                if (a.year != null) pw.Text(a.year!, style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.Text(a.organization, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
      );

  static pw.Widget _sideLabel(String label) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 6, bottom: 1),
        child: pw.Text(label.toUpperCase(),
            style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600)),
      );

  static const pw.TextStyle _smallStyle = pw.TextStyle(fontSize: 9);

  static pw.Widget _sidebarLabel(String label, String value) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF78909C), letterSpacing: 1)),
      pw.Text(value, style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
      pw.SizedBox(height: 8),
    ],
  );

  static pw.Widget _template3Section(String title) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF263238), letterSpacing: 1.5)),
      pw.Container(height: 1, color: const PdfColor.fromInt(0xFF263238)),
      pw.SizedBox(height: 6),
    ],
  );

  static pw.Widget _template4Section(String title) => pw.Column(
    children: [
      pw.SizedBox(height: 12),
      pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
      pw.SizedBox(height: 4),
      pw.Container(width: 40, height: 1, color: PdfColors.grey700),
      pw.SizedBox(height: 8),
    ],
  );

  static pw.Widget _buildCircularImage(pw.ImageProvider image, double size) {
    return pw.Container(
      width: size,
      height: size,
      decoration: const pw.BoxDecoration(
        shape: pw.BoxShape.circle,
      ),
      child: pw.ClipOval(
        child: pw.Image(image, fit: pw.BoxFit.cover),
      ),
    );
  }

  // ─── Template 11: Clean Minimal ───────────────────────────────────

  static Future<Uint8List> _buildTemplate11(ResumeModel r, bool isPrinterFriendly, pw.ThemeData theme, pw.ImageProvider? image) async {
    final doc = pw.Document(theme: theme);
    final primaryColor = const PdfColor.fromInt(0xFF2C3E50);
    final greyText = const PdfColor.fromInt(0xFF666666);
    final darkText = const PdfColor.fromInt(0xFF333333);
    final dividerColor = const PdfColor.fromInt(0xFFCCCCCC);
    final lightGreyBg = const PdfColor.fromInt(0xFFF0F0F0);

    pw.Widget _buildDivider() {
      return pw.Container(
        width: 40,
        height: 1,
        color: dividerColor,
      );
    }

    pw.Widget _buildSectionTitle(String title) {
      return pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.5,
          color: primaryColor,
        ),
      );
    }

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(vertical: 36, horizontal: 0),
      build: (ctx) => [
        // Thin colored top bar
        pw.Container(
          width: double.infinity,
          height: 4,
          color: primaryColor,
        ),
        pw.SizedBox(height: 28),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Name
              pw.Text(
                r.name,
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 8),
              // Contact info
              pw.Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  if (r.email.isNotEmpty) pw.Text(r.email, style: pw.TextStyle(fontSize: 9, color: greyText)),
                  if (r.phone.isNotEmpty) pw.Text(r.phone, style: pw.TextStyle(fontSize: 9, color: greyText)),
                  if (r.location.isNotEmpty) pw.Text(r.location, style: pw.TextStyle(fontSize: 9, color: greyText)),
                  if (r.website.isNotEmpty) pw.Text(r.website, style: pw.TextStyle(fontSize: 9, color: greyText)),
                ],
              ),
              pw.SizedBox(height: 20),
              _buildDivider(),
              pw.SizedBox(height: 16),
              
              // Profile/Summary
              if (r.summary.isNotEmpty) ...[
                _buildSectionTitle('PROFILE'),
                pw.SizedBox(height: 8),
                pw.Text(r.summary, style: pw.TextStyle(fontSize: 10, lineSpacing: 1.5, color: darkText)),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
              ],
              
              // Work Experience
              if (r.workExperience.isNotEmpty) ...[
                _buildSectionTitle('WORK EXPERIENCE'),
                pw.SizedBox(height: 10),
                ...r.workExperience.map((job) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(job.role, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                          pw.Text('${job.startDate} - ${job.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(job.company, style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: greyText)),
                      if (job.description.isNotEmpty) ...[
                        pw.SizedBox(height: 6),
                        pw.Text(job.description, style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.4, color: PdfColors.grey800)),
                      ],
                    ],
                  ),
                )),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
              ],
              
              // Education
              if (r.education.isNotEmpty) ...[
                _buildSectionTitle('EDUCATION'),
                pw.SizedBox(height: 10),
                ...r.education.map((edu) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${edu.degree} in ${edu.field}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                          pw.Text('${edu.startDate} - ${edu.endDate}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(edu.institution, style: pw.TextStyle(fontSize: 10, color: greyText)),
                    ],
                  ),
                )),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
              ],
              
              // Certifications
              if (r.certifications.isNotEmpty) ...[
                _buildSectionTitle('CERTIFICATIONS'),
                pw.SizedBox(height: 10),
                ...r.certifications.map((cert) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(cert.name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text(cert.issuer, style: pw.TextStyle(fontSize: 9, color: greyText)),
                      if (cert.dateIssued != null && cert.dateIssued!.isNotEmpty)
                        pw.Text('Issued: ${cert.dateIssued}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                    ],
                  ),
                )),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
              ],
              
              // Licenses
              if (r.licenses.isNotEmpty) ...[
                _buildSectionTitle('LICENSES'),
                pw.SizedBox(height: 10),
                ...r.licenses.map((license) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(license.licenseName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text(license.issuingAuthority, style: pw.TextStyle(fontSize: 9, color: greyText)),
                      if (license.issueDate.isNotEmpty)
                        pw.Text('License No: ${license.licenseNumber} • Issued: ${license.issueDate}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                    ],
                  ),
                )),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
              ],
              
              // Awards
              if (r.awards.isNotEmpty) ...[
                _buildSectionTitle('AWARDS'),
                pw.SizedBox(height: 10),
                ...r.awards.map((award) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(award.title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                          if (award.year != null && award.year!.isNotEmpty)
                            pw.Text(award.year!, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                        ],
                      ),
                      pw.Text(award.organization, style: pw.TextStyle(fontSize: 9, color: greyText)),
                      if (award.description != null && award.description!.isNotEmpty)
                        pw.Text(award.description!, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                )),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
              ],
              
              // Skills
              if (r.skills.isNotEmpty) ...[
                _buildSectionTitle('SKILLS'),
                pw.SizedBox(height: 8),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: r.skills.map((skill) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: lightGreyBg,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                    ),
                    child: pw.Text(skill, style: pw.TextStyle(fontSize: 9, color: darkText)),
                  )).toList(),
                ),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
              ],
              
              // Languages
              if (r.languages.isNotEmpty) ...[
                _buildSectionTitle('LANGUAGES'),
                pw.SizedBox(height: 8),
                pw.Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: r.languages.map((lang) => pw.Text(
                    '${lang.name} (${lang.proficiency})',
                    style: pw.TextStyle(fontSize: 10, color: darkText),
                  )).toList(),
                ),
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    ));
    return doc.save();
  }
}