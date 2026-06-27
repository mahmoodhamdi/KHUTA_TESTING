import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/core/utils/haptic_utils.dart';
import 'package:khuta/cubit/assessment/assessment_cubit.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/screens/child/assessment/widgets/answer_options_list.dart';
import 'package:khuta/screens/child/assessment/widgets/navigation_buttons.dart';
import 'package:khuta/screens/child/assessment/widgets/progress_bar.dart';
import 'package:khuta/screens/child/assessment/widgets/question_image.dart';
import 'package:khuta/screens/child/assessment/widgets/question_text.dart';
import 'package:khuta/screens/child/results_screen.dart';
import 'package:khuta/screens/main_screen.dart';
import 'package:khuta/widgets/loading_overlay.dart';

class AssessmentScreen extends StatelessWidget {
  final Child child;
  final List<Question> questions;

  const AssessmentScreen({
    super.key,
    required this.questions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return _ErrorScreen(
        onRetry: () => Navigator.pop(context),
      );
    }

    return BlocProvider(
      create: (context) => AssessmentCubit(
        child: child,
        questions: questions,
      ),
      child: _AssessmentView(
        child: child,
        questions: questions,
      ),
    );
  }
}

class _AssessmentView extends StatelessWidget {
  final Child child;
  final List<Question> questions;

  const _AssessmentView({
    required this.child,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AssessmentCubit, AssessmentState>(
      listener: (context, state) {
        // Handle status changes
        if (state.status == AssessmentStatus.submitting) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const LoadingOverlay(),
          );
        } else if (state.status == AssessmentStatus.success) {
          // Close loading dialog
          Navigator.of(context).pop();
          // Navigate to results
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                interpretation: state.interpretation ?? '',
                child: child,
                score: state.finalScore ?? 0,
                answers: state.answers,
                questions: questions,
                recommendations: state.recommendations ?? [],
              ),
            ),
          );
        } else if (state.status == AssessmentStatus.error) {
          // Close loading dialog if open
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage?.tr() ?? 'error_saving_results'.tr()),
              backgroundColor: Colors.red,
            ),
          );
          // Clear error state
          context.read<AssessmentCubit>().clearError();
        }
      },
      builder: (context, state) {
        final cubit = context.read<AssessmentCubit>();
        final currentQuestion = questions[state.currentIndex];

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _showExitConfirmation(context, isDark);
          },
          child: Scaffold(
            backgroundColor: HomeScreenTheme.backgroundColor(isDark),
            appBar: _buildAppBar(context, isDark, cubit),
            body: SafeArea(
              child: Column(
                children: [
                  AssessmentProgressBar(
                    currentQuestionIndex: state.currentIndex,
                    totalQuestions: questions.length,
                  ),
                  Expanded(
                    child: _buildQuestionContent(
                      context,
                      currentQuestion,
                      state,
                      cubit,
                      isRTL,
                    ),
                  ),
                  NavigationButtons(
                    onPrevious: () {
                      HapticUtils.navigation();
                      cubit.previousQuestion();
                    },
                    onNext: () {
                      if (cubit.isLastQuestion) {
                        HapticUtils.assessmentComplete();
                        cubit.submitAssessment();
                      } else {
                        HapticUtils.navigation();
                        cubit.nextQuestion();
                      }
                    },
                    isFirstQuestion: state.isFirstQuestion,
                    isLastQuestion: cubit.isLastQuestion,
                    canProceed: cubit.canProceed,
                    isRTL: isRTL,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    AssessmentCubit cubit,
  ) {
    return AppBar(
      title: Text(questions[0].questionType.tr()),
      backgroundColor: HomeScreenTheme.cardBackground(isDark),
      foregroundColor: HomeScreenTheme.primaryText(isDark),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _showExitConfirmation(context, isDark),
      ),
    );
  }

  Widget _buildQuestionContent(
    BuildContext context,
    Question currentQuestion,
    AssessmentState state,
    AssessmentCubit cubit,
    bool isRTL,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          QuestionImage(imageUrl: currentQuestion.imageUrl),
          const SizedBox(height: 24),
          QuestionText(text: currentQuestion.questionText, isRTL: isRTL),
          const SizedBox(height: 24),
          AnswerOptionsList(
            selectedAnswer: state.answers[state.currentIndex],
            onSelect: (optionIndex) {
              HapticUtils.answerSelected();
              cubit.selectAnswer(state.currentIndex, optionIndex);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context, bool isDark) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        title: Text(
          'exit_assessment'.tr(),
          style: TextStyle(
            color: HomeScreenTheme.primaryText(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'exit_assessment_confirmation'.tr(),
          style: TextStyle(color: HomeScreenTheme.primaryText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'continue'.tr(),
              style: TextStyle(color: HomeScreenTheme.accentBlue(isDark)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            ),
            child: Text(
              'exit'.tr(),
              style: TextStyle(color: HomeScreenTheme.accentRed(isDark)),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _ErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text('assessment'.tr()),
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        foregroundColor: HomeScreenTheme.primaryText(isDark),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: HomeScreenTheme.accentRed(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'error_loading_questions'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: HomeScreenTheme.primaryText(isDark),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeScreenTheme.accentBlue(isDark),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
