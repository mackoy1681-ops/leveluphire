import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate2 extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate2({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595,
      padding: const EdgeInsets.all(72),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name only (no photo in header)
          Text(resume.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, letterSpacing: 1, color: Color(0xFF2C3E50))),
          const SizedBox(height: 10),
          if (resume.summary.isNotEmpty) Text(resume.summary, style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D))),
          const SizedBox(height: 20),
          const Divider(thickness: 0.5),
          const SizedBox(height: 20),
          
          // Contact in line
          if (resume.email.isNotEmpty || resume.phone.isNotEmpty || resume.location.isNotEmpty)
            Text(_buildContactLine(), style: const TextStyle(fontSize: 9, color: Color(0xFF95A5A6))),
          const SizedBox(height: 28),
          
          // Work Experience
          if (resume.workExperience.isNotEmpty) ...[
            const Text('Experience', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF2C3E50))),
            const SizedBox(height: 12),
            ...resume.workExperience.map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.role, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(job.company, style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D))),
                  Text('${job.startDate} — ${job.endDate}', style: const TextStyle(fontSize: 9, color: Color(0xFFBDC3C7))),
                  const SizedBox(height: 8),
                  Text(job.description, style: const TextStyle(fontSize: 10, height: 1.4, color: Color(0xFF34495E))),
                ],
              ),
            )),
          ],
          
          // Education
          if (resume.education.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Education', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF2C3E50))),
            const SizedBox(height: 12),
            ...resume.education.map((edu) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(edu.degree, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(edu.institution, style: const TextStyle(fontSize: 10, color: Color(0xFF7F8C8D))),
                ],
              ),
            )),
          ],
          
          // Skills
          if (resume.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Skills', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF2C3E50))),
            const SizedBox(height: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: resume.skills.map((s) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $s', style: const TextStyle(fontSize: 10)))).toList()),
          ],
        ],
      ),
    );
  }
  
  String _buildContactLine() {
    List<String> parts = [];
    if (resume.email.isNotEmpty) parts.add(resume.email);
    if (resume.phone.isNotEmpty) parts.add(resume.phone);
    if (resume.location.isNotEmpty) parts.add(resume.location);
    return parts.join('  |  ');
  }
}