// LevelUpHire — App Constants (LinkedIn-inspired light palette)

import 'package:flutter/material.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────

const Color kBackground    = Color(0xFFF3F2EF);
const Color kSurface       = Color(0xFFFFFFFF);
const Color kPrimaryText   = Color(0xFF191919);
const Color kSecondaryText = Color(0xFF666666);
const Color kAccentBlue    = Color(0xFF0A66C2);
const Color kBorderColor   = Color(0xFFD9DDE3);
const Color kError         = Color(0xFFC62828);
const Color kSuccess       = Color(0xFF057642);
const Color kOverlay       = Color(0xFFE8F3FF);

// ─── Typography ──────────────────────────────────────────────────────────────

const double kFontBase      = 15.0;
const double kFontSmall     = 13.0;
const double kFontTiny      = 11.0;
const double kFontLabel     = 10.0;
const double kFontHeading   = 20.0;
const double kFontTitle     = 18.0;

// ─── Spacing ─────────────────────────────────────────────────────────────────

const double kPadS  = 8.0;
const double kPadM  = 12.0;
const double kPadL  = 16.0;
const double kPadXL = 24.0;

// ─── Border Radius ───────────────────────────────────────────────────────────

const double kRadiusCard   = 16.0;
const double kRadiusPill   = 9999.0;
const double kRadiusInput  = 8.0;

// ─── Nav ─────────────────────────────────────────────────────────────────────

/// Height of the floating bottom nav bar pill
const double kNavHeight    = 70.0;

// ─── Routes ──────────────────────────────────────────────────────────────────

const String kRouteSplash       = '/';
const String kRouteLogin        = '/login';
const String kRouteSignup       = '/signup';
const String kRouteProfileSetup = '/profile-setup';
const String kRouteHome         = '/home';
const String kRouteProfile      = '/profile';
const String kRouteEditProfile  = '/edit-profile';
const String kRoutePublicProfile = '/public-profile';
const String kRouteResume       = '/resume';
const String kRouteResumeEditor = '/resume-editor';
const String kRouteAssessment   = '/assessment';
const String kRouteInterview    = '/interview';
const String kRouteDiscussHub   = '/discuss';

// Discuss deep links
const String kRouteCreateThread = '/discuss/create';
const String kRouteThreadPrefix = '/discuss/thread'; // final URL: /discuss/thread/<id>

// Assessment sub-routes (helps mobile Chrome back-swipe use in-app history)
const String kRouteAbstractTest    = '/assessment/abstract';
const String kRouteNumericalTest   = '/assessment/numerical';
const String kRouteVerbalTest      = '/assessment/verbal';
const String kRoutePersonalityTest = '/assessment/personality';
const String kRouteIntegrityTest   = '/assessment/integrity';
const String kRouteEssaySetup      = '/assessment/essay';
const String kRouteEnglishExam     = '/assessment/english';
const String kRouteCivilService    = '/assessment/civil-service';

// ─── Assets ──────────────────────────────────────────────────────────────────

const String kLogoPath = 'assets/images/logof.png';
