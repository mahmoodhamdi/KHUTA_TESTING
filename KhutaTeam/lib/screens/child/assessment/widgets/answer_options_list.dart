import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'answer_option.dart';

class AnswerOptionsList extends StatelessWidget {
  final int selectedAnswer;
  final Function(int) onSelect;

  const AnswerOptionsList({
    super.key,
    required this.selectedAnswer,
    required this.onSelect,
  });

  static const List<String> answerKeys = [
    'never',
    'rarely',
    'sometimes',
    'often',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < answerKeys.length; i++)
          AnswerOption(
            option: answerKeys[i].tr(),
            isSelected: selectedAnswer == i,
            onTap: () => onSelect(i),
          ),
      ],
    );
  }
}
