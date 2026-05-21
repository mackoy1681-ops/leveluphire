import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate7 extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate7({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595,
      color: Colors.white,
      child: Column(
        children: [
          // Dark header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(72, 32, 72, 24),
            color: const Color(0xFF1A2A3A),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 35, backgroundColor: Colors.white24, backgroundImage: resume.photoUrl != null ? NetworkImage(resume.photoUrl!) : null, child: resume.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null),
                    const SizedBox(width: 16),
                    Expanded(child: Text(resume.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400, color: Colors.white))),
                  ],
                ),
                if (resume.summary.isNotEmpty) ...[const SizedBox(height: 10), Text(resume.summary, style: const TextStyle(fontSize: 11, color: Colors.white70))],
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.email.isNotEmpty || resume.phone.isNotEmpty || resume.location.isNotEmpty)
                  Text(_buildContactLine(), style: const TextStyle(fontSize: 9, color: Color(0xFF8A9BAB))),
                const SizedBox(height: 28),
                
                if (resume.workExperience.isNotEmpty) ...[
                  const Text('WORK EXPERIENCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF1A2A3A))),
                  const SizedBox(height: 12),
                  ...resume.workExperience.map((job) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A2A3A))),
                        Text(job.company, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7B8B))),
                        Text('${job.startDate} - ${job.endDate}', style: const TextStyle(fontSize: 9, color: Color(0xFF8A9BAB))),
                        const SizedBox(height: 8),
                        Text(job.description, style: const TextStyle(fontSize: 10, height: 1.4, color: Color(0xFF4A5A6A))),
                      ],
                    ),
                  )),
                ],
                
                if (resume.education.isNotEmpty) ...[
                  const Text('EDUCATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF1A2A3A))),
                  const SizedBox(height: 12),
                  ...resume.education.map((edu) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(edu.degree, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        Text(edu.institution, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7B8B))),
                      ],
                    ),
                  )),
                ],
                
                if (resume.skills.isNotEmpty) ...[
                  const Text('SKILLS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF1A2A3A))),
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
  
  String _buildContactLine() => [resume.email, resume.phone, resume.location].where((s) => s.isNotEmpty).join('  |  ');
}