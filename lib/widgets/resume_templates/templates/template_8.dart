import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate8 extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate8({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFD35400);
    return Container(
      width: 595,
      padding: const EdgeInsets.all(72),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo centered above name (still left align content)
          Center(
            child: CircleAvatar(radius: 45, backgroundImage: resume.photoUrl != null ? NetworkImage(resume.photoUrl!) : null, child: resume.photoUrl == null ? const Icon(Icons.person, size: 45) : null),
          ),
          const SizedBox(height: 16),
          Center(child: Text(resume.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: Color(0xFF2C3E50)))),
          const SizedBox(height: 8),
          if (resume.summary.isNotEmpty) Center(child: Text(resume.summary, style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D)))),
          const SizedBox(height: 20),
          Container(height: 1, color: accent),
          const SizedBox(height: 20),
          
          // Contact
          if (resume.email.isNotEmpty || resume.phone.isNotEmpty || resume.location.isNotEmpty)
            Center(child: Text(_buildContactLine(), style: const TextStyle(fontSize: 9, color: Color(0xFF95A5A6)))),
          const SizedBox(height: 28),
          
          // Work Experience
          if (resume.workExperience.isNotEmpty) ...[
            _sectionHeader('WORK EXPERIENCE', accent),
            const SizedBox(height: 12),
            ...resume.workExperience.map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.role, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                  Text(job.company, style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D))),
                  Text('${job.startDate} - ${job.endDate}', style: const TextStyle(fontSize: 10, color: Color(0xFFBDC3C7))),
                  const SizedBox(height: 8),
                  Text(job.description, style: const TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF34495E))),
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
                  Text(edu.degree, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF2C3E50))),
                  Text(edu.institution, style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D))),
                ],
              ),
            )),
          ],
          
          // Skills with accent background
          if (resume.skills.isNotEmpty) ...[
            _sectionHeader('SKILLS', accent),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 6, children: resume.skills.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4)), child: Text(s, style: const TextStyle(fontSize: 9, color: Colors.white)))).toList()),
          ],
        ],
      ),
    );
  }
  
  Widget _sectionHeader(String title, Color accent) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: accent)), const SizedBox(height: 6), Container(height: 2, color: accent, width: 40)]);
  String _buildContactLine() => [resume.email, resume.phone, resume.location].where((s) => s.isNotEmpty).join('  |  ');
}