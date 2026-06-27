
class Question {
  final String id;
  final String imageUrl;
  final String questionText;
  final String questionType;

  Question({
    required this.id,
    required this.imageUrl,
    required this.questionText,
    this.questionType = "parent",
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      questionText: map['questionText'] ?? '',
      questionType: map['questionType'] ?? "parent",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'questionText': questionText,
      'questionType': questionType,
    };
  }
}
