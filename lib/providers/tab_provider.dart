import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tab indices for MainWrapperScreen
/// 0 = Home, 1 = Resume, 2 = Assessment, 3 = Interview, 4 = Profile
final mainTabIndexProvider = StateProvider<int>((ref) => 0);
