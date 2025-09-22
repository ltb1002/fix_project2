class ProgressModel {
  final String subject;
  final int completedLessons;
  final int totalLessons;
  final double progressPercent; // 0..100

  ProgressModel({
    required this.subject,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercent,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      subject: json['subject'] ?? '',
      completedLessons: json['completedLessons'] ?? 0,
      totalLessons: json['totalLessons'] ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'completedLessons': completedLessons,
      'totalLessons': totalLessons,
      'progressPercent': progressPercent,
    };
  }
}
