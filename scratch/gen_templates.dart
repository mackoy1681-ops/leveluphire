import 'dart:io';

void main() {
  final dir = Directory('C:/Users/ebetd/leveluphire/lib/widgets/resume_templates/templates');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  for (var i = 6; i <= 40; i++) {
    final file = File('${dir.path}/template_$i.dart');
    final content = '''
import 'package:flutter/material.dart';
import '../../../models/resume_model.dart';

class ResumeTemplate$i extends StatelessWidget {
  final ResumeModel resume;
  const ResumeTemplate$i({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Template $i', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            const Text('Design coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
''';
    file.writeAsStringSync(content);
  }
  print('Generated templates 6-40');
}
