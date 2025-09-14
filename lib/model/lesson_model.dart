// content_model.dart
class ContentItem {
  final String type;
  final String value;

  ContentItem({required this.type, required this.value});

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      type: json['type'] ?? 'text',
      value: json['value'] ?? '',
    );
  }
}

// exercise_model.dart
class Exercise {
  final String question;
  final List<ContentItem> solutions;

  Exercise({required this.question, required this.solutions});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    var solutionsList = json['solutions'] as List<dynamic>? ?? [];
    return Exercise(
      question: json['question'] ?? '',
      solutions: solutionsList.map((item) => ContentItem.fromJson(item)).toList(),
    );
  }
}

// lesson_model.dart
class Lesson {
  final int id;
  final String title;
  final String videoUrl;
  final List<ContentItem> contents;
  final List<Exercise> exercises;

  Lesson({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.contents,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    var contentsList = json['contents'] as List<dynamic>? ?? [];
    var exercisesList = json['exercises'] as List<dynamic>? ?? [];

    return Lesson(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      contents: contentsList.map((item) => ContentItem.fromJson(item)).toList(),
      exercises: exercisesList.map((item) => Exercise.fromJson(item)).toList(),
    );
  }
}