import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate10 extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate10({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595,
      padding: const EdgeInsets.all(72),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header
          Row(
            children: [
              CircleAvatar(radius: 35, backgroundColor: const Color(0xFFF0F0F0), backgroundImage: resume.photoUrl != null ? NetworkImage(resume.photoUrl!) : null, child: resume.photoUrl == null ? const Icon(Icons.person, color: Color(0xFF999999)) : null),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resume.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                  if (resume.summary.isNotEmpty) Text(resume.summary, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Contact as simple text
          if (resume.email.isNotEmpty || resume.phone.isNotEmpty || resume.location.isNotEmpty)
            Text(_buildContactLine(), style: const TextStyle(fontSize: 9, color: Color(0xFF888888))),
          const SizedBox(height: 28),
          
          // Work Experience
          if (resume.workExperience.isNotEmpty) ...[
            const Text('WORK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 12),
            ...resume.workExperience.map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                  Text(job.company, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                  Text('${job.startDate} - ${job.endDate}', style: const TextStyle(fontSize: 9, color: Color(0xFF999999))),
                  const SizedBox(height: 8),
                  Text(job.description, style: const TextStyle(fontSize: 10, height: 1.4, color: Color(0xFF444444))),
                ],
              ),
            )),
          ],
          
          // Education
          if (resume.education.isNotEmpty) ...[
            const Text('EDUCATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 12),
            ...resume.education.map((edu) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(edu.degree, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                  Text(edu.institution, style: const TextStyle(fontSize: 10, color: Color(0xFF666666))),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  String _buildContactLine() {
    final parts = <String>[];
    if (resume.email.isNotEmpty) parts.add(resume.email);
    if (resume.phone.isNotEmpty) parts.add(resume.phone);
    if (resume.location.isNotEmpty) parts.add(resume.location);
    return parts.join(' • ');
  }
}