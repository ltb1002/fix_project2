import 'package:flutter/material.dart';
import 'package:flutter_elearning_application/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  // Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Rx variables
  var isPasswordVisible = true.obs;
  var registeredUsers = <String, String>{}.obs;
  var isLoggedIn = false.obs;
  var email = ''.obs;
  var password = ''.obs;
  var username = ''.obs;

  // Quản lý lớp học
  var classes = ["6", "7", "8", "9"].obs;
  var selectedClass = "".obs;
  var isClassSelected = false.obs;

  // Danh sách môn học
  var subjects = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();

    debounce(email, (_) {
      if (GetUtils.isEmail(email.value)) {
        print("Email is valid: ${email.value}");
      } else {
        print("Email not valid");
      }
    }, time: const Duration(milliseconds: 800));
  }

  /// Đọc thông tin đăng nhập từ SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    final storedPassword = prefs.getString('password');
    final storedUsername = prefs.getString('username');
    final storedClass = prefs.getString('selectedClass');
    final loggedInStatus = prefs.getBool('isLoggedIn') ?? false;

    if (loggedInStatus && storedEmail != null && storedPassword != null) {
      email.value = storedEmail;
      password.value = storedPassword;
      username.value = storedUsername ?? "Người dùng";
      selectedClass.value = storedClass ?? "";
      isClassSelected.value = selectedClass.value.isNotEmpty;
      updateSubjects();
      isLoggedIn.value = true;

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.offAllNamed(AppRoutes.main);
      });
    }
  }

  /// Lưu thông tin đăng nhập
  Future<void> saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', emailController.text.trim());
    await prefs.setString('password', passwordController.text.trim());
    await prefs.setString('username', usernameController.text.trim());
    await prefs.setString('selectedClass', selectedClass.value);
    await prefs.setBool('isLoggedIn', true);
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be blank";
    }
    if (value.length < 3) {
      return "Name must be at least 3 characters";
    }
    return null;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email cannot be blank";
    }
    if (!GetUtils.isEmail(value)) {
      return "Email is not valid";
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be blank";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  /// Đăng ký
  Future<void> registerUser(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(emailController.text)) {
        Get.snackbar("Error", "Email already registered!");
        return;
      }

      await prefs.setString('email', emailController.text.trim());
      await prefs.setString('password', passwordController.text.trim());
      await prefs.setString('username', usernameController.text.trim());
      await prefs.setBool('isLoggedIn', false);

      Get.snackbar("Success", "Register successfully!");
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Đăng nhập
  Future<void> loginUser(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      final savedPassword = prefs.getString('password');
      final savedName = prefs.getString('username');

      if (emailController.text == savedEmail &&
          passwordController.text == savedPassword) {
        isLoggedIn.value = true;
        username.value = savedName ?? "Người dùng";

        await prefs.setBool('isLoggedIn', true);
        await saveUserData();

        Get.snackbar("Login", "Login successfully!");
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.snackbar("Login", "Login failed! Email or Password incorrect");
      }
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    isLoggedIn.value = false;
    email.value = "";
    password.value = "";
    username.value = "";
    selectedClass.value = "";
    isClassSelected.value = false;
    subjects.clear();

    Get.offAllNamed(AppRoutes.login);
  }

  /// Cập nhật lớp học + Danh sách môn học
  Future<void> setSelectedClass(String value) async {
    selectedClass.value = value;
    isClassSelected.value = true;
    updateSubjects();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedClass', value);

    subjects.refresh();
  }

  void updateSubjects() {
    subjects.value = ["Toán", "Lý", "Anh", "Văn"];
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
