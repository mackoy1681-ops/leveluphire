import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _icons = [
    Icons.home_rounded,
    Icons.description_rounded,
    Icons.assignment_rounded,
    Icons.mic_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Resume', 'Assess', 'Interview', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 20,
      child: Container(
        height: kNavHeight,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: kBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_icons.length, (i) {
            final isActive = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? kAccentBlue.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(kRadiusPill),
                          ),
                          child: Icon(
                            _icons[i],
                            color: isActive ? kAccentBlue : kSecondaryText,
                            size: isActive ? 24 : 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            color: isActive ? kAccentBlue : kSecondaryText,
                            fontSize: kFontLabel,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
