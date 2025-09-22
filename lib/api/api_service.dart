import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class APIService {
  static const String baseUrl = "http://192.168.15.192:8080/api";

  // Headers chung cho các request
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Xử lý lỗi HTTP
  static Map<String, dynamic> handleError(dynamic e) {
    Get.snackbar(
      "Lỗi kết nối",
      "Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return {'success': false, 'message': 'Network error: ${e.toString()}'};
  }

  // =================== AUTH ===================
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: getHeaders(),
        body: json.encode({'email': email, 'password': password}),
      );
      return json.decode(response.body);
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: getHeaders(),
        body: json.encode({'email': email, 'password': password}),
      );
      return json.decode(response.body);
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: getHeaders(),
        body: json.encode({'email': email}),
      );
      return json.decode(response.body);
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: getHeaders(),
        body: json.encode({'token': token, 'newPassword': newPassword}),
      );
      return json.decode(response.body);
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getUserProfile({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/user-profile'),
        headers: getHeaders(token: token),
      );
      return json.decode(response.body);
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/user-profile'),
        headers: getHeaders(token: token),
        body: json.encode(userData),
      );
      return json.decode(response.body);
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: getHeaders(token: token),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String, dynamic>> validateToken({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/validate-token'),
        headers: getHeaders(token: token),
      );
      return json.decode(response.body);
    } catch (e) {
      return handleError(e);
    }
  }

  // =================== PROGRESS ===================
  static Future<Map<String, dynamic>> getProgress({required int userId, required int grade}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/progress/user/$userId/grade/$grade"),
        headers: getHeaders(),
      );
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String,dynamic>> updateProgressApi(Map<String,dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/progress/update"),
        headers: getHeaders(),
        body: json.encode(body),
      );
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String,dynamic>> getProgressHistory({
    required int userId,
    required String subject,
    required String range
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/progress/history?userId=$userId&subject=$subject&range=$range"),
        headers: getHeaders(),
      );
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }

  // =================== SUBJECTS & CONTENT ===================
  static Future<Map<String,dynamic>> getSubjects({int? grade}) async {
    try {
      String url = "$baseUrl/subjects";
      if (grade != null) url += "?grade=$grade";
      final response = await http.get(Uri.parse(url), headers: getHeaders());
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String,dynamic>> getSubjectByGradeAndCode(int grade, String code) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/grades/$grade/subjects/$code"),
        headers: getHeaders(),
      );
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String,dynamic>> getChapters(int subjectId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/subjects/$subjectId/chapters"),
        headers: getHeaders(),
      );
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String,dynamic>> getLessons(int chapterId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/chapters/$chapterId/lessons"),
        headers: getHeaders(),
      );
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String,dynamic>> getLessonContents(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/lessons/$lessonId/contents"),
        headers: getHeaders(),
      );
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String,dynamic>> getExercises(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/lessons/$lessonId/exercises"),
        headers: getHeaders(),
      );
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }

  static Future<Map<String,dynamic>> getExerciseSolutions(int exerciseId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/exercises/$exerciseId/solutions"),
        headers: getHeaders(),
      );
      return {'success': response.statusCode == 200, 'data': json.decode(response.body)};
    } catch (e) {
      return handleError(e);
    }
  }
}
