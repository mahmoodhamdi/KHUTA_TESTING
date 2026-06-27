import 'package:easy_localization/easy_localization.dart';
import 'package:khuta/models/question.dart';

final Map<int, Map<String, String>> indexedTeacherQuestions = {
  0: {
    "text": "impulsive_excitable",
    "image":
        "assets/images/teacher_questions/Impulsive_and_easily_excitable.jpg",
  },
  1: {
    "text": "submissive_surrendering",
    "image": "assets/images/teacher_questions/Submissive_and_surrendering.jpg",
  },
  2: {
    "text": "sensitive_to_criticism",
    "image":
        "assets/images/teacher_questions/Highly_sensitive_to_criticism.webp",
  },
  3: {
    "text": "uncooperative_with_teacher",
    "image": "assets/images/teacher_questions/Uncooperative_with_teacher.jpg",
  },
  4: {
    "text": "bored_and_irritated",
    "image":
        "assets/images/teacher_questions/Child_feeling_bored_and_irritated.jpeg",
  },
  5: {
    "text": "childish_and_immature",
    "image": "assets/images/teacher_questions/Childish_and_immature.jpg",
  },
  6: {
    "text": "uncooperative_with_classmates",
    "image":
        "assets/images/teacher_questions/Uncooperative_with_classmates.jpg",
  },
  7: {
    "text": "socially_unacceptable",
    "image": "assets/images/teacher_questions/Socially_unacceptable.jpg",
  },
  8: {
    "text": "fidgety_always_standing",
    "image": "assets/images/teacher_questions/Fidgety_and_always_standing.jpg",
  },
  9: {
    "text": "does_not_get_along",
    "image":
        "assets/images/teacher_questions/Does_not_get_along_with_others.jpg",
  },
  10: {
    "text": "learning_difficulties",
    "image": "assets/images/teacher_questions/Has_learning_difficulties.jpeg",
  },
  11: {
    "text": "disruptive_naughty",
    "image": "assets/images/teacher_questions/Disruptive_and_naughty.jpg",
  },
  12: {
    "text": "easily_led_by_others",
    "image": "assets/images/teacher_questions/Easily_led_by_others.jpg",
  },
  13: {
    "text": "impolite_behavior",
    "image": "assets/images/teacher_questions/Behaves_impolitely.jpg",
  },
  14: {
    "text": "noticeable_mood_swings",
    "image": "assets/images/teacher_questions/Mood_swings_are_noticeable.webp",
  },
  15: {
    "text": "noise_at_inappropriate_times",
    "image":
        "assets/images/teacher_questions/Makes_noise_at_inappropriate_times.jpg",
  },
  16: {
    "text": "annoys_other_children",
    "image": "assets/images/teacher_questions/Annoys_other_children.jpg",
  },
  17: {
    "text": "monopolizes_play",
    "image": "assets/images/teacher_questions/Monopolizes_play.jpg",
  },
  18: {
    "text": "daydreams_a_lot",
    "image": "assets/images/teacher_questions/Daydreams_a_lot.jpg",
  },
  19: {
    "text": "easily_frustrated",
    "image":
        "assets/images/teacher_questions/Easily_frustrated_when_exerting_effort.jpg",
  },
  20: {
    "text": "wants_immediate_gratification",
    "image":
        "assets/images/teacher_questions/Insists_on_immediate_gratification.jpg",
  },
  21: {
    "text": "seeks_attention",
    "image": "assets/images/teacher_questions/Seeks_excessive_attention.jpg",
  },
  22: {
    "text": "distractibility",
    "image": "assets/images/teacher_questions/Suffers_from_distractibility.jpg",
  },
  23: {
    "text": "lacks_leadership",
    "image": "assets/images/teacher_questions/Lacks_the_ability_to_lead.jpg",
  },
  24: {
    "text": "explosive_behavior",
    "image":
        "assets/images/teacher_questions/Explosive_and_unexpected_behavior.jpg",
  },
  25: {
    "text": "fails_to_finish",
    "image": "assets/images/teacher_questions/Fails_to_finish_tasks.jpg",
  },
  26: {
    "text": "frowns_and_discontent",
    "image": "assets/images/teacher_questions/Frowns_and_shows_discontent.jpg",
  },
  27: {
    "text": "denies_mistakes",
    "image":
        "assets/images/teacher_questions/Denies_mistakes_and_blames_others.jpg",
  },
};

final List<Question> parentQuestions = List.generate(48, (index) {
  // بيانات الأسئلة (بدون tr() هنا)
  const Map<int, Map<String, String>> indexedParentQuestions = {
    0: {
      "text": "rude_with_adults",
      "image": "assets/images/parents_questions/Rude_with_adults.jpg",
    },
    1: {
      "text": "distracted_and_inattentive",
      "image": "assets/images/parents_questions/Distracted_and_inattentive.jpg",
    },
    2: {"text": "shy", "image": "assets/images/parents_questions/Shy.jpg"},
    3: {
      "text": "cries_easily",
      "image": "assets/images/parents_questions/Cries_easily.jpg",
    },
    4: {
      "text": "very_fearful",
      "image": "assets/images/parents_questions/Very_fearful.jpeg",
    },
    5: {
      "text": "always_ready_to_fight",
      "image": "assets/images/parents_questions/Always_ready_to_fight.jpg",
    },
    6: {
      "text": "unable_to_stop_repetitive_behavior",
      "image":
          "assets/images/parents_questions/Unable_to_stop_repetitive_behavior.jpg",
    },
    7: {
      "text": "disobedient",
      "image": "assets/images/parents_questions/Disobedient.jpeg",
    },
    8: {
      "text": "immature",
      "image": "assets/images/parents_questions/Immature.jpg",
    },
    9: {"text": "harsh", "image": "assets/images/parents_questions/Harsh.jpg"},
    10: {
      "text": "does_not_appear_happy",
      "image": "assets/images/parents_questions/Does_not_appear_happy.jpg",
    },
    11: {
      "text": "dislikes_and_disobeys_rules",
      "image":
          "assets/images/parents_questions/Dislikes_and_disobeys_rules.jpg",
    },
    12: {
      "text": "does_not_get_along_with_siblings",
      "image":
          "assets/images/parents_questions/Does_not_get_along_with_siblings.jpg",
    },
    13: {
      "text": "fidgety_and_irritable",
      "image": "assets/images/parents_questions/Fidgety_and_irritable.jpg",
    },
    14: {
      "text": "has_other_disorders_and_pain",
      "image":
          "assets/images/parents_questions/Has_other_disorders_and_pain.jpg",
    },
    15: {
      "text": "boastful",
      "image": "assets/images/parents_questions/Boastful.jpg",
    },
    16: {
      "text": "feels_like_vomiting",
      "image": "assets/images/parents_questions/Feels_like_vomiting.jpg",
    },
    17: {
      "text": "stomach_pain",
      "image": "assets/images/parents_questions/Stomach_pain.jpg",
    },
    18: {
      "text": "learning_difficulty",
      "image": "assets/images/parents_questions/Learning_difficulty.jpg",
    },
    19: {
      "text": "stomach_problems",
      "image": "assets/images/parents_questions/Stomach_problems.jpg",
    },
    20: {
      "text": "sleep_problems",
      "image": "assets/images/parents_questions/Sleep_problems.jpg",
    },
    21: {
      "text": "eating_problems_like_poor_appetite",
      "image":
          "assets/images/parents_questions/Eating_problems_like_poor_appetite.jpg",
    },
    22: {
      "text": "destructive",
      "image": "assets/images/parents_questions/Destructive.jpeg",
    },
    23: {
      "text": "extremely_sensitive",
      "image": "assets/images/parents_questions/Extremely_sensitive.jpg",
    },
    24: {
      "text": "troublemaker_creates_issues",
      "image":
          "assets/images/parents_questions/Troublemaker_creates_issues.jpg",
    },
    25: {
      "text": "easily_frustrated",
      "image": "assets/images/parents_questions/Easily_frustrated.jpg",
    },
    26: {
      "text": "impulsive_and_excitable",
      "image": "assets/images/parents_questions/Impulsive_and_excitable.jpg",
    },
    27: {
      "text": "speaks_differently_than_peers",
      "image":
          "assets/images/parents_questions/Speaks_differently_than_peers.jpg",
    },
    28: {
      "text": "leaves_self_vulnerable",
      "image": "assets/images/parents_questions/Leaves_self_vulnerable.jpg",
    },
    29: {
      "text": "frequently_fights",
      "image": "assets/images/parents_questions/Frequently_fights.jpg",
    },
    30: {
      "text": "rapid_mood_swings",
      "image": "assets/images/parents_questions/Rapid_mood_swings.jpg",
    },
    31: {
      "text": "struggles_to_make_and_keep_friends",
      "image":
          "assets/images/parents_questions/Struggles_to_make_and_keep_friends.jpg",
    },
    32: {
      "text": "wants_to_operate_things",
      "image": "assets/images/parents_questions/Wants_to_operate_things.jpg",
    },
    33: {
      "text": "annoys_other_children",
      "image": "assets/images/parents_questions/Annoys_other_children.jpg",
    },
    34: {
      "text": "steals",
      "image": "assets/images/parents_questions/Steals.jpg",
    },
    35: {
      "text": "has_headaches",
      "image": "assets/images/parents_questions/Has_headaches.jpg",
    },
    36: {
      "text": "feels_family_cheats_him",
      "image": "assets/images/parents_questions/Feels_family_cheats_him.jpg",
    },
    37: {
      "text": "shows_discontent",
      "image": "assets/images/parents_questions/Shows_discontent.jpg",
    },
    38: {
      "text": "suffers_from_daydreaming",
      "image": "assets/images/parents_questions/Suffers_from_daydreaming.jpg",
    },
    39: {
      "text": "exposes_self_to_trouble",
      "image": "assets/images/parents_questions/Exposes_self_to_trouble.jpg",
    },
    40: {
      "text": "fails_to_finish_tasks",
      "image": "assets/images/parents_questions/Fails_to_finish_tasks.jpg",
    },
    41: {
      "text": "prefers_standing_ready_to_go",
      "image":
          "assets/images/parents_questions/Prefers_standing_ready_to_go.jpg",
    },
    42: {
      "text": "bites_things",
      "image": "assets/images/parents_questions/Bites_things.jpg",
    },
    43: {
      "text": "worries_more_than_others_due_to_loneliness",
      "image":
          "assets/images/parents_questions/Worries_more_than_others_due_to_loneliness.jpg",
    },
    44: {
      "text": "lies_and_makes_up_stories",
      "image": "assets/images/parents_questions/Lies_and_makes_up_stories.jpg",
    },
    45: {
      "text": "sucks_thumb",
      "image": "assets/images/parents_questions/Sucks_thumb.jpg",
    },
    46: {
      "text": "denies_mistakes_and_blames_others",
      "image":
          "assets/images/parents_questions/Denies_mistakes_and_blames_others.jpg",
    },
    47: {
      "text": "threatens_and_attacks_others",
      "image":
          "assets/images/parents_questions/Threatens_and_attacks_others.jpg",
    },
  };

  return Question(
    id: 'p$index',
    questionText: tr(indexedParentQuestions[index]!['text']!),
    imageUrl: indexedParentQuestions[index]!['image']!,
    questionType: "parent",
  );
});

final List<Question> teacherQuestions = List.generate(
  indexedTeacherQuestions.length,
  (index) {
    return Question(
      id: 't$index',
      questionText: tr(indexedTeacherQuestions[index]!['text']!),
      imageUrl: indexedTeacherQuestions[index]!['image']!,
      questionType: "teacher",
    );
  },
);
