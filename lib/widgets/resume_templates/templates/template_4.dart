import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate4 extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate4({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595,
      padding: const EdgeInsets.all(72),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered name (but content left aligned)
          Center(child: Text(resume.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400, fontFamily: 'Georgia', color: Color(0xFF3D2B1F)))),
          const SizedBox(height: 8),
          if (resume.summary.isNotEmpty) Center(child: Text(resume.summary, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF8B7355), fontFamily: 'Georgia'))),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFD4C5B0)),
          const SizedBox(height: 20),
          
          // Contact
          if (resume.email.isNotEmpty || resume.phone.isNotEmpty || resume.location.isNotEmpty)
            Center(child: Text(_buildContactLine(), style: const TextStyle(fontSize: 9, color: Color(0xFF8B7355), fontFamily: 'Georgia'))),
          const SizedBox(height: 28),
          
          // Work Experience
          if (resume.workExperience.isNotEmpty) ...[
            _sectionHeader('Experience'),
            const SizedBox(height: 12),
            ...resume.workExperience.map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Georgia', color: Color(0xFF3D2B1F))),
                  Text(job.company, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF8B7355), fontFamily: 'Georgia')),
                  Text('${job.startDate} - ${job.endDate}', style: const TextStyle(fontSize: 9, color: Color(0xFFB8A99A), fontFamily: 'Georgia')),
                  const SizedBox(height: 8),
                  Text(job.description, style: const TextStyle(fontSize: 10, height: 1.4, color: Color(0xFF4A3B2C), fontFamily: 'Georgia')),
                ],
              ),
            )),
          ],
          
          // Education
          if (resume.education.isNotEmpty) ...[
            _sectionHeader('Education'),
            const SizedBox(height: 12),
            ...resume.education.map((edu) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(edu.degree, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Georgia')),
                  Text(edu.institution, style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF8B7355), fontFamily: 'Georgia')),
                ],
              ),
            )),
          ],
          
          // Skills
          if (resume.skills.isNotEmpty) ...[
            _sectionHeader('Skills'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: resume.skills.map((s) => Text('• $s', style: const TextStyle(fontSize: 10, fontFamily: 'Georgia'))).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _sectionHeader(String title) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFF3D2B1F), fontFamily: 'Georgia')), const SizedBox(height: 6), Container(height: 0.5, color: const Color(0xFFD4C5B0), width: 30)]);
  String _buildContactLine() => [resume.email, resume.phone, resume.location].where((s) => s.isNotEmpty).join('  |  ');
}