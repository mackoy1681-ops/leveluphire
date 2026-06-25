import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/constants.dart';
import '../models/route_args.dart';

class InterviewIncoming extends StatefulWidget {
  final String profession;
  final bool isFemale;
  final String imageFileName;

  const InterviewIncoming({
    super.key,
    required this.profession,
    required this.isFemale,
    required this.imageFileName,
  });

  @override
  State<InterviewIncoming> createState() => _InterviewIncomingState();
}

class _InterviewIncomingState extends State<InterviewIncoming> {
  late AudioPlayer _audioPlayer;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playRingtone();
  }

  Future<void> _playRingtone() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sound/ring.wav'));
    } catch (e) {
      print('Ring sound error: $e');
      // Silently fail - app still works
    }
  }

  Future<void> _stopRingtone() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Stop ring error: $e');
    }
  }

  void _answerCall() async {
    if (_isAnswered) return;
    setState(() => _isAnswered = true);
    await _stopRingtone();
    
    if (mounted) {
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        kRouteInterviewSession,
        arguments: InterviewSessionArgs(
          profession: widget.profession,
          isFemale: widget.isFemale,
          imageFileName: widget.imageFileName,
        ),
      );
    }
  }

  void _declineCall() async {
    if (_isAnswered) return;
    setState(() => _isAnswered = true);
    await _stopRingtone();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(color: kAccentBlue.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kAccentBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
              child: const Text(
                'INCOMING CALL',
                style: TextStyle(
                  color: kAccentBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kAccentBlue, width: 2),
                image: DecorationImage(
                  image: AssetImage('assets/interviewer/${widget.imageFileName}'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'AI Interviewer',
              style: TextStyle(
                color: kPrimaryText,
                fontSize: kFontTitle,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kAccentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: kAccentBlue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: kAccentBlue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _declineCall,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: kError.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: kError, width: 2),
                    ),
                    child: const Icon(
                      Icons.call_end,
                      size: 32,
                      color: kError,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _answerCall,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: kSuccess.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: kSuccess, width: 2),
                    ),
                    child: const Icon(
                      Icons.call,
                      size: 32,
                      color: kSuccess,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}