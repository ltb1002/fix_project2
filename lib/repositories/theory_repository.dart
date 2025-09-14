import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../model/chapter_model.dart';
import '../model/lesson_model.dart';

class TheoryRepository {
  late final String baseUrl;
  late final http.Client client;

  TheoryRepository() {
    if (kIsWeb) {
      baseUrl = "http://192.168.0.144:8080/api";
    } else if (Platform.isAndroid) {
      if (_isGenymotion()) {
        baseUrl = "http://192.168.51.2:8080/api";
      } else if (_isEmulator()) {
        baseUrl = "http://10.0.2.2:8080/api";
      } else {
        baseUrl = "http://192.168.0.144:8080/api";
      }
    } else if (Platform.isIOS) {
      baseUrl = "http://localhost:8080/api";
    } else {
      baseUrl = "http://192.168.0.144:8080/api";
    }

    print("Using baseUrl: $baseUrl");
    client = _createHttpClient();
  }

  http.Client _createHttpClient() {
    if (kIsWeb) return http.Client();

    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 30)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    return IOClient(httpClient);
  }

  bool _isEmulator() {
    return Platform.isAndroid &&
        (Platform.environment.containsKey('EMULATOR_DEVICE') ||
            Platform.environment.containsKey('ANDROID_EMULATOR'));
  }

  bool _isGenymotion() {
    return Platform.isAndroid &&
        Platform.environment.containsKey('GENYMOTION');
  }

  /// Map tên môn học hiển thị (có dấu) sang code trong DB (không dấu, viết liền)
  String _normalizeSubjectCode(String subjectName) {
    final mapping = {
      "Toán": "toan",
      "Ngữ Văn": "nguvan",
      "Khoa học Tự nhiên": "khoahoctunhien",
      "Tiếng Anh": "tienganh",
      // thêm các môn khác nếu có
    };

    return mapping[subjectName] ??
        subjectName.toLowerCase().replaceAll(" ", "");
  }

  Future<List<Chapter>> fetchTheory(String subjectName, int grade) async {
    try {
      // 1. Chuyển tên môn học sang code trong DB
      final subjectCode = _normalizeSubjectCode(subjectName);

      // 2. Gọi API lấy thông tin subject theo grade + code
      final subjectRes = await _getWithRetry(
          "$baseUrl/grades/$grade/subjects/$subjectCode");
      final subject = json.decode(subjectRes);

      // Check if subject data is valid
      if (subject == null || subject['id'] == null) {
        throw Exception("Không tìm thấy môn học: $subjectName - Khối $grade");
      }

      final subjectId = subject['id'];

      // 3. Lấy chapters của subject
      final chaptersRes =
      await _getWithRetry("$baseUrl/subjects/$subjectId/chapters");
      final chaptersData = json.decode(chaptersRes) as List;

      List<Chapter> chapters = [];

      // 4. Lấy lessons cho từng chapter
      for (var chapterJson in chaptersData) {
        final chapterId = chapterJson['id'];
        final lessonsRes =
        await _getWithRetry("$baseUrl/chapters/$chapterId/lessons");
        final lessonsData = json.decode(lessonsRes) as List;

        Chapter chapter = Chapter.fromJson(chapterJson);
        chapter.lessons =
            lessonsData.map<Lesson>((x) => Lesson.fromJson(x)).toList();
        chapters.add(chapter);
      }

      return chapters;
    } catch (e) {
      print("ERROR: Không thể tải dữ liệu từ API: $e");
      throw Exception("Không thể tải dữ liệu từ API: $e");
    }
  }

  Future<String> _getWithRetry(String url, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        print("Calling API (attempt ${i + 1}/$maxRetries): $url");
        final response =
        await client.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          throw Exception("Lỗi server: ${response.statusCode} khi gọi $url");
        }

        return response.body;
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        print("Retrying API call after error: $e");
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception("Failed to call API after $maxRetries attempts");
  }

  void dispose() {
    client.close();
  }
}