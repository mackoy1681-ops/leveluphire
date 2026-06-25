import 'package:flutter/material.dart';
import 'constants.dart';

/// Consistent back navigation for web and native.
/// Replaces legacy tab-switch fallbacks from the removed bottom nav wrapper.
void popOrHome(BuildContext context) {
  final nav = Navigator.of(context);
  if (nav.canPop()) {
    nav.pop();
  } else {
    nav.pushReplacementNamed(kRouteHome);
  }
}
