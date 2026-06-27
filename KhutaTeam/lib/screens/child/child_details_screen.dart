import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:khuta/core/constants/questions.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/core/utils/haptic_utils.dart';
import 'package:khuta/core/utils/page_transitions.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/test_result.dart';
import 'package:khuta/screens/child/assessment/assessment_screen.dart';
import 'package:khuta/screens/child/game/game_screen.dart';

class ChildDetailsScreen extends StatefulWidget {
  final Child child;

  const ChildDetailsScreen({super.key, required this.child});

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text(widget.child.name),
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        foregroundColor: HomeScreenTheme.primaryText(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: HomeScreenTheme.accentBlue(isDark),
            unselectedLabelColor: HomeScreenTheme.secondaryText(isDark),
            indicatorColor: HomeScreenTheme.accentBlue(isDark),
            tabs: [
              Tab(text: 'profile_results'.tr()),
              Tab(text: 'recommendations'.tr()),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زرار اللعبة التدريبية
          FloatingActionButton.small(
            heroTag: 'game_fab',
            onPressed: () {
              HapticUtils.buttonPress();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GameScreen(child: widget.child)),
              );
            },
            backgroundColor: const Color(0xFF9B59B6),
            child: const Icon(Icons.sports_esports_rounded, color: Colors.white),
          ).animate().scale(delay: 100.ms, duration: 300.ms),
          const SizedBox(height: 10),
          // زرار التقييم
          FloatingActionButton(
            heroTag: 'assessment_fab',
            onPressed: () {
              HapticUtils.buttonPress();
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildAssessmentOptions(
                  context,
                  isDark,
                  isRTL,
                ).animate().slideY(begin: 1.0, end: 0.0, duration: 300.ms),
              );
            },
            backgroundColor: HomeScreenTheme.accentBlue(isDark),
            child: const Icon(Icons.add, color: Colors.white),
          ).animate().scale(delay: 200.ms, duration: 300.ms),
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileAndResultsTab(context, isDark, isRTL),
            _buildRecommendationsTab(context, isDark, isRTL),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAndResultsTab(
    BuildContext context,
    bool isDark,
    bool isRTL,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HomeScreenTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [HomeScreenTheme.cardShadow(isDark)],
            ),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color:
                        (widget.child.gender == 'male'
                                ? HomeScreenTheme.accentBlue(isDark)
                                : HomeScreenTheme.accentPink(isDark))
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    widget.child.gender == 'male' ? Icons.boy : Icons.girl,
                    size: 60,
                    color: widget.child.gender == 'male'
                        ? HomeScreenTheme.accentBlue(isDark)
                        : HomeScreenTheme.accentPink(isDark),
                  ),
                ).animate().scale(duration: 400.ms).fadeIn(),
                const SizedBox(height: 16),
                Text(
                  widget.child.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: HomeScreenTheme.primaryText(isDark),
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      color: HomeScreenTheme.secondaryText(isDark),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.child.age} ${'years_old'.tr()}',
                      style: TextStyle(
                        fontSize: 16,
                        color: HomeScreenTheme.secondaryText(isDark),
                      ),
                    ),
                  ],
                ).animate().slideX(
                  begin: isRTL ? -0.2 : 0.2,
                  end: 0,
                  duration: 300.ms,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.child.gender == 'male' ? Icons.male : Icons.female,
                      color: HomeScreenTheme.secondaryText(isDark),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.child.gender.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: HomeScreenTheme.secondaryText(isDark),
                      ),
                    ),
                  ],
                ).animate().slideX(
                  begin: isRTL ? 0.2 : -0.2,
                  end: 0,
                  duration: 300.ms,
                ),
                if (widget.child.testResults.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black12 : Colors.grey[50])!,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'test_summary'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: HomeScreenTheme.primaryText(isDark),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              Icons.assignment_turned_in,
                              widget.child.testResults.length.toString(),
                              'total_tests'.tr(),
                              HomeScreenTheme.accentBlue(isDark),
                              isDark,
                            ).animate().fadeIn(delay: 200.ms),
                            _buildStatItem(
                              context,
                              Icons.trending_up,
                              '${widget.child.testResults.last.score}',
                              'last_score'.tr(),
                              HomeScreenTheme.getScoreColor(
                                widget.child.testResults.last.score,
                                isDark,
                              ),
                              isDark,
                            ).animate().fadeIn(delay: 300.ms),
                            _buildStatItem(
                              context,
                              Icons.calendar_today,
                              DateFormat.MMMd().format(
                                widget.child.testResults.last.date,
                              ),
                              'last_test'.tr(),
                              HomeScreenTheme.secondaryText(isDark),
                              isDark,
                            ).animate().fadeIn(delay: 400.ms),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          // Results Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HomeScreenTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [HomeScreenTheme.cardShadow(isDark)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: HomeScreenTheme.accentGreen(
                          isDark,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history,
                        color: HomeScreenTheme.accentGreen(isDark),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'previous_tests'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HomeScreenTheme.primaryText(isDark),
                      ),
                    ),
                  ],
                ).animate().slideY(begin: 0.2, end: 0, duration: 300.ms),
                const SizedBox(height: 16),
                if (widget.child.testResults.isEmpty)
                  Center(
                    child: Text(
                      'no_results'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: HomeScreenTheme.secondaryText(isDark),
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                  )
                else
                  ...widget.child.testResults.asMap().entries.map(
                    (entry) => _buildTestResultCard(entry.value, isDark)
                        .animate()
                        .fadeIn(delay: (100 * entry.key).ms)
                        .slideX(
                          begin: isRTL ? -0.1 : 0.1,
                          end: 0,
                          duration: 300.ms,
                        ),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(
    BuildContext context,
    bool isDark,
    bool isRTL,
  ) {
    if (widget.child.testResults.isEmpty ||
        widget.child.testResults.last.recommendations.isEmpty) {
      return Center(
        child: Text(
          'no_recommendations'.tr(),
          style: TextStyle(
            fontSize: 16,
            color: HomeScreenTheme.secondaryText(isDark),
          ),
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: HomeScreenTheme.cardBackground(isDark),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [HomeScreenTheme.cardShadow(isDark)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HomeScreenTheme.accentBlue(
                      isDark,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: HomeScreenTheme.accentBlue(isDark),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'recommendations'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: HomeScreenTheme.primaryText(isDark),
                  ),
                ),
              ],
            ).animate().slideY(begin: 0.2, end: 0, duration: 300.ms),
            const SizedBox(height: 16),
            ...widget.child.testResults.last.recommendations
                .asMap()
                .entries
                .map(
                  (entry) =>
                      Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: HomeScreenTheme.backgroundColor(isDark),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: HomeScreenTheme.accentBlue(
                                  isDark,
                                ).withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 22,
                                  color: HomeScreenTheme.accentBlue(isDark),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _cleanRec(entry.value),
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.6,
                                      color: HomeScreenTheme.secondaryText(
                                        isDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (100 * entry.key).ms)
                          .slideX(
                            begin: isRTL ? -0.1 : 0.1,
                            end: 0,
                            duration: 300.ms,
                          ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentOptions(
    BuildContext context,
    bool isDark,
    bool isRTL,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'select_assessment'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(
              Icons.family_restroom,
              color: HomeScreenTheme.accentBlue(isDark),
            ),
            title: Text(
              'parent_assessment'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: HomeScreenTheme.primaryText(isDark),
              ),
            ),
            onTap: () {
              HapticUtils.buttonPress();
              Navigator.pop(context);
              Navigator.push(
                context,
                SlidePageRoute(
                  page: AssessmentScreen(
                    child: widget.child,
                    questions: parentQuestions,
                  ),
                ),
              );
            },
          ).animate().fadeIn(delay: 100.ms),
          ListTile(
            leading: Icon(
              Icons.class_,
              color: HomeScreenTheme.accentBlue(isDark),
            ),
            title: Text(
              'teacher_assessment'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: HomeScreenTheme.primaryText(isDark),
              ),
            ),
            onTap: () {
              HapticUtils.buttonPress();
              Navigator.pop(context);
              Navigator.push(
                context,
                SlidePageRoute(
                  page: AssessmentScreen(
                    questions: teacherQuestions,
                    child: widget.child,
                  ),
                ),
              );
            },
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    ).animate().slideY(begin: 1.0, end: 0.0, duration: 300.ms);
  }

  Widget _buildTestResultCard(TestResult test, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black12 : const Color(0xFFF7FAFC)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.testType.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HomeScreenTheme.primaryText(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.locale.languageCode == 'ar'
                      ? DateFormat('dd/MM/yyyy', 'ar').format(test.date)
                      : DateFormat('dd/MM/yyyy', 'en').format(test.date),
                  style: TextStyle(
                    fontSize: 14,
                    color: HomeScreenTheme.secondaryText(isDark),
                  ),
                ),
                if (test.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    test.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: HomeScreenTheme.secondaryText(isDark),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: HomeScreenTheme.getScoreColor(
                test.score,
                isDark,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              test.score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: HomeScreenTheme.getScoreColor(test.score, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: HomeScreenTheme.primaryText(isDark),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: HomeScreenTheme.secondaryText(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // FIX #6: AI recommendations are plain text, NOT translation keys — never call .tr() on them
  String _cleanRec(String input) {
    return input
        .replaceAll(RegExp(r'^[\*\-\•]\s*'), '')
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => m.group(1) ?? '')
        .trim();
  }
}
