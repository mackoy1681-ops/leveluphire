import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/tab_provider.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  List<Map<String, dynamic>> _awards = [];
  List<Map<String, dynamic>> _interviewResults = [];
  List<Map<String, dynamic>> _essayResults = [];
  List<Map<String, dynamic>> _civilServiceResults = [];
  List<Map<String, dynamic>> _englishResults = [];
  Map<String, String> _insights = {};
  bool _isLoading = true;

  // Award settings
  bool _showAwardScores = true;
  Map<String, bool> _awardScoreVisibility = {};

  // Insight order
  List<String> _insightOrder = [
    'essay',
    'professional',
    'interview',
    'personality',
    'integrity',
    'civil_service',
    'english'
  ];

  // Toggle states for insights
  bool _showEssay = true;
  bool _showProfessionalExam = true;
  bool _showInterviewPractice = true;
  bool _showPersonality = true;
  bool _showIntegrity = true;
  bool _showCivilService = true;
  bool _showEnglish = true;

  final List<Map<String, dynamic>> _awardConfig = [
    {'icon': 1, 'testName': 'Abstract Reasoning', 'displayName': 'Abstract', 'type': 'score'},
    {'icon': 2, 'testName': 'Numerical Reasoning', 'displayName': 'Numerical', 'type': 'score'},
    {'icon': 3, 'testName': 'Verbal Reasoning', 'displayName': 'Verbal', 'type': 'score'},
    {'icon': 4, 'testName': 'Behavioral', 'displayName': 'Behavioral', 'type': 'taken'},
    {'icon': 5, 'testName': 'Integrity', 'displayName': 'Integrity', 'type': 'taken'},
    {'icon': 6, 'testName': 'Professional Exam', 'displayName': 'Professional', 'type': 'score'},
    {'icon': 7, 'testName': 'Interview Practice', 'displayName': 'Interview', 'type': 'taken'},
    {'icon': 8, 'testName': 'Essay Writing', 'displayName': 'Essay', 'type': 'score'},
    {'icon': 9, 'testName': 'Civil Service Exam', 'displayName': 'Civil Service', 'type': 'score'},
    {'icon': 10, 'testName': 'English Proficiency', 'displayName': 'English', 'type': 'score'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAwardSettings();
    _loadInsightOrder();
  }

  void _loadAwardSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showAwardScores = prefs.getBool('show_award_scores') ?? true;
    });
    
    for (var award in _awardConfig) {
      final key = 'award_score_visible_${award['testName']}';
      _awardScoreVisibility[award['testName']] = prefs.getBool(key) ?? true;
    }
  }

  Future<void> _saveAwardSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_award_scores', _showAwardScores);
    for (var entry in _awardScoreVisibility.entries) {
      await prefs.setBool('award_score_visible_${entry.key}', entry.value);
    }
  }

  void _showAwardSettingsDialog() {
    final earnedAwards = _getEarnedAwardsWithDetails();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: kSurface,
            title: const Text(
              'Award Settings',
              style: TextStyle(color: kPrimaryText),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Show all scores',
                        style: TextStyle(color: kPrimaryText),
                      ),
                      Switch(
                        value: _showAwardScores,
                        onChanged: (val) {
                          setDialogState(() {
                            _showAwardScores = val;
                            for (var award in earnedAwards) {
                              _awardScoreVisibility[award['testName']] = val;
                            }
                          });
                          _saveAwardSettings();
                        },
                        activeColor: kAccentBlue,
                      ),
                    ],
                  ),
                  const Divider(color: kBorderColor),
                  const SizedBox(height: 8),
                  const Text(
                    'Individual Award Scores',
                    style: TextStyle(color: kSecondaryText, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...earnedAwards.map((award) {
                    final testName = award['testName'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            award['displayName'],
                            style: const TextStyle(color: kPrimaryText),
                          ),
                          Switch(
                            value: _awardScoreVisibility[testName] ?? true,
                            onChanged: (val) {
                              setDialogState(() {
                                _awardScoreVisibility[testName] = val;
                              });
                              _saveAwardSettings();
                            },
                            activeColor: kAccentBlue,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: kAccentBlue)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final awardsResponse = await Supabase.instance.client
          .from('user_awards')
          .select()
          .eq('user_id', user.id);

      final insightsResponse = await Supabase.instance.client
          .from('user_assessments')
          .select()
          .eq('user_id', user.id);

      final interviewResponse = await Supabase.instance.client
          .from('interview_results')
          .select()
          .eq('user_id', user.id)
          .order('taken_at', ascending: false);

      final essayResponse = await Supabase.instance.client
          .from('essay_results')
          .select()
          .eq('user_id', user.id)
          .order('taken_at', ascending: false);

      final civilServiceResponse = await Supabase.instance.client
          .from('civil_service_results')
          .select()
          .eq('user_id', user.id)
          .order('taken_at', ascending: false);

      final englishResponse = await Supabase.instance.client
          .from('english_results')
          .select()
          .eq('user_id', user.id)
          .order('taken_at', ascending: false);

      if (mounted) {
        setState(() {
          _awards = List<Map<String, dynamic>>.from(awardsResponse);
          _interviewResults = List<Map<String, dynamic>>.from(interviewResponse);
          _essayResults = List<Map<String, dynamic>>.from(essayResponse);
          _civilServiceResults = List<Map<String, dynamic>>.from(civilServiceResponse);
          _englishResults = List<Map<String, dynamic>>.from(englishResponse);
          for (var insight in insightsResponse) {
            _insights[insight['assessment_type']] = insight['result_summary'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _getAwardValue(String testName) {
    final award = _awards.firstWhere(
      (a) => a['test_name'] == testName,
      orElse: () => {},
    );
    if (award.isEmpty) return null;
    
    final config = _awardConfig.firstWhere(
      (c) => c['testName'] == testName,
      orElse: () => {},
    );
    
    if (config['type'] == 'taken') {
      return 'Taken';
    }
    
    if (award['percentage'] != null) {
      final percentage = award['percentage'] as int;
      if (percentage >= 76) {
        final showScore = _awardScoreVisibility[testName] ?? true;
        if (showScore && _showAwardScores) {
          return '$percentage%';
        }
        return 'Earned';
      }
    }
    
    return null;
  }

  bool _isAwardEarned(String testName) {
    return _getAwardValue(testName) != null;
  }

  List<Map<String, dynamic>> _getEarnedAwardsWithDetails() {
    return _awardConfig.where((award) => _isAwardEarned(award['testName'])).toList();
  }

  List<Map<String, dynamic>> _getEarnedAwards() {
    return _getEarnedAwardsWithDetails();
  }

  Widget _buildInsightCard({
    required String id,
    required String title,
    required Widget content,
    required bool isVisible,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    return Card(
      key: ValueKey(id),
      margin: const EdgeInsets.only(bottom: 12),
      color: kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusCard),
        side: const BorderSide(color: kBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.drag_handle, color: kSecondaryText, size: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: kAccentBlue,
                      fontSize: kFontSmall,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.55,
                      child: Switch(
                        value: isVisible,
                        onChanged: (_) => onToggle(),
                        activeColor: kAccentBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: kError, size: 18),
                      onPressed: onDelete,
                      tooltip: 'Hide this insight permanently',
                    ),
                  ],
                ),
              ],
            ),
            if (isVisible) ...[
              const SizedBox(height: 8),
              content,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final isOwner = user != null;
    
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          tooltip: 'Back to Home',
          onPressed: () {
            // If this screen was pushed as a route (web/mobile), pop it.
            // Otherwise fall back to switching the main tab (legacy wrapper).
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            } else {
              ref.read(mainTabIndexProvider.notifier).state = 0;
            }
          },
        ),
        title: const Text('My Profile', style: TextStyle(color: kPrimaryText)),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.settings, color: kAccentBlue, size: 20),
              tooltip: 'Award Settings',
              onPressed: _showAwardSettingsDialog,
            ),
          profileAsync.whenOrNull(
            data: (profile) => TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, kRouteEditProfile),
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: kAccentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ) ?? const SizedBox.shrink(),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        loading: () => Container(
          color: kBackground,
          child: const Center(
            child: CircularProgressIndicator(color: kAccentBlue),
          ),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: kError),
          ),
        ),
        data: (profile) {
          final p = profile ?? UserModel.empty('');
          final earnedAwards = _getEarnedAwards();
          
          // Build insight widgets list with proper keys for ReorderableColumn
          final List<Widget> insightWidgetsList = [];
          
          if (_essayResults.isNotEmpty) {
            insightWidgetsList.add(
              Container(
                key: const ValueKey('essay'),
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildEssayInsights(),
              ),
            );
          }
          
          if (_interviewResults.where((r) => r['profession'] != null).isNotEmpty) {
            insightWidgetsList.add(
              Container(
                key: const ValueKey('professional'),
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildProfessionalExamInsights(),
              ),
            );
          }
          
          if (_interviewResults.where((r) => r['summary'] != null).isNotEmpty) {
            insightWidgetsList.add(
              Container(
                key: const ValueKey('interview'),
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildInterviewPracticeInsights(),
              ),
            );
          }
          
          if (_insights.containsKey('personality')) {
            insightWidgetsList.add(
              Container(
                key: const ValueKey('personality'),
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildPersonalityInsight(),
              ),
            );
          }
          
          if (_insights.containsKey('integrity')) {
            insightWidgetsList.add(
              Container(
                key: const ValueKey('integrity'),
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildIntegrityInsight(),
              ),
            );
          }
          
          if (_civilServiceResults.isNotEmpty) {
            insightWidgetsList.add(
              Container(
                key: const ValueKey('civil_service'),
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildCivilServiceInsights(),
              ),
            );
          }
          
          if (_englishResults.isNotEmpty) {
            insightWidgetsList.add(
              Container(
                key: const ValueKey('english'),
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildEnglishInsights(),
              ),
            );
          }
          
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: kSurface,
                      backgroundImage: p.avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(p.avatarUrl)
                          : null,
                      child: p.avatarUrl.isEmpty
                          ? const Icon(Icons.person, size: 50, color: kSecondaryText)
                          : null,
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      p.displayName.isEmpty ? 'Anonymous User' : p.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (p.username.isNotEmpty)
                      Text(
                        p.username.startsWith('@') ? p.username : '@${p.username}',
                        style: const TextStyle(
                          color: kAccentBlue,
                          fontSize: kFontBase,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 12),
                    
                    if (p.bio.isNotEmpty)
                      Text(
                        p.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: kPrimaryText,
                          fontSize: kFontBase,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Achievements',
                      style: TextStyle(
                        color: kPrimaryText,
                        fontSize: kFontTitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (earnedAwards.isNotEmpty)
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: earnedAwards.map((award) {
                          final value = _getAwardValue(award['testName'])!;
                          final isLarge = award['icon'] == 6 || award['icon'] == 7 || award['icon'] == 8;
                          final iconSize = isLarge ? 60.0 : 50.0;
                          
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/${award['icon']}.png',
                                width: iconSize,
                                height: iconSize,
                                errorBuilder: (context, error, stack) {
                                  return Icon(
                                    Icons.emoji_events,
                                    size: iconSize,
                                    color: kAccentBlue,
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                award['displayName'],
                                style: TextStyle(
                                  color: kSecondaryText,
                                  fontSize: isLarge ? kFontSmall : 11,
                                ),
                              ),
                              if (value != 'Earned' || (value == 'Earned' && _showAwardScores))
                                Text(
                                  value,
                                  style: const TextStyle(
                                    color: kAccentBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Insights',
                      style: TextStyle(
                        color: kPrimaryText,
                        fontSize: kFontTitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ReorderableColumn(
                      children: insightWidgetsList,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _insightOrder.removeAt(oldIndex);
                          _insightOrder.insert(newIndex, item);
                        });
                        _saveInsightOrder();
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveInsightOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('insight_order', _insightOrder);
  }

  void _loadInsightOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList('insight_order');
    if (savedOrder != null && savedOrder.isNotEmpty) {
      setState(() {
        _insightOrder = savedOrder;
      });
    }
  }

  Widget _buildEssayInsights() {
    final essayResults = _essayResults.toList();
    
    if (essayResults.isEmpty) return const SizedBox.shrink();

    return Column(
      children: essayResults.map((result) {
        final percentage = result['percentage'] ?? 0;
        final summary = result['summary'] ?? 'No summary available.';
        
        return _buildInsightCard(
          id: 'essay_${result['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          title: 'Essay Writing',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: $percentage%',
                style: const TextStyle(
                  color: kSuccess,
                  fontSize: kFontBase,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summary,
                style: const TextStyle(
                  color: kPrimaryText,
                  fontSize: kFontBase,
                  height: 1.4,
                ),
              ),
            ],
          ),
          isVisible: _showEssay,
          onToggle: () => setState(() => _showEssay = !_showEssay),
          onDelete: () => _hideInsightPermanently('essay', result['id']),
        );
      }).toList(),
    );
  }

  Widget _buildCivilServiceInsights() {
    final civilServiceResults = _civilServiceResults.toList();
    
    if (civilServiceResults.isEmpty) return const SizedBox.shrink();

    return Column(
      children: civilServiceResults.map((result) {
        final percentage = result['percentage'] ?? 0;
        final score = result['score'] ?? 0;
        final total = result['total_questions'] ?? 40;
        final passed = percentage >= 80;
        
        return _buildInsightCard(
          id: 'civil_service_${result['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          title: 'Civil Service Exam',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: $score/$total ($percentage%)',
                style: TextStyle(
                  color: passed ? kSuccess : kError,
                  fontSize: kFontBase,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                passed 
                    ? 'You passed the Civil Service Exam! Ready for government employment.'
                    : 'Keep practicing. Focus on your weak areas to pass next time.',
                style: const TextStyle(
                  color: kPrimaryText,
                  fontSize: kFontBase,
                  height: 1.4,
                ),
              ),
            ],
          ),
          isVisible: _showCivilService,
          onToggle: () => setState(() => _showCivilService = !_showCivilService),
          onDelete: () => _hideInsightPermanently('civil_service', result['id']),
        );
      }).toList(),
    );
  }

  Widget _buildEnglishInsights() {
    final englishResults = _englishResults.toList();
    
    if (englishResults.isEmpty) return const SizedBox.shrink();

    return Column(
      children: englishResults.map((result) {
        final percentage = result['percentage'] ?? 0;
        final score = result['score'] ?? 0;
        final total = result['total_questions'] ?? 30;
        final passed = percentage >= 76;
        
        return _buildInsightCard(
          id: 'english_${result['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          title: 'English Proficiency',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: $score/$total ($percentage%)',
                style: TextStyle(
                  color: passed ? kSuccess : kError,
                  fontSize: kFontBase,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                passed 
                    ? 'BPO-ready English communication skills!'
                    : 'Practice grammar, vocabulary, and reading comprehension to improve.',
                style: const TextStyle(
                  color: kPrimaryText,
                  fontSize: kFontBase,
                  height: 1.4,
                ),
              ),
            ],
          ),
          isVisible: _showEnglish,
          onToggle: () => setState(() => _showEnglish = !_showEnglish),
          onDelete: () => _hideInsightPermanently('english', result['id']),
        );
      }).toList(),
    );
  }

  Widget _buildProfessionalExamInsights() {
    final examResults = _interviewResults
        .where((r) => r['profession'] != null)
        .toList();
    
    if (examResults.isEmpty) return const SizedBox.shrink();

    return Column(
      children: examResults.map((result) {
        final profession = result['profession'] ?? 'Your field';
        final percentage = result['percentage'] ?? 0;
        final summary = result['summary'] ?? 'No summary available.';
        
        return _buildInsightCard(
          id: 'professional_${result['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          title: 'Professional Exam',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$profession $percentage%',
                style: const TextStyle(
                  color: kSuccess,
                  fontSize: kFontBase,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summary,
                style: const TextStyle(
                  color: kPrimaryText,
                  fontSize: kFontBase,
                  height: 1.4,
                ),
              ),
            ],
          ),
          isVisible: _showProfessionalExam,
          onToggle: () => setState(() => _showProfessionalExam = !_showProfessionalExam),
          onDelete: () => _hideInsightPermanently('professional', result['id']),
        );
      }).toList(),
    );
  }

  Widget _buildInterviewPracticeInsights() {
    final interviewResults = _interviewResults
        .where((r) => r['summary'] != null)
        .toList();
    
    if (interviewResults.isEmpty) return const SizedBox.shrink();

    return Column(
      children: interviewResults.map((result) {
        final profession = result['profession'] ?? 'Your field';
        final percentage = result['percentage'] ?? 0;
        final summary = result['summary'] ?? 'No summary available.';
        
        return _buildInsightCard(
          id: 'interview_${result['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          title: 'Interview Practice',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$profession $percentage%',
                style: const TextStyle(
                  color: kSuccess,
                  fontSize: kFontBase,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summary,
                style: const TextStyle(
                  color: kPrimaryText,
                  fontSize: kFontBase,
                  height: 1.4,
                ),
              ),
            ],
          ),
          isVisible: _showInterviewPractice,
          onToggle: () => setState(() => _showInterviewPractice = !_showInterviewPractice),
          onDelete: () => _hideInsightPermanently('interview', result['id']),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalityInsight() {
    if (!_insights.containsKey('personality')) return const SizedBox.shrink();
    
    return _buildInsightCard(
      id: 'personality',
      title: 'Personality Profile',
      content: Text(
        _insights['personality']!,
        style: const TextStyle(
          color: kPrimaryText,
          fontSize: kFontBase,
          height: 1.4,
        ),
      ),
      isVisible: _showPersonality,
      onToggle: () => setState(() => _showPersonality = !_showPersonality),
      onDelete: () => _hideInsightPermanently('personality', null),
    );
  }

  Widget _buildIntegrityInsight() {
    if (!_insights.containsKey('integrity')) return const SizedBox.shrink();
    
    return _buildInsightCard(
      id: 'integrity',
      title: 'Integrity Profile',
      content: Text(
        _insights['integrity']!,
        style: const TextStyle(
          color: kPrimaryText,
          fontSize: kFontBase,
          height: 1.4,
        ),
      ),
      isVisible: _showIntegrity,
      onToggle: () => setState(() => _showIntegrity = !_showIntegrity),
      onDelete: () => _hideInsightPermanently('integrity', null),
    );
  }

  Future<void> _hideInsightPermanently(String insightType, dynamic resultId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Hide Insight', style: TextStyle(color: kPrimaryText)),
        content: const Text(
          'This insight will be hidden from your profile. You can unhide it later from settings.',
          style: TextStyle(color: kSecondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kSecondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hide', style: TextStyle(color: kError)),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      await Supabase.instance.client.from('hidden_insights').upsert({
        'user_id': user.id,
        'insight_type': insightType,
        'result_id': resultId,
        'hidden_at': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        switch (insightType) {
          case 'essay':
            _showEssay = false;
            break;
          case 'professional':
            _showProfessionalExam = false;
            break;
          case 'interview':
            _showInterviewPractice = false;
            break;
          case 'personality':
            _showPersonality = false;
            break;
          case 'integrity':
            _showIntegrity = false;
            break;
          case 'civil_service':
            _showCivilService = false;
            break;
          case 'english':
            _showEnglish = false;
            break;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insight hidden'), backgroundColor: kSuccess),
        );
      }
    } catch (e) {
      print('Error hiding insight: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: kError),
        );
      }
    }
  }
}
