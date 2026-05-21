import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate3 extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate3({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2C6E9E);
    return Container(
      width: 595,
      padding: const EdgeInsets.all(72),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Container(height: 4, color: accent, width: double.infinity),
          const SizedBox(height: 20),
          
          // Header with photo
          Row(
            children: [
              CircleAvatar(radius: 35, backgroundImage: resume.photoUrl != null ? NetworkImage(resume.photoUrl!) : null, child: resume.photoUrl == null ? const Icon(Icons.person) : null),
              const SizedBox(width: 16),
              Expanded(child: Text(resume.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400, color: Color(0xFF1A2A3A)))),
            ],
          ),
          if (resume.summary.isNotEmpty) ...[const SizedBox(height: 8), Text(resume.summary, style: const TextStyle(fontSize: 11, color: Color(0xFF666666)))],
          const SizedBox(height: 20),
          
          // Contact
          if (resume.email.isNotEmpty || resume.phone.isNotEmpty || resume.location.isNotEmpty)
            Wrap(spacing: 20, children: [
              if (resume.email.isNotEmpty) _contactItem(Icons.email, resume.email, accent),
              if (resume.phone.isNotEmpty) _contactItem(Icons.phone, resume.phone, accent),
              if (resume.location.isNotEmpty) _contactItem(Icons.location_on, resume.location, accent),
            ]),
          const SizedBox(height: 24),
          
          // Work Experience
          if (resume.workExperience.isNotEmpty) ...[
            _sectionHeader('WORK EXPERIENCE', accent),
            const SizedBox(height: 12),
            ...resume.workExperience.map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(job.company, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                  Text('${job.startDate} - ${job.endDate}', style: const TextStyle(fontSize: 9, color: Color(0xFF999999))),
                  const SizedBox(height: 6),
                  Text(job.description, style: const TextStyle(fontSize: 10, height: 1.4)),
                ],
              ),
            )),
          ],
          
          // Education
          if (resume.education.isNotEmpty) ...[
            _sectionHeader('EDUCATION', accent),
            const SizedBox(height: 12),
            ...resume.education.map((edu) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(edu.degree, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(edu.institution, style: const TextStyle(fontSize: 10, color: Color(0xFF666666))),
                ],
              ),
            )),
          ],
          
          // Skills
          if (resume.skills.isNotEmpty) ...[
            _sectionHeader('SKILLS', accent),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: resume.skills.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(s, style: TextStyle(fontSize: 9, color: accent)))).toList()),
          ],
        ],
      ),
    );
  }
  
  Widget _sectionHeader(String title, Color accent) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: accent)), const SizedBox(height: 4), Container(height: 1, color: accent.withOpacity(0.3), width: 40)]);
  Widget _contactItem(IconData icon, String text, Color accent) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: accent), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 9, color: Color(0xFF666666)))]);
}