import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate1 extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate1({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Photo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    color: const Color(0xFF2D2D44),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: resume.photoUrl != null && resume.photoUrl!.isNotEmpty
                      ? Image.network(
                          resume.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            color: Colors.white54,
                            size: 40,
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white54, size: 40),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (resume.name.isNotEmpty)
                        Text(
                          resume.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      if (resume.summary.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          resume.summary,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFBBBBCC),
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Contact row
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (resume.email.isNotEmpty)
                            _contactItem(Icons.email_outlined, resume.email),
                          if (resume.phone.isNotEmpty)
                            _contactItem(Icons.phone_outlined, resume.phone),
                          if (resume.location.isNotEmpty)
                            _contactItem(Icons.location_on_outlined, resume.location),
                          if (resume.website.isNotEmpty)
                            _contactItem(Icons.link, resume.website),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Work Experience
                if (resume.workExperience.isNotEmpty) ...[
                  _sectionTitle('Work Experience'),
                  ...resume.workExperience.map((job) => _workItem(job)),
                  const SizedBox(height: 8),
                ],

                // Education
                if (resume.education.isNotEmpty) ...[
                  _sectionTitle('Education'),
                  ...resume.education.map((edu) => _eduItem(edu)),
                  const SizedBox(height: 8),
                ],

                // Licenses
                if (resume.licenses.isNotEmpty) ...[
                  _sectionTitle('Professional Licenses'),
                  ...resume.licenses.map((lic) => _licenseItem(lic)),
                  const SizedBox(height: 8),
                ],

                // Certifications
                if (resume.certifications.isNotEmpty) ...[
                  _sectionTitle('Certifications'),
                  ...resume.certifications.map((cert) => _certItem(cert)),
                  const SizedBox(height: 8),
                ],

                // Awards
                if (resume.awards.isNotEmpty) ...[
                  _sectionTitle('Awards & Achievements'),
                  ...resume.awards.map((award) => _awardItem(award)),
                  const SizedBox(height: 8),
                ],

                // Skills
                if (resume.skills.isNotEmpty) ...[
                  _sectionTitle('Skills'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: resume.skills
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F5),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFDDDDEE)),
                              ),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFF333355))),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],

                // Languages
                if (resume.languages.isNotEmpty) ...[
                  _sectionTitle('Languages'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: resume.languages
                        .map((lang) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.circle,
                                    size: 6, color: Color(0xFF1A1A2E)),
                                const SizedBox(width: 5),
                                Text(
                                  '${lang.name}  ',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A)),
                                ),
                                Text(
                                  lang.proficiency,
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFF666666)),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section helpers ───────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            letterSpacing: 1.2,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          height: 1.5,
          color: const Color(0xFF1A1A2E),
        ),
      ],
    );
  }

  Widget _contactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFFBBBBCC)),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 10, color: Color(0xFFCCCCDD))),
      ],
    );
  }

  Widget _workItem(WorkExperience job) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job.role,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
              ),
              if (job.startDate.isNotEmpty || job.endDate.isNotEmpty)
                Text(
                  '${job.startDate}${job.endDate.isNotEmpty ? ' – ${job.endDate}' : ''}',
                  style: const TextStyle(
                      fontSize: 9, color: Color(0xFF888888)),
                ),
            ],
          ),
          if (job.company.isNotEmpty)
            Text(job.company,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF555566),
                    fontStyle: FontStyle.italic)),
          if (job.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(job.description,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF444444), height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _eduItem(Education edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  edu.degree,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
              ),
              if (edu.startDate.isNotEmpty || edu.endDate.isNotEmpty)
                Text(
                  '${edu.startDate}${edu.endDate.isNotEmpty ? ' – ${edu.endDate}' : ''}',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF888888)),
                ),
            ],
          ),
          if (edu.institution.isNotEmpty)
            Text(edu.institution,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF555566),
                    fontStyle: FontStyle.italic)),
          if (edu.field.isNotEmpty)
            Text(edu.field,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF666666))),
        ],
      ),
    );
  }

  Widget _certItem(Certification cert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.verified_outlined, size: 12, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert.name,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
                Text(
                  [
                    if (cert.issuer.isNotEmpty) cert.issuer,
                    if (cert.dateIssued != null && cert.dateIssued!.isNotEmpty)
                      cert.dateIssued!,
                  ].join(' · '),
                  style: const TextStyle(
                      fontSize: 9, color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _licenseItem(License lic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.badge_outlined, size: 12, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lic.licenseName,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
                Text(
                  [
                    if (lic.issuingAuthority.isNotEmpty) lic.issuingAuthority,
                    if (lic.licenseNumber.isNotEmpty) 'No. ${lic.licenseNumber}',
                    if (lic.issueDate.isNotEmpty) lic.issueDate,
                  ].join(' · '),
                  style: const TextStyle(fontSize: 9, color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _awardItem(Award award) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.emoji_events_outlined,
                size: 12, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(award.title,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
                Text(
                  [
                    if (award.organization.isNotEmpty) award.organization,
                    if (award.year != null && award.year!.isNotEmpty) award.year!,
                  ].join(' · '),
                  style: const TextStyle(fontSize: 9, color: Color(0xFF777777)),
                ),
                if (award.description != null &&
                    award.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(award.description!,
                      style: const TextStyle(
                          fontSize: 9, color: Color(0xFF555555), height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}