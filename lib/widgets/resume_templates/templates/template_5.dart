import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate5 extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate5({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595,
      padding: const EdgeInsets.all(72),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left border accent
          Container(width: 4, color: const Color(0xFFC0392B)),
          const SizedBox(width: 24),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(radius: 35, backgroundImage: resume.photoUrl != null ? NetworkImage(resume.photoUrl!) : null, child: resume.photoUrl == null ? const Icon(Icons.person) : null),
                    const SizedBox(width: 16),
                    Expanded(child: Text(resume.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400))),
                  ],
                ),
                if (resume.summary.isNotEmpty) ...[const SizedBox(height: 8), Text(resume.summary, style: const TextStyle(fontSize: 11, color: Color(0xFF666666)))],
                const SizedBox(height: 20),
                
                // Contact
                if (resume.email.isNotEmpty || resume.phone.isNotEmpty || resume.location.isNotEmpty)
                  Text(_buildContactLine(), style: const TextStyle(fontSize: 9, color: Color(0xFF999999))),
                const SizedBox(height: 28),
                
                // Work Experience
                if (resume.workExperience.isNotEmpty) ...[
                  _sectionHeader('WORK EXPERIENCE'),
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
                  _sectionHeader('EDUCATION'),
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
                  _sectionHeader('SKILLS'),
                  const SizedBox(height: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: resume.skills.map((s) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $s', style: const TextStyle(fontSize: 10)))).toList()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _sectionHeader(String title) => Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFFC0392B)));
  String _buildContactLine() => [resume.email, resume.phone, resume.location].where((s) => s.isNotEmpty).join('  |  ');
}