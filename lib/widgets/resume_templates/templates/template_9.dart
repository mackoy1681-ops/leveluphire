import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate9 extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate9({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595,
      padding: const EdgeInsets.all(72),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with divider
          Text(resume.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w300, letterSpacing: 2, color: Color(0xFF1A1A1A))),
          Container(height: 2, color: const Color(0xFF1A1A1A), width: 50, margin: const EdgeInsets.symmetric(vertical: 12)),
          if (resume.summary.isNotEmpty) Text(resume.summary, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
          const SizedBox(height: 20),
          
          // Two column layout (info + photo on same row)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (resume.email.isNotEmpty || resume.phone.isNotEmpty || resume.location.isNotEmpty) ...[
                      const Text('CONTACT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 8),
                      if (resume.email.isNotEmpty) Text(resume.email, style: const TextStyle(fontSize: 9, color: Color(0xFF666666))),
                      if (resume.phone.isNotEmpty) Text(resume.phone, style: const TextStyle(fontSize: 9, color: Color(0xFF666666))),
                      if (resume.location.isNotEmpty) Text(resume.location, style: const TextStyle(fontSize: 9, color: Color(0xFF666666))),
                      const SizedBox(height: 20),
                    ],
                    if (resume.skills.isNotEmpty) ...[
                      const Text('SKILLS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: resume.skills.map((s) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $s', style: const TextStyle(fontSize: 9, color: Color(0xFF666666))))).toList()),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (resume.photoUrl != null)
                      CircleAvatar(radius: 50, backgroundImage: NetworkImage(resume.photoUrl!)),
                    const SizedBox(height: 16),
                    if (resume.workExperience.isNotEmpty) ...[
                      const Text('EXPERIENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 10),
                      ...resume.workExperience.map((job) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.role, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text(job.company, style: const TextStyle(fontSize: 10, color: Color(0xFF666666))),
                            Text('${job.startDate} - ${job.endDate}', style: const TextStyle(fontSize: 8, color: Color(0xFF999999))),
                            const SizedBox(height: 4),
                            Text(job.description, style: const TextStyle(fontSize: 9, height: 1.3)),
                          ],
                        ),
                      )),
                    ],
                    if (resume.education.isNotEmpty) ...[
                      const Text('EDUCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 10),
                      ...resume.education.map((edu) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(edu.degree, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                            Text(edu.institution, style: const TextStyle(fontSize: 9, color: Color(0xFF666666))),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}