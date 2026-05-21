class ResumeTemplateData {
  final String id;
  final String name;
  final bool isAtsFriendly; // true = ATS, false = Creative
  final String thumbnailAsset;
  
  const ResumeTemplateData({
    required this.id,
    required this.name,
    required this.isAtsFriendly,
    this.thumbnailAsset = '',
  });
}

final List<ResumeTemplateData> allTemplates = [
  ResumeTemplateData(id: 'template_1', name: 'Classic', isAtsFriendly: true),
  ResumeTemplateData(id: 'template_2', name: 'Modern Blue', isAtsFriendly: false),
  ResumeTemplateData(id: 'template_3', name: 'Two Column', isAtsFriendly: false),
  ResumeTemplateData(id: 'template_4', name: 'Dark Accent', isAtsFriendly: false),
  ResumeTemplateData(id: 'template_5', name: 'Professional Classic', isAtsFriendly: true),
  ResumeTemplateData(id: 'template_6', name: 'Minimalist Sans', isAtsFriendly: true),
  ResumeTemplateData(id: 'template_7', name: 'Corporate Sidebar', isAtsFriendly: false),
  ResumeTemplateData(id: 'template_8', name: 'Modern Minimal', isAtsFriendly: true),
  ResumeTemplateData(id: 'template_9', name: 'Modern Minimal', isAtsFriendly: true),
  ResumeTemplateData(id: 'template_10', name: 'Executive Pro', isAtsFriendly: true),
  ResumeTemplateData(id: 'template_11', name: 'Clean Minimal', isAtsFriendly: true),
];
