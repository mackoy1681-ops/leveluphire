class WorkExperience {
  final String company;
  final String role;
  final String startDate;
  final String endDate;
  final String description;

  const WorkExperience({
    this.company = '',
    this.role = '',
    this.startDate = '',
    this.endDate = '',
    this.description = '',
  });

  Map<String, dynamic> toMap() => {
        'company': company,
        'role': role,
        'start_date': startDate,
        'end_date': endDate,
        'description': description,
      };

  factory WorkExperience.fromMap(Map<String, dynamic> m) => WorkExperience(
        company: m['company'] as String? ?? '',
        role: m['role'] as String? ?? '',
        startDate: m['start_date'] as String? ?? '',
        endDate: m['end_date'] as String? ?? '',
        description: m['description'] as String? ?? '',
      );

  WorkExperience copyWith({
    String? company,
    String? role,
    String? startDate,
    String? endDate,
    String? description,
  }) =>
      WorkExperience(
        company: company ?? this.company,
        role: role ?? this.role,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        description: description ?? this.description,
      );
}

class Education {
  final String institution;
  final String degree;
  final String field;
  final String startDate;
  final String endDate;

  const Education({
    this.institution = '',
    this.degree = '',
    this.field = '',
    this.startDate = '',
    this.endDate = '',
  });

  Map<String, dynamic> toMap() => {
        'institution': institution,
        'degree': degree,
        'field': field,
        'start_date': startDate,
        'end_date': endDate,
      };

  factory Education.fromMap(Map<String, dynamic> m) => Education(
        institution: m['institution'] as String? ?? '',
        degree: m['degree'] as String? ?? '',
        field: m['field'] as String? ?? '',
        startDate: m['start_date'] as String? ?? '',
        endDate: m['end_date'] as String? ?? '',
      );

  Education copyWith({
    String? institution,
    String? degree,
    String? field,
    String? startDate,
    String? endDate,
  }) =>
      Education(
        institution: institution ?? this.institution,
        degree: degree ?? this.degree,
        field: field ?? this.field,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );
}

class Certification {
  final String name;
  final String issuer;
  final String? dateIssued;
  final String? expiryDate;

  Certification({
    required this.name,
    required this.issuer,
    this.dateIssued,
    this.expiryDate,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'issuer': issuer,
        'date_issued': dateIssued,
        'expiry_date': expiryDate,
      };

  factory Certification.fromMap(Map<String, dynamic> m) => Certification(
        name: m['name'] as String? ?? '',
        issuer: m['issuer'] as String? ?? '',
        dateIssued: m['date_issued'] as String?,
        expiryDate: m['expiry_date'] as String?,
      );

  Certification copyWith({
    String? name,
    String? issuer,
    String? dateIssued,
    String? expiryDate,
  }) =>
      Certification(
        name: name ?? this.name,
        issuer: issuer ?? this.issuer,
        dateIssued: dateIssued ?? this.dateIssued,
        expiryDate: expiryDate ?? this.expiryDate,
      );
}

class Award {
  final String title;
  final String organization;
  final String? year;
  final String? description;

  Award({
    required this.title,
    required this.organization,
    this.year,
    this.description,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'organization': organization,
        'year': year,
        'description': description,
      };

  factory Award.fromMap(Map<String, dynamic> m) => Award(
        title: m['title'] as String? ?? '',
        organization: m['organization'] as String? ?? '',
        year: m['year'] as String?,
        description: m['description'] as String?,
      );

  Award copyWith({
    String? title,
    String? organization,
    String? year,
    String? description,
  }) =>
      Award(
        title: title ?? this.title,
        organization: organization ?? this.organization,
        year: year ?? this.year,
        description: description ?? this.description,
      );
}

class License {
  final String licenseName;
  final String licenseNumber;
  final String issueDate;
  final String expiryDate;
  final String issuingAuthority;

  const License({
    required this.licenseName,
    required this.licenseNumber,
    required this.issueDate,
    required this.expiryDate,
    this.issuingAuthority = '',
  });

  Map<String, dynamic> toMap() => {
        'license_name': licenseName,
        'license_number': licenseNumber,
        'issue_date': issueDate,
        'expiry_date': expiryDate,
        'issuing_authority': issuingAuthority,
      };

  factory License.fromMap(Map<String, dynamic> m) => License(
        licenseName: m['license_name'] as String? ?? '',
        licenseNumber: m['license_number'] as String? ?? '',
        issueDate: m['issue_date'] as String? ?? '',
        expiryDate: m['expiry_date'] as String? ?? '',
        issuingAuthority: m['issuing_authority'] as String? ?? '',
      );

  License copyWith({
    String? licenseName,
    String? licenseNumber,
    String? issueDate,
    String? expiryDate,
    String? issuingAuthority,
  }) =>
      License(
        licenseName: licenseName ?? this.licenseName,
        licenseNumber: licenseNumber ?? this.licenseNumber,
        issueDate: issueDate ?? this.issueDate,
        expiryDate: expiryDate ?? this.expiryDate,
        issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      );
}

class Language {
  final String name;
  final String proficiency; // "Native", "Fluent", "Intermediate", "Basic"

  const Language({
    required this.name,
    required this.proficiency,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'proficiency': proficiency,
      };

  factory Language.fromMap(Map<String, dynamic> m) => Language(
        name: m['name'] as String? ?? '',
        proficiency: m['proficiency'] as String? ?? 'Basic',
      );

  Language copyWith({
    String? name,
    String? proficiency,
  }) =>
      Language(
        name: name ?? this.name,
        proficiency: proficiency ?? this.proficiency,
      );
}

class ResumeModel {
  final String id;
  final String userId;
  final String title;
  final String templateId;
  final String? photoUrl;
  
  // Personal info
  final String name;
  final String email;
  final String phone;
  final String location;
  final String summary;
  final String website;
  
  // Sections
  final List<WorkExperience> workExperience;
  final List<Education> education;
  final List<Certification> certifications;
  final List<Award> awards;
  final List<Language> languages;
  final List<String> skills;
  final List<String> sectionOrder;
  final List<License> licenses;
  
  final DateTime? updatedAt;

  const ResumeModel({
    required this.id,
    required this.userId,
    this.title = 'My Resume',
    this.templateId = 'template_1',
    this.photoUrl,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.summary = '',
    this.website = '',
    this.workExperience = const [],
    this.education = const [],
    this.certifications = const [],
    this.awards = const [],
    this.languages = const [],
    this.skills = const [],
    this.sectionOrder = const ["work", "education", "certifications", "awards", "skills", "languages"],
    this.licenses = const [],
    this.updatedAt,
  });

  factory ResumeModel.fromMap(Map<String, dynamic> map) {
    final rawData = map['data'];
    final Map<String, dynamic> data = rawData is Map ? Map<String, dynamic>.from(rawData) : {};
    
    final weRaw = data['work_experience'] as List<dynamic>? ?? [];
    final eduRaw = data['education'] as List<dynamic>? ?? [];
    final certsRaw = data['certifications'] as List<dynamic>? ?? [];
    final awardsRaw = data['awards'] as List<dynamic>? ?? [];
    final langsRaw = data['languages'] as List<dynamic>? ?? [];
    final skillsRaw = data['skills'] as List<dynamic>? ?? [];
    final licensesRaw = data['licenses'] as List<dynamic>? ?? [];
    final orderRaw = data['section_order'] as List<dynamic>? ?? ["work", "education", "certifications", "awards", "skills", "languages"];

    return ResumeModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String? ?? 'My Resume',
      templateId: map['template_id'] as String? ?? 'template_1',
      photoUrl: data['photo_url'] as String?,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      location: data['location'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      website: data['website'] as String? ?? '',
      workExperience: weRaw.map((e) => WorkExperience.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
      education: eduRaw.map((e) => Education.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
      certifications: certsRaw.map((e) => Certification.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
      awards: awardsRaw.map((e) => Award.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
      languages: langsRaw.map((e) => Language.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
      skills: skillsRaw.map((e) => e as String).toList(),
      licenses: licensesRaw.map((e) => License.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
      sectionOrder: orderRaw.map((e) => e as String).toList(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'title': title,
        'template_id': templateId,
        'data': {
          'photo_url': photoUrl,
          'name': name,
          'email': email,
          'phone': phone,
          'location': location,
          'summary': summary,
          'website': website,
          'work_experience': workExperience.map((e) => e.toMap()).toList(),
          'education': education.map((e) => e.toMap()).toList(),
          'certifications': certifications.map((e) => e.toMap()).toList(),
          'awards': awards.map((e) => e.toMap()).toList(),
          'languages': languages.map((e) => e.toMap()).toList(),
          'skills': skills,
          'licenses': licenses.map((e) => e.toMap()).toList(),
          'section_order': sectionOrder,
        },
      };

  ResumeModel copyWith({
    String? title,
    String? templateId,
    String? photoUrl,
    String? name,
    String? email,
    String? phone,
    String? location,
    String? summary,
    String? website,
    List<WorkExperience>? workExperience,
    List<Education>? education,
    List<Certification>? certifications,
    List<Award>? awards,
    List<Language>? languages,
    List<String>? skills,
    List<String>? sectionOrder,
    List<License>? licenses,
  }) =>
      ResumeModel(
        id: id,
        userId: userId,
        title: title ?? this.title,
        templateId: templateId ?? this.templateId,
        photoUrl: photoUrl ?? this.photoUrl,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        summary: summary ?? this.summary,
        website: website ?? this.website,
        workExperience: workExperience ?? this.workExperience,
        education: education ?? this.education,
        certifications: certifications ?? this.certifications,
        awards: awards ?? this.awards,
        languages: languages ?? this.languages,
        skills: skills ?? this.skills,
        sectionOrder: sectionOrder ?? this.sectionOrder,
        licenses: licenses ?? this.licenses,
        updatedAt: updatedAt,
      );

  static ResumeModel empty(String userId) => ResumeModel(
        id: '',
        userId: userId,
        licenses: const [],
      );
}
