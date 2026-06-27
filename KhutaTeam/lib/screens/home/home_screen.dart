import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/core/utils/accessibility_utils.dart';
import 'package:khuta/core/utils/haptic_utils.dart';
import 'package:khuta/core/utils/page_transitions.dart';
import 'package:khuta/core/widgets/shimmer_loading.dart';
import 'package:khuta/cubit/child/child_cubit.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/screens/child/add_child_screen.dart';
import 'package:khuta/screens/child/child_details_screen.dart';

import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChildCubit()..loadChildren(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: HomeScreenTheme.backgroundColor(isDark),
        appBar: AppBar(
          title: Text('my_children'.tr()),
          backgroundColor: HomeScreenTheme.cardBackground(isDark),
          foregroundColor: HomeScreenTheme.primaryText(isDark),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: BlocConsumer<ChildCubit, ChildState>(
            listener: (context, state) {
              if (state.status == ChildStatus.error &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
                context.read<ChildCubit>().clearError();
              }
            },
            builder: (context, state) {
              switch (state.status) {
                case ChildStatus.initial:
                case ChildStatus.loading:
                  return const ChildListSkeleton();
                case ChildStatus.error:
                  if (state.children.isEmpty) {
                    return _ErrorWidget(
                      error: state.errorMessage ?? 'error_loading_children'.tr(),
                      onRetry: () => context.read<ChildCubit>().loadChildren(),
                      isDark: isDark,
                    );
                  }
                  return _ChildrenList(children: state.children);
                case ChildStatus.loaded:
                case ChildStatus.adding:
                case ChildStatus.deleting:
                  if (state.isEmpty) {
                    return _EmptyState(
                      onAddChild: () => _showAddChildScreen(context),
                      isDark: isDark,
                    );
                  }
                  return _ChildrenList(children: state.children);
              }
            },
          ),
        ),
        floatingActionButton: Tooltip(
          message: 'accessibility_add_child_button'.tr(),
          child: FloatingActionButton(
            onPressed: () => _showAddChildScreen(context),
            backgroundColor: HomeScreenTheme.accentBlue(isDark),
            child: Semantics(
              label: 'accessibility_add_child_button'.tr(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddChildScreen(BuildContext context) {
    HapticUtils.buttonPress();
    Navigator.of(context).push(
      SlideUpPageRoute(
        page: AddChildScreen(
          onAddChild: (child) {
            context.read<ChildCubit>().addChild(child);
          },
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'error_loading_children'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: TextStyle(color: HomeScreenTheme.secondaryText(isDark)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeScreenTheme.accentBlue(isDark),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddChild;
  final bool isDark;

  const _EmptyState({
    required this.onAddChild,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: HomeScreenTheme.accentBlue(isDark).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.child_care,
              size: 80,
              color: HomeScreenTheme.accentBlue(isDark),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'no_children_yet'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'add_child_description'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: HomeScreenTheme.secondaryText(isDark),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onAddChild,
            icon: const Icon(Icons.add),
            label: Text('add_first_child'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeScreenTheme.accentBlue(isDark),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildrenList extends StatelessWidget {
  final List<Child> children;

  const _ChildrenList({required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return _ChildCard(child: children[index]);
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  final Child child;

  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lastTest = child.testResults.isNotEmpty ? child.testResults.last : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: InkWell(
        onTap: () {
          HapticUtils.cardTap();
          Navigator.of(context).push(
            SlidePageRoute(
              page: ChildDetailsScreen(child: child),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar section
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (child.gender == 'male'
                              ? HomeScreenTheme.accentBlue(isDark)
                              : HomeScreenTheme.accentPink(isDark))
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      child.gender == 'male' ? Icons.boy : Icons.girl,
                      size: 30,
                      color: child.gender == 'male'
                          ? HomeScreenTheme.accentBlue(isDark)
                          : HomeScreenTheme.accentPink(isDark),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HomeScreenTheme.primaryText(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.cake_outlined,
                              size: 14,
                              color: HomeScreenTheme.secondaryText(isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${child.age} ${'years_old'.tr()}',
                              style: TextStyle(
                                fontSize: 14,
                                color: HomeScreenTheme.secondaryText(isDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (child.testResults.isNotEmpty) ...[
                const SizedBox(height: 16),
                _TestResultsSection(lastTest: lastTest!, isDark: isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TestResultsSection extends StatelessWidget {
  final dynamic lastTest;
  final bool isDark;

  const _TestResultsSection({
    required this.lastTest,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'test_history'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HomeScreenTheme.primaryText(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 24,
                    color: HomeScreenTheme.secondaryText(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'last_test'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: HomeScreenTheme.secondaryText(isDark),
                    ),
                  ),
                ],
              ),
              Text(
                context.locale.languageCode == 'ar'
                    ? DateFormat.yMMMd('ar').format(lastTest.date)
                    : DateFormat.yMMMd('en').format(lastTest.date),
                style: TextStyle(
                  fontSize: 14,
                  color: HomeScreenTheme.secondaryText(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: HomeScreenTheme.getScoreColor(
                              lastTest.score,
                              isDark,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            lastTest.score < 45
                                ? Icons.emoji_events // Low score - good
                                : lastTest.score <= 55
                                    ? Icons.horizontal_rule // Average
                                    : Icons.trending_up, // Elevated/High - concern
                            size: 12,
                            color: HomeScreenTheme.getScoreColor(
                              lastTest.score,
                              isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'latest_score'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: HomeScreenTheme.secondaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                label: AccessibilityUtils.getScoreAccessibilityLabel(lastTest.score),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: HomeScreenTheme.getScoreColor(
                          lastTest.score,
                          isDark,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lastTest.score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: HomeScreenTheme.getScoreColor(
                            lastTest.score,
                            isDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Text label for score severity (accessibility)
                    Text(
                      AccessibilityUtils.getScoreSeverityText(lastTest.score),
                      style: TextStyle(
                        fontSize: 10,
                        color: HomeScreenTheme.getScoreColor(
                          lastTest.score,
                          isDark,
                        ),
                      ),
                    ),
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
