import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../models/assessment_model.dart';
import '../models/interview_model.dart';
import '../models/resume_model.dart';
import '../models/notification_model.dart';

class SupabaseService {
  /// Do not annotate with `SupabaseQueryBuilder` — Dart Web (dartdevc) can hit
  /// InvalidType compile errors when that type is surfaced through this helper.
  static dynamic _table(String table) => Supabase.instance.client.from(table);

  // ─── Profile ─────────────────────────────────────────────────────────────

  static Future<UserModel?> getUserProfile(String userId) async {
    final data = await _table('profiles').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return UserModel.fromMap(data);
  }

  static Future<void> upsertUserProfile(UserModel user) async {
    await commitUserProfile(user);
  }

  /// Writes only editable profile columns (avoids 400s if DB is missing stats columns).
  /// Prefer UPDATE (row from auth trigger); INSERT if no row exists yet.
  static Future<Map<String, dynamic>> commitUserProfile(UserModel user) async {
    final client = Supabase.instance.client;
    final write = {
      'display_name': user.displayName,
      'username': user.username,
      'bio': user.bio,
      'location': user.location,
      'website': user.website,
      'avatar_url': user.avatarUrl,
      'is_profile_complete': user.isProfileComplete,
    };

    final afterUpdate =
        await client.from('profiles').update(write).eq('id', user.id).select().maybeSingle();
    if (afterUpdate != null) {
      return Map<String, dynamic>.from(afterUpdate);
    }

    final afterInsert = await client
        .from('profiles')
        .insert({'id': user.id, ...write})
        .select()
        .maybeSingle();
    if (afterInsert == null) {
      throw Exception(
        'Could not save profile (no row returned). Check RLS INSERT on public.profiles.',
      );
    }
    return Map<String, dynamic>.from(afterInsert);
  }

  // ─── Resumes ─────────────────────────────────────────────────────────────

  static Future<List<ResumeModel>> getResumes(String userId) async {
    final data = await _table('resumes')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return (data as List<dynamic>)
        .map((e) => ResumeModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (resume.id.isEmpty) {
      final data = await _table('resumes').insert(resume.toMap()).select().single();
      return ResumeModel.fromMap(data);
    } else {
      await _table('resumes').update(resume.toMap()).eq('id', resume.id);
      return resume;
    }
  }

  static Future<void> deleteResume(String resumeId) async {
    await _table('resumes').delete().eq('id', resumeId);
  }

  // ─── Assessment Results ───────────────────────────────────────────────────

  static Future<void> saveAssessmentResult(AssessmentResult result) async {
    await _table('assessment_results').insert(result.toMap());
  }

  static Future<List<AssessmentResult>> getAssessmentHistory(String userId) async {
    final data = await _table('assessment_results')
        .select()
        .eq('user_id', userId)
        .order('taken_at', ascending: false)
        .limit(20);
    return (data as List<dynamic>)
        .map((e) => AssessmentResult.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Interview Sessions ───────────────────────────────────────────────────

  static Future<void> saveInterviewSession(InterviewSession session) async {
    if (session.id.isEmpty) {
      await _table('interview_sessions').insert(session.toMap());
    } else {
      await _table('interview_sessions').update(session.toMap()).eq('id', session.id);
    }
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  static Future<List<NotificationModel>> getNotifications(String userId) async {
    final data = await _table('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List<dynamic>)
        .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> markAllNotificationsRead(String userId) async {
    await _table('notifications').update({'is_read': true}).eq('user_id', userId);
  }

  // ─── Stats ────────────────────────────────────────────────────────────────

  static Future<Map<String, int>> getUserStats(String userId) async {
    final a = await _table('assessment_results').select('id').eq('user_id', userId);
    final i = await _table('interview_sessions').select('id').eq('user_id', userId);
    final r = await _table('resumes').select('id').eq('user_id', userId);
    return {
      'assessments_taken': (a as List).length,
      'interviews_completed': (i as List).length,
      'resumes_created': (r as List).length,
    };
  }
}
