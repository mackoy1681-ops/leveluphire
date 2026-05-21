import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate11 extends StatelessWidget {
  final ResumeModel resume;

  const ResumeTemplate11({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thin colored top bar
          Container(
            width: 595,
            height: 4,
            color: const Color(0xFF2C3E50),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  resume.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                // Contact info
                _buildContactInfo(),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 16),
                // Profile/Summary
                if (resume.summary.isNotEmpty) ...[
                  _buildSectionTitle('PROFILE'),
                  const SizedBox(height: 8),
                  Text(
                    resume.summary,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                ],
                // Work Experience
                if (resume.workExperience.isNotEmpty) ...[
                  _buildSectionTitle('WORK EXPERIENCE'),
                  const SizedBox(height: 10),
                  ...resume.workExperience.map((job) => _buildWorkItem(job)),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                ],
                // Education
                if (resume.education.isNotEmpty) ...[
                  _buildSectionTitle('EDUCATION'),
                  const SizedBox(height: 10),
                  ...resume.education.map((edu) => _buildEducationItem(edu)),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                ],
                // Certifications
                if (resume.certifications.isNotEmpty) ...[
                  _buildSectionTitle('CERTIFICATIONS'),
                  const SizedBox(height: 10),
                  ...resume.certifications.map((cert) => _buildCertificationItem(cert)),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                ],
                // Licenses
                if (resume.licenses.isNotEmpty) ...[
                  _buildSectionTitle('LICENSES'),
                  const SizedBox(height: 10),
                  ...resume.licenses.map((license) => _buildLicenseItem(license)),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                ],
                // Awards
                if (resume.awards.isNotEmpty) ...[
                  _buildSectionTitle('AWARDS'),
                  const SizedBox(height: 10),
                  ...resume.awards.map((award) => _buildAwardItem(award)),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                ],
                // Skills
                if (resume.skills.isNotEmpty) ...[
                  _buildSectionTitle('SKILLS'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: resume.skills
                        .map((skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                ],
                // Languages
                if (resume.languages.isNotEmpty) ...[
                  _buildSectionTitle('LANGUAGES'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: resume.languages
                        .map((lang) => Text(
                              '${lang.name} (${lang.proficiency})',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF333333),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    final List<String> contacts = [];
    if (resume.email.isNotEmpty) contacts.add(resume.email);
    if (resume.phone.isNotEmpty) contacts.add(resume.phone);
    if (resume.location.isNotEmpty) contacts.add(resume.location);
    if (resume.website.isNotEmpty) contacts.add(resume.website);

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: contacts.map((contact) => Text(
        contact,
        style: const TextStyle(
          fontSize: 9,
          color: Color(0xFF666666),
        ),
      )).toList(),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 40,
      height: 1,
      color: const Color(0xFFCCCCCC),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildWorkItem(WorkExperience job) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.role,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                '${job.startDate} - ${job.endDate}',
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            job.company,
            style: const TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: Color(0xFF666666),
            ),
          ),
          if (job.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              job.description,
              style: const TextStyle(
                fontSize: 9,
                height: 1.4,
                color: Color(0xFF444444),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationItem(Education edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${edu.degree} in ${edu.field}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                '${edu.startDate} - ${edu.endDate}',
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            edu.institution,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationItem(Certification cert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cert.name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          Text(
            cert.issuer,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF666666),
            ),
          ),
          if (cert.dateIssued != null && cert.dateIssued!.isNotEmpty)
            Text(
              'Issued: ${cert.dateIssued}',
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF999999),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLicenseItem(License license) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            license.licenseName,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          Text(
            license.issuingAuthority,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF666666),
            ),
          ),
          if (license.issueDate.isNotEmpty)
            Text(
              'License No: ${license.licenseNumber} • Issued: ${license.issueDate}',
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF999999),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAwardItem(Award award) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                award.title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              if (award.year != null && award.year!.isNotEmpty)
                Text(
                  award.year!,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF999999),
                  ),
                ),
            ],
          ),
          Text(
            award.organization,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF666666),
            ),
          ),
          if (award.description != null && award.description!.isNotEmpty)
            Text(
              award.description!,
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF777777),
              ),
            ),
        ],
      ),
    );
  }
}