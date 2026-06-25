import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resume_model.dart';
import '../providers/resume_provider.dart';
import '../services/pdf_service.dart';
import '../utils/constants.dart';
import 'package:reorderables/reorderables.dart';
import 'package:intl/intl.dart';
import '../models/route_args.dart';
import '../widgets/resume_templates/template_data.dart';
import '../widgets/resume_templates/templates/templates.dart';

class ResumeEditorScreen extends ConsumerStatefulWidget {
  const ResumeEditorScreen({super.key});

  @override
  ConsumerState<ResumeEditorScreen> createState() =>
      _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends ConsumerState<ResumeEditorScreen> {
  int _step = 0;
  bool _saving = false;
  bool _exporting = false;
  bool _uploadingPhoto = false;

  // Personal info controllers
  final _titleCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  String? _photoUrl;

  // Sections list (mutable)
  List<WorkExperience> _workExp = [];
  List<Education> _education = [];
  List<Certification> _certifications = [];
  List<License> _licenses = [];
  List<Award> _awards = [];
  List<Language> _languages = [];
  List<String> _skills = [];
  List<String> _sectionOrder = ["summary", "licenses", "work", "education", "certifications", "awards", "skills", "languages"];

  final _skillCtrl = TextEditingController();
  String _selectedTemplate = '';
  String _templateFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final r = ref.read(currentResumeProvider);
      if (r == null) return;
      _titleCtrl.text = r.title;
      _nameCtrl.text = r.name;
      _emailCtrl.text = r.email;
      _phoneCtrl.text = r.phone;
      _locCtrl.text = r.location;
      _summaryCtrl.text = r.summary;
      _websiteCtrl.text = r.website;
      setState(() {
        _photoUrl = r.photoUrl;
        _workExp = List.from(r.workExperience);
        _education = List.from(r.education);
        _certifications = List.from(r.certifications);
        _licenses = List.from(r.licenses);
        _awards = List.from(r.awards);
        _languages = List.from(r.languages);
        _skills = List.from(r.skills);
        _selectedTemplate = r.templateId;
        _sectionOrder = List.from(r.sectionOrder);
      });
    });
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl, _nameCtrl, _emailCtrl, _phoneCtrl,
      _locCtrl, _summaryCtrl, _websiteCtrl, _skillCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  ResumeModel _buildResume() {
    final current = ref.read(currentResumeProvider)!;
    return current.copyWith(
      title: _titleCtrl.text.trim().isEmpty ? 'My Resume' : _titleCtrl.text.trim(),
      photoUrl: _photoUrl,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      location: _locCtrl.text.trim(),
      summary: _summaryCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      workExperience: _workExp,
      education: _education,
      certifications: _certifications,
      licenses: _licenses,
      awards: _awards,
      languages: _languages,
      skills: _skills,
      templateId: _selectedTemplate.isEmpty ? 'template_1' : _selectedTemplate,
      sectionOrder: _sectionOrder,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await ref.read(resumeListProvider.notifier).save(_buildResume());
      ref.read(currentResumeProvider.notifier).state = saved;
      if (mounted) {
        Navigator.pushNamed(
          context,
          kRouteResumeView,
          arguments: ResumeViewArgs(resume: saved),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final resume = _buildResume();
      final bytes = await PdfService.generateResumePdf(resume);
      await PdfService.sharePdf(bytes, resume.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  static const _steps = [
    'Personal Info',
    'Experience',
    'Education',
    'Certifications',
    'Licenses',
    'Awards',
    'Languages',
    'Skills',
    'Template',
    'Preview',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Resume Editor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: kAccentBlue, strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(
                      color: kAccentBlue, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _steps.length,
              itemBuilder: (_, i) {
                final active = i == _step;
                return GestureDetector(
                  onTap: () => setState(() => _step = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? kAccentBlue : kSurface,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(
                        color: active ? kAccentBlue : kBorderColor,
                      ),
                    ),
                    child: Text(
                      _steps[i],
                      style: TextStyle(
                        color: active ? Colors.white : kSecondaryText,
                        fontSize: kFontSmall,
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: kBorderColor),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kPadL),
              child: _buildStep(),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: kPadL, vertical: kPadM),
            decoration: const BoxDecoration(
              color: kBackground,
              border:
                  Border(top: BorderSide(color: kBorderColor)),
            ),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: _step == _steps.length - 1
                      ? ElevatedButton.icon(
                          onPressed: _exporting ? null : _exportPdf,
                          icon: _exporting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2))
                              : const Icon(Icons.picture_as_pdf),
                          label: const Text('Export PDF'),
                        )
                      : ElevatedButton(
                          onPressed: () => setState(() => _step++),
                          child: const Text('Next'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _personalInfoStep();
      case 1: return _workExpStep();
      case 2: return _educationStep();
      case 3: return _certificationsStep();
      case 4: return _licensesStep();
      case 5: return _awardsStep();
      case 6: return _languagesStep();
      case 7: return _skillsStep();
      case 8: return _templateStep();
      case 9: return _previewStep();
      default: return const SizedBox.shrink();
    }
  }

  // ── Step 0: Personal Info ────────────────────────────────────────────────

  Widget _personalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Personal Information'),
        
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: kSurface,
                  backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                  child: _uploadingPhoto 
                    ? const CircularProgressIndicator()
                    : _photoUrl == null 
                      ? const Icon(Icons.camera_alt, size: 40, color: kSecondaryText) 
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap to upload photo', style: TextStyle(color: kSecondaryText, fontSize: kFontSmall)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _tf(_titleCtrl, 'Internal Resume Name (e.g. Software Engineer App)', Icons.drive_file_rename_outline),
        const Padding(
          padding: EdgeInsets.only(top: 4, left: 12),
          child: Text(
            'This name helps you identify your resumes and will NOT appear on the final PDF.',
            style: TextStyle(color: kSecondaryText, fontSize: 10, fontStyle: FontStyle.italic),
          ),
        ),
        _gap(),
        _tf(_nameCtrl, 'Full Name', Icons.person_outline),
        _gap(),
        _tf(_emailCtrl, 'Email', Icons.email_outlined,
            type: TextInputType.emailAddress),
        _gap(),
        _tf(_phoneCtrl, 'Phone', Icons.phone_outlined,
            type: TextInputType.phone),
        _gap(),
        _tf(_locCtrl, 'Location', Icons.location_on_outlined),
        _gap(),
        _tf(_websiteCtrl, 'Website (optional)', Icons.link),
        _gap(),
        _label('Professional Summary'),
        TextFormField(
          controller: _summaryCtrl,
          maxLines: 4,
          style: const TextStyle(color: kPrimaryText, fontSize: kFontBase),
          decoration: InputDecoration(
            hintText: 'A brief summary of your skills and experience...',
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
              borderSide: const BorderSide(color: kAccentBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw 'User not logged in';

      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await image.readAsBytes();
      
      await supabase.storage.from('resume_photos').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
          contentType: 'image/jpeg',
        ),
      );

      final publicUrl = supabase.storage.from('resume_photos').getPublicUrl(fileName);
      setState(() => _photoUrl = publicUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      setState(() => _uploadingPhoto = false);
    }
  }

  // ── Step 1: Work Experience ──────────────────────────────────────────────

  Widget _workExpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Work Experience'),
        ..._workExp.asMap().entries.map((e) => _workCard(e.key, e.value)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _workExp.add(const WorkExperience())),
          icon: const Icon(Icons.add, color: kAccentBlue),
          label: const Text('Add Experience',
              style: TextStyle(color: kAccentBlue)),
        ),
      ],
    );
  }

  Widget _workCard(int idx, WorkExperience w) {
    final p = 'work_${idx}_';
    return _listCard(
      title: 'Experience ${idx + 1}',
      onDelete: () => setState(() => _workExp.removeAt(idx)),
      children: [
        _tfVal(w.role, 'Job Title', (v) {
          setState(() => _workExp[idx] = _workExp[idx].copyWith(role: v));
        }, keyPrefix: p),
        _gap(),
        _tfVal(w.company, 'Company', (v) {
          setState(() => _workExp[idx] = _workExp[idx].copyWith(company: v));
        }, keyPrefix: p),
        _gap(),
        Row(
          children: [
            Expanded(child: _dateField(w.startDate, 'Start Date', (v) {
              setState(() => _workExp[idx] = _workExp[idx].copyWith(startDate: v));
            }, keyPrefix: p)),
            const SizedBox(width: 10),
            Expanded(child: _dateField(w.endDate, 'End Date', (v) {
              setState(() => _workExp[idx] = _workExp[idx].copyWith(endDate: v));
            }, keyPrefix: p)),
          ],
        ),
        _gap(),
        _tfVal(w.description, 'Description', (v) {
          setState(() => _workExp[idx] = _workExp[idx].copyWith(description: v));
        }, lines: 3, keyPrefix: p),
      ],
    );
  }

  // ── Step 2: Education ────────────────────────────────────────────────────

  Widget _educationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Education'),
        ..._education.asMap().entries.map((e) => _eduCard(e.key, e.value)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _education.add(const Education())),
          icon: const Icon(Icons.add, color: kAccentBlue),
          label: const Text('Add Education',
              style: TextStyle(color: kAccentBlue)),
        ),
      ],
    );
  }

  Widget _eduCard(int idx, Education e) {
    final p = 'edu_${idx}_';
    return _listCard(
      title: 'Education ${idx + 1}',
      onDelete: () => setState(() => _education.removeAt(idx)),
      children: [
        _tfVal(e.institution, 'Institution', (v) {
          setState(() => _education[idx] = _education[idx].copyWith(institution: v));
        }, keyPrefix: p),
        _gap(),
        _tfVal(e.degree, 'Degree (e.g. Bachelor\'s)', (v) {
          setState(() => _education[idx] = _education[idx].copyWith(degree: v));
        }, keyPrefix: p),
        _gap(),
        _tfVal(e.field, 'Field of Study', (v) {
          setState(() => _education[idx] = _education[idx].copyWith(field: v));
        }, keyPrefix: p),
        _gap(),
        Row(
          children: [
            Expanded(child: _dateField(e.startDate, 'Start Year', (v) {
              setState(() => _education[idx] = _education[idx].copyWith(startDate: v));
            }, keyPrefix: p)),
            const SizedBox(width: 10),
            Expanded(child: _dateField(e.endDate, 'End Year', (v) {
              setState(() => _education[idx] = _education[idx].copyWith(endDate: v));
            }, keyPrefix: p)),
          ],
        ),
      ],
    );
  }

  // ── Step 3: Certifications ──────────────────────────────────────────────

  Widget _certificationsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Certifications'),
        ..._certifications.asMap().entries.map((e) => _certCard(e.key, e.value)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _certifications.add(Certification(name: '', issuer: ''))),
          icon: const Icon(Icons.add, color: kAccentBlue),
          label: const Text('Add Certification', style: TextStyle(color: kAccentBlue)),
        ),
      ],
    );
  }

  Widget _certCard(int idx, Certification c) {
    final p = 'cert_${idx}_';
    return _listCard(
      title: 'Certification ${idx + 1}',
      onDelete: () => setState(() => _certifications.removeAt(idx)),
      children: [
        _tfVal(c.name, 'Certification Name', (v) {
          setState(() => _certifications[idx] = _certifications[idx].copyWith(name: v));
        }, keyPrefix: p),
        _gap(),
        _tfVal(c.issuer, 'Issuer', (v) {
          setState(() => _certifications[idx] = _certifications[idx].copyWith(issuer: v));
        }, keyPrefix: p),
        _gap(),
        Row(
          children: [
            Expanded(child: _dateField(c.dateIssued ?? '', 'Date Issued', (v) {
              setState(() => _certifications[idx] = _certifications[idx].copyWith(dateIssued: v));
            }, keyPrefix: p)),
            const SizedBox(width: 10),
            Expanded(child: _dateField(c.expiryDate ?? '', 'Expiry Date', (v) {
              setState(() => _certifications[idx] = _certifications[idx].copyWith(expiryDate: v));
            }, keyPrefix: p)),
          ],
        ),
      ],
    );
  }

  // ── Step 4: Licenses ─────────────────────────────────────────────────────

  Widget _licensesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Professional Licenses'),
        ..._licenses.asMap().entries.map((e) => _licenseCard(e.key, e.value)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _licenses.add(
            const License(
              licenseName: '',
              licenseNumber: '',
              issueDate: '',
              expiryDate: '',
              issuingAuthority: '',
            )
          )),
          icon: const Icon(Icons.add, color: kAccentBlue),
          label: const Text('Add License', style: TextStyle(color: kAccentBlue)),
        ),
      ],
    );
  }

  Widget _licenseCard(int idx, License l) {
    final p = 'lic_${idx}_';
    return _listCard(
      title: 'License ${idx + 1}',
      onDelete: () => setState(() => _licenses.removeAt(idx)),
      children: [
        _tfVal(l.licenseName, 'License Name (e.g. Professional Engineer)', (v) {
          setState(() => _licenses[idx] = _licenses[idx].copyWith(licenseName: v));
        }, keyPrefix: p),
        _gap(),
        _tfVal(l.issuingAuthority, 'Issuing Authority (e.g. PRC)', (v) {
          setState(() => _licenses[idx] = _licenses[idx].copyWith(issuingAuthority: v));
        }, keyPrefix: p),
        _gap(),
        _tfVal(l.licenseNumber, 'License Number', (v) {
          setState(() => _licenses[idx] = _licenses[idx].copyWith(licenseNumber: v));
        }, keyPrefix: p),
        _gap(),
        Row(
          children: [
            Expanded(child: _dateField(l.issueDate, 'Issue Date', (v) {
              setState(() => _licenses[idx] = _licenses[idx].copyWith(issueDate: v));
            }, keyPrefix: p)),
            const SizedBox(width: 10),
            Expanded(child: _dateField(l.expiryDate, 'Expiry Date', (v) {
              setState(() => _licenses[idx] = _licenses[idx].copyWith(expiryDate: v));
            }, keyPrefix: p)),
          ],
        ),
      ],
    );
  }

  // ── Step 5: Awards ───────────────────────────────────────────────────────

  Widget _awardsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Awards'),
        ..._awards.asMap().entries.map((e) => _awardCard(e.key, e.value)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _awards.add(Award(title: '', organization: ''))),
          icon: const Icon(Icons.add, color: kAccentBlue),
          label: const Text('Add Award', style: TextStyle(color: kAccentBlue)),
        ),
      ],
    );
  }

  Widget _awardCard(int idx, Award a) {
    final p = 'award_${idx}_';
    return _listCard(
      title: 'Award ${idx + 1}',
      onDelete: () => setState(() => _awards.removeAt(idx)),
      children: [
        _tfVal(a.title, 'Award Title', (v) {
          setState(() => _awards[idx] = _awards[idx].copyWith(title: v));
        }, keyPrefix: p),
        _gap(),
        _tfVal(a.organization, 'Organization', (v) {
          setState(() => _awards[idx] = _awards[idx].copyWith(organization: v));
        }, keyPrefix: p),
        _gap(),
        _tfVal(a.year ?? '', 'Year', (v) {
          setState(() => _awards[idx] = _awards[idx].copyWith(year: v));
        }, keyPrefix: p),
        _gap(),
        _tfVal(a.description ?? '', 'Description', (v) {
          setState(() => _awards[idx] = _awards[idx].copyWith(description: v));
        }, lines: 2, keyPrefix: p),
      ],
    );
  }

  // ── Step 6: Languages ────────────────────────────────────────────────────

  Widget _languagesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Languages'),
        ..._languages.asMap().entries.map((e) => _languageCard(e.key, e.value)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _languages.add(Language(name: '', proficiency: 'Basic'))),
          icon: const Icon(Icons.add, color: kAccentBlue),
          label: const Text('Add Language', style: TextStyle(color: kAccentBlue)),
        ),
      ],
    );
  }

  Widget _languageCard(int idx, Language l) {
    final p = 'lang_${idx}_';
    return _listCard(
      title: 'Language ${idx + 1}',
      onDelete: () => setState(() => _languages.removeAt(idx)),
      children: [
        _tfVal(l.name, 'Language Name (e.g. English)', (v) {
          setState(() => _languages[idx] = _languages[idx].copyWith(name: v));
        }, keyPrefix: p),
        _gap(),
        DropdownButtonFormField<String>(
          value: l.proficiency,
          dropdownColor: kSurface,
          style: const TextStyle(color: kPrimaryText),
          decoration: const InputDecoration(labelText: 'Proficiency'),
          items: ["Native", "Fluent", "Intermediate", "Basic"]
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _languages[idx] = _languages[idx].copyWith(proficiency: v));
          },
        ),
      ],
    );
  }

  // ── Step 7: Skills ───────────────────────────────────────────────────────

  Widget _skillsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Skills'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _skillCtrl,
                style: const TextStyle(color: kPrimaryText),
                decoration: const InputDecoration(
                  hintText: 'e.g. Flutter, Python, Leadership...',
                  prefixIcon:
                      Icon(Icons.add_circle_outline, color: kSecondaryText),
                ),
                onFieldSubmitted: (v) => _addSkill(),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _addSkill,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(56, 48)),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((s) => _skillChip(s)).toList(),
        ),
      ],
    );
  }

  void _addSkill() {
    final v = _skillCtrl.text.trim();
    if (v.isNotEmpty && !_skills.contains(v)) {
      setState(() {
        _skills.add(v);
        _skillCtrl.clear();
      });
    }
  }

  Widget _skillChip(String skill) {
    return Chip(
      label: Text(skill,
          style: const TextStyle(color: kPrimaryText, fontSize: kFontSmall)),
      backgroundColor: kSurface,
      side: const BorderSide(color: kBorderColor),
      deleteIcon: const Icon(Icons.close, size: 14, color: kSecondaryText),
      onDeleted: () => setState(() => _skills.remove(skill)),
    );
  }

  // ── Step 8: Template ─────────────────────────────────────────────────────

  Widget _templateStep() {
    final filteredTemplates = allTemplates.where((t) {
      if (_templateFilter == 'ATS') return t.isAtsFriendly;
      if (_templateFilter == 'Creative') return !t.isAtsFriendly;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionHeader('Choose Template'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.info_outline, color: kSecondaryText, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: kSurface,
                    title: const Text('Template Types', style: TextStyle(color: kPrimaryText)),
                    content: const Text(
                      'ATS Friendly: Best for online applications (LinkedIn, Indeed, Workday)\n\nCreative: Best for printed resumes or emailing directly to recruiters',
                      style: TextStyle(color: kSecondaryText),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'ATS', 'Creative'].map((f) {
              final active = _templateFilter == f;
              return GestureDetector(
                onTap: () => setState(() => _templateFilter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? kAccentBlue : kSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? kAccentBlue : kBorderColor),
                  ),
                  child: Text(f, style: TextStyle(color: active ? Colors.white : kSecondaryText, fontSize: 12)),
                ),
              );
            }).toList(),
          ),
        ),

        NotificationListener<ScrollEndNotification>(
          onNotification: (notification) {
            return true;
          },
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTemplates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, i) => _templateCard(filteredTemplates[i]),
          ),
        ),
      ],
    );
  }

  Widget _templateCard(ResumeTemplateData data) {
    final selected = data.id == _selectedTemplate;
    final resume = _buildResume();
    
    Widget preview;
    switch (data.id) {
      case 'template_1': preview = ResumeTemplate1(resume: resume); break;
      case 'template_2': preview = ResumeTemplate2(resume: resume); break;
      case 'template_3': preview = ResumeTemplate3(resume: resume); break;
      case 'template_4': preview = ResumeTemplate4(resume: resume); break;
      case 'template_5': preview = ResumeTemplate5(resume: resume); break;
      case 'template_6': preview = ResumeTemplate6(resume: resume); break;
      case 'template_7': preview = ResumeTemplate7(resume: resume); break;
      case 'template_8': preview = ResumeTemplate8(resume: resume); break;
      case 'template_9': preview = ResumeTemplate9(resume: resume); break;
      default: preview = ResumeTemplate1(resume: resume);
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedTemplate = data.id),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadiusCard),
              border: Border.all(
                color: selected ? kAccentBlue : kBorderColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusCard - 1)),
                    child: Container(
                      color: Colors.white,
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: Transform.scale(
                          scale: 0.38,
                          alignment: Alignment.topLeft,
                          child: SizedBox(width: 595, child: preview),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? kAccentBlue : kSurface,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(kRadiusCard - 1)),
                  ),
                  child: Text(
                    data.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? Colors.white : kSecondaryText,
                      fontSize: kFontSmall,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: data.isAtsFriendly ? Colors.green.withOpacity(0.9) : Colors.purple.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(data.isAtsFriendly ? Icons.smart_toy : Icons.palette, size: 10, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    data.isAtsFriendly ? 'ATS' : 'Creative',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 9: Preview with Print Preview Button ───────────────────────────

  Widget _previewStep() {
    final resume = _buildResume();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionHeader('Preview'),
            const Spacer(),
            TextButton.icon(
              onPressed: _showReorderDialog,
              icon: const Icon(Icons.reorder, size: 18),
              label: const Text('Reorder Sections'),
            ),
          ],
        ),
        const Text('This is how your resume will look when exported.',
            style: TextStyle(color: kSecondaryText, fontSize: kFontSmall)),
        const SizedBox(height: 16),
        
        // Print Preview Button
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              kRoutePrintPreview,
              arguments: PrintPreviewArgs(
                resume: resume,
                selectedTemplateId: _selectedTemplate,
              ),
            );
          },
          icon: const Icon(Icons.print),
          label: const Text('Open Print Preview'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        
        const SizedBox(height: 16),
        const Text('Quick preview (scaled)',
            style: TextStyle(color: kSecondaryText, fontSize: kFontSmall)),
        const SizedBox(height: 8),
        
        // Scaled preview (clickable to open print preview)
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              kRoutePrintPreview,
              arguments: PrintPreviewArgs(
                resume: resume,
                selectedTemplateId: _selectedTemplate,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(kRadiusInput),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kRadiusInput),
              child: _buildResumePreview(resume),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumePreview(ResumeModel resume) {
    switch (_selectedTemplate) {
      case 'template_1': return ResumeTemplate1(resume: resume);
      case 'template_2': return ResumeTemplate2(resume: resume);
      case 'template_3': return ResumeTemplate3(resume: resume);
      case 'template_4': return ResumeTemplate4(resume: resume);
      case 'template_5': return ResumeTemplate5(resume: resume);
      case 'template_6': return ResumeTemplate6(resume: resume);
      case 'template_7': return ResumeTemplate7(resume: resume);
      case 'template_8': return ResumeTemplate8(resume: resume);
      case 'template_9': return ResumeTemplate9(resume: resume);
      default: return ResumeTemplate1(resume: resume);
    }
  }

  void _showReorderDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Drag to Reorder Sections', style: TextStyle(color: kPrimaryText, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Flexible(
                child: SizedBox(
                  height: 350,
                  child: ReorderableListView.builder(
                    itemCount: _sectionOrder.length,
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) {
                      setModalState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = _sectionOrder.removeAt(oldIndex);
                        _sectionOrder.insert(newIndex, item);
                      });
                      setState(() {});
                    },
                    itemBuilder: (itemContext, index) {
                      final s = _sectionOrder[index];
                      final sectionNames = {
                        'summary': 'Professional Summary',
                        'licenses': 'Licenses',
                        'work': 'Work Experience',
                        'education': 'Education',
                        'certifications': 'Certifications',
                        'awards': 'Awards',
                        'skills': 'Skills',
                        'languages': 'Languages',
                      };
                      return Container(
                        key: ValueKey(s),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorderColor),
                        ),
                        child: ListTile(
                          leading: ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_indicator, color: kAccentBlue),
                          ),
                          title: Text(sectionNames[s] ?? s.toUpperCase(), 
                              style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Navigator.pop(modalContext), child: const Text('Done')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _listCard({required String title, required VoidCallback onDelete, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(kPadM),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(color: kPrimaryText, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: kError, size: 18),
                onPressed: onDelete,
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _tfVal(String value, String hint, Function(String) onChanged,
      {int lines = 1, String keyPrefix = ''}) {
    return TextFormField(
      key: ValueKey('$keyPrefix$hint'),
      initialValue: value,
      maxLines: lines,
      style: const TextStyle(color: kPrimaryText),
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.all(12),
      ),
      onChanged: onChanged,
    );
  }

  Widget _gap() => const SizedBox(height: 12);

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryText),
      ),
    );
  }

  Widget _dateField(String initial, String label, ValueChanged<String> onSelected,
      {String keyPrefix = ''}) {
    return TextFormField(
      key: ValueKey('$keyPrefix$label'),
      initialValue: initial,
      style: const TextStyle(color: kPrimaryText),
      decoration: InputDecoration(
        hintText: '$label (e.g. 2023 or Present)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.all(12),
      ),
      onChanged: onSelected,
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: kSecondaryText, fontSize: kFontSmall)),
      );

  Widget _tf(TextEditingController c, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) =>
      TextFormField(
        controller: c,
        keyboardType: type,
        style: const TextStyle(color: kPrimaryText),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: kSecondaryText),
        ),
    );
}