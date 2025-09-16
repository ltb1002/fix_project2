import 'exercise_model.dart';

class ContentItem {
  final int id;
  final String type;       // "text" hoặc "image"
  final String value;      // nội dung text hoặc link image
  final int order;         // thứ tự hiển thị

  ContentItem({
    required this.id,
    required this.type,
    required this.value,
    required this.order,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? 0,
      type: json['contentType'] ?? 'text',
      value: json['contentValue'] ?? '',
      order: json['contentOrder'] ?? 0,
    );
  }
}

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
    this.contents = const [],
    this.exercises = const [],
  });

  Lesson copyWith({
    int? id,
    String? title,
    String? videoUrl,
    List<ContentItem>? contents,
    List<Exercise>? exercises,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      contents: contents ?? this.contents,
      exercises: exercises ?? this.exercises,
    );
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    // Load contents nếu có
    final contentsData = json['contents'] as List<dynamic>? ?? [];
    List<ContentItem> contents = contentsData
        .map((c) => ContentItem.fromJson(c))
        .toList();

    // Load exercises nếu có
    final exercisesData = json['exercises'] as List<dynamic>? ?? [];
    List<Exercise> exercises = exercisesData
        .map((e) => Exercise.fromJson(e))
        .toList();

    return Lesson(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      contents: contents,
      exercises: exercises,
    );
  }
}