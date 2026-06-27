import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:khuta/core/services/connectivity_service.dart';
import 'package:khuta/core/utils/retry_helper.dart';
import 'package:khuta/models/question.dart';

/// Service for generating personalized ADHD recommendations using Firebase AI.
///
/// This service uses Google's Gemini 2.0 Flash model to analyze assessment results
/// and provide tailored recommendations for parents and educators. It includes:
///
/// - **Automatic language detection**: Detects Arabic vs English from question content
/// - **AI-powered recommendations**: Generates 5-7 actionable recommendations
/// - **Fallback system**: Provides static recommendations when AI is unavailable
/// - **Retry logic**: Handles transient failures with exponential backoff
/// - **Connectivity awareness**: Checks network before making AI calls
///
/// ## Usage
///
/// ```dart
/// final recommendations = await AiRecommendationsService.getRecommendations(
///   55, // T-score
///   questions, // List of assessment questions
///   answers, // List of answer values
///   childAge: 8,
///   childGender: 'male',
/// );
/// ```
///
/// ## Fallback Behavior
///
/// When AI generation fails (no internet, API error, empty response), the service
/// returns pre-defined recommendations based on the T-score severity level:
/// - T-score ≥70: High concern - professional consultation recommended
/// - T-score 65-69: Elevated concern - intervention plan needed
/// - T-score 60-64: Moderate concern - monitoring recommended
/// - T-score 45-59: Average - continue current support
/// - T-score <45: Low concern - maintain positive strategies
class AiRecommendationsService {
  static final ConnectivityService _connectivityService = ConnectivityService();

  /// The Gemini AI model instance used for generating recommendations.
  static final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
  );

  /// Detects the language of the assessment based on question content.
  ///
  /// Checks for Arabic Unicode characters (U+0600 to U+06FF) in the first question.
  ///
  /// Returns 'ar' for Arabic, 'en' for English (default).
  static String _detectLanguage(List<Question> questions) {
    if (questions.isEmpty) return 'en';
    
    // Check if first question contains Arabic characters
    final firstQuestion = questions[0].questionText;
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    
    return arabicRegex.hasMatch(firstQuestion) ? 'ar' : 'en';
  }

  /// Formats the AI prompt with assessment data.
  ///
  /// Creates a structured prompt including:
  /// - Child demographics (age, gender)
  /// - T-score result
  /// - All questions with their answers
  /// - Clear instructions for AI response format
  ///
  /// The prompt is generated in the detected language (Arabic or English).
  static String _formatPrompt(
    List<Question> questions,
    List<int> answers,
    int tScore,
    int? childAge,
    String? childGender,
  ) {
    final language = _detectLanguage(questions);
    final isArabic = language == 'ar';
    
    List<String> promptBuilder = [];
    
    // Add intro based on language
    if (isArabic) {
      promptBuilder.addAll([
        'تم تقييم طفل باستخدام مقياس كونرز لأعراض اضطراب فرط الحركة ونقص الانتباه (ADHD).',
        childAge != null ? 'عمر الطفل: $childAge سنة' : '',
        childGender != null ? 'جنس الطفل: $childGender' : '',
        'النتيجة الإجمالية: $tScore',
        '',
        'الأسئلة والإجابات:',
      ]);
    } else {
      promptBuilder.addAll([
        'A child has been assessed using the Conners Scale for ADHD symptoms.',
        childAge != null ? 'Child age: $childAge years' : '',
        childGender != null ? 'Child gender: $childGender' : '',
        'Total score: $tScore',
        '',
        'Questions and answers:',
      ]);
    }

    // Add questions and answers
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] >= 0) {
        promptBuilder.add(
          '${i + 1}. ${questions[i].questionText} - ${_translateAnswer(answers[i])}',
        );
      }
    }

    // Add instructions based on language
    if (isArabic) {
      promptBuilder.addAll([
        '',
        'المطلوب:',
        'قائمة بالتوصيات العملية فقط (5-7 توصيات) لا تضف أي مقدمات أو عبارات ترحيبية أو ملخصات. اذكر التوصيات مباشرة.',
        '',
        'يرجى الكتابة باللغة العربية بشكل مختصر ومفيد.',
      ]);
    } else {
      promptBuilder.addAll([
        '',
        'Required:',
        'List ONLY practical recommendations (5-7 recommendations). Do NOT include any introductions, welcome phrases, or summaries. Provide ONLY the direct recommendations.',
        '',
        'Please write in English, keeping it concise and helpful.',
      ]);
    }

    return promptBuilder.where((line) => line.isNotEmpty).join('\n');
  }

  /// Translates answer value to localized text.
  ///
  /// Answer values:
  /// - 0: Never
  /// - 1: Rarely
  /// - 2: Sometimes
  /// - 3: Often
  static String _translateAnswer(int answer) {
    switch (answer) {
      case 0:
        return "never".tr();
      case 1:
        return "rarely".tr();
      case 2:
        return "sometimes".tr();
      case 3:
        return "often".tr();
      default:
        return 'Not Answered';
    }
  }

  /// Generates personalized recommendations based on assessment results.
  ///
  /// This is the main entry point for getting AI-powered recommendations.
  ///
  /// Parameters:
  /// - [tScore]: The calculated T-score from the assessment
  /// - [questions]: List of assessment questions (used for language detection)
  /// - [answers]: List of answer values corresponding to each question
  /// - [childAge]: Optional age of the child for more tailored recommendations
  /// - [childGender]: Optional gender of the child
  ///
  /// Returns a list of 5-7 actionable recommendation strings.
  ///
  /// The method:
  /// 1. Checks internet connectivity
  /// 2. Attempts AI generation with retry logic (3 attempts, exponential backoff)
  /// 3. Parses the AI response to extract clean recommendations
  /// 4. Falls back to static recommendations if any step fails
  static Future<List<String>> getRecommendations(
    int tScore,
    List<Question> questions,
    List<int> answers, {
    int? childAge,
    String? childGender,
  }) async {
    try {
      // Check connectivity first
      if (!await _connectivityService.hasConnection()) {
        if (kDebugMode) debugPrint('No internet connection, using fallback recommendations');
        return _getFallbackRecommendations(
          tScore: tScore,
          language: _detectLanguage(questions),
        );
      }

      // Retry AI call up to 3 times with exponential backoff
      final response = await RetryHelper.retry(
        operation: () async {
          final prompt = [
            Content.text(_formatPrompt(questions, answers, tScore, childAge, childGender))
          ];
          if (kDebugMode) debugPrint('Prompt: ${prompt[0].parts[0].toString()}');
          return await model.generateContent(prompt);
        },
        maxAttempts: 3,
        initialDelay: const Duration(seconds: 2),
      );

      if (response.text == null || response.text!.isEmpty) {
        return _getFallbackRecommendations(
          tScore: tScore,
          language: _detectLanguage(questions),
        );
      }

      // Parse the response to extract recommendations
      final responseText = response.text!;
      final recommendations = _parseRecommendations(responseText);

      return recommendations.isEmpty
          ? _getFallbackRecommendations(
              tScore: tScore,
              language: _detectLanguage(questions),
            )
          : recommendations;
    } catch (e) {
      if (kDebugMode) debugPrint('Error generating AI recommendations: $e');
      return _getFallbackRecommendations(
        tScore: tScore,
        language: _detectLanguage(questions),
      );
    }
  }

  /// Parses the AI response text to extract individual recommendations.
  ///
  /// Handles various formats:
  /// - Bullet points (• or -)
  /// - Numbered lists (1., 2., etc.)
  /// - Plain text lines
  ///
  /// Filters out:
  /// - Empty lines
  /// - Introduction/summary phrases (English and Arabic)
  /// - Meta-commentary about the recommendations
  static List<String> _parseRecommendations(String responseText) {
    final recommendations = <String>[];
    final lines = responseText.split('\n');
    
    for (String line in lines) {
      final trimmedLine = line.trim();
      
      // Skip empty lines
      if (trimmedLine.isEmpty) continue;
      
      // Skip lines that look like introductions or summaries
      if (trimmedLine.toLowerCase().contains('summary') ||
          trimmedLine.toLowerCase().contains('analysis') ||
          trimmedLine.toLowerCase().contains('based on') ||
          trimmedLine.toLowerCase().contains('according to') ||
          trimmedLine.contains('ملخص') ||
          trimmedLine.contains('تحليل')) {
        continue;
      }
      
      // Extract bullet points or numbered items
      if (trimmedLine.startsWith('•') || 
          trimmedLine.startsWith('-') ||
          RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
        
        // Clean up the recommendation text
        String recommendation = trimmedLine
            .replaceFirst(RegExp(r'^[•\-\d\.]+\s*'), '')
            .trim();
            
        if (recommendation.isNotEmpty) {
          recommendations.add(recommendation);
        }
      }
      // Also add lines that look like recommendations but without bullets
      // Only if they don't contain common introduction phrases
      else if (trimmedLine.length > 10 &&
               !trimmedLine.toLowerCase().contains('recommend') &&
               !trimmedLine.toLowerCase().contains('following') &&
               !trimmedLine.toLowerCase().contains('here') &&
               !trimmedLine.contains('توصيات') &&
               !trimmedLine.contains('فيما يلي')) {
        recommendations.add(trimmedLine);
      }
    }
    
    return recommendations;
  }

  /// Returns static fallback recommendations when AI generation fails.
  ///
  /// Recommendations are tailored to the T-score severity level:
  /// - ≥70: Very high concern - immediate professional help
  /// - 65-69: High concern - professional consultation
  /// - 60-64: Moderate concern - monitoring and possible consultation
  /// - 45-59: Average range - continue current support
  /// - <45: Low concern - maintain positive strategies
  ///
  /// Available in both English and Arabic based on [language] parameter.
  static List<String> _getFallbackRecommendations({
    int tScore = 0,
    String language = 'en',
  }) {
    final isArabic = language == 'ar';
    
    if (tScore >= 70) {
      return isArabic ? [
        'استشارة فورية مع أخصائي نفسي أو طبيب نفسي',
        'إجراء تقييم شامل لاضطراب فرط الحركة ونقص الانتباه',
        'وضع خطة دعم متكاملة في المنزل والمدرسة',
        'مراقبة منتظمة للسلوك والأعراض',
        'التنسيق بين الأهل والمعلمين',
        'النظر في التدخلات السلوكية المكثفة',
      ] : [
        'Immediate consultation with psychologist or psychiatrist',
        'Comprehensive ADHD evaluation needed',
        'Create integrated support plan for home and school',
        'Regular monitoring of behavior and symptoms',
        'Coordinate between parents and teachers',
        'Consider intensive behavioral interventions',
      ];
    } else if (tScore >= 65) {
      return isArabic ? [
        'استشارة مع أخصائي نفسي أو تربوي',
        'وضع خطة تدخل سلوكي',
        'تحسين التنسيق بين الأهل والمعلمين',
        'متابعة دورية للتقدم',
        'تطبيق استراتيجيات الدعم في البيئات المختلفة',
      ] : [
        'Consultation with psychologist or educational specialist',
        'Develop behavioral intervention plan',
        'Improve parent-teacher coordination',
        'Regular follow-up for progress',
        'Implement support strategies across environments',
      ];
    } else if (tScore >= 60) {
      return isArabic ? [
        'مراقبة السلوك عن كثب',
        'النظر في استشارة مهنية',
        'تطبيق استراتيجيات الدعم',
        'تقييم منتظم للوضع',
        'تعزيز السلوكيات الإيجابية',
      ] : [
        'Monitor behavior closely',
        'Consider professional consultation',
        'Implement support strategies',
        'Regular assessment of situation',
        'Reinforce positive behaviors',
      ];
    } else if (tScore >= 45) {
      return isArabic ? [
        'مواصلة الدعم الحالي',
        'المراقبة المنتظمة',
        'التعزيز الإيجابي',
        'الأنشطة المناسبة للعمر',
        'التشجيع المستمر',
      ] : [
        'Continue current support',
        'Maintain regular monitoring',
        'Positive reinforcement',
        'Age-appropriate activities',
        'Ongoing encouragement',
      ];
    } else {
      return isArabic ? [
        'المحافظة على الاستراتيجيات الحالية',
        'تشجيع السلوكيات الإيجابية',
        'مراقبة النمو العادي',
        'المشاركة المناسبة للعمر',
      ] : [
        'Maintain current strategies',
        'Encourage positive behaviors',
        'Regular development monitoring',
        'Age-appropriate engagement',
      ];
    }
  }
}