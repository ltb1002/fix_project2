import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = true.obs;
  var isLoggedIn = false.obs;
  var isFirstOpen = true.obs;

  var email = ''.obs;
  var password = ''.obs;
  var username = ''.obs;

  var classes = ["6", "7", "8", "9"].obs;
  var selectedClass = "".obs;
  var isClassSelected = false.obs;

  var subjects = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstOpen.value = prefs.getBool('isFirstOpen') ?? true;
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn.value) {
      email.value = prefs.getString('email') ?? '';
      password.value = prefs.getString('password') ?? '';
      username.value = prefs.getString('username') ?? 'Người dùng';
      selectedClass.value = prefs.getString('selectedClass') ?? '';
      isClassSelected.value = selectedClass.value.isNotEmpty;
      updateSubjects();
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return "Name cannot be blank";
    if (value.length < 3) return "Name must be at least 3 characters";
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email cannot be blank";
    if (!GetUtils.isEmail(value)) return "Email is not valid";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password cannot be blank";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  Future<void> registerUser(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', emailController.text.trim());
      await prefs.setString('password', passwordController.text.trim());
      await prefs.setString('username', usernameController.text.trim());
      await prefs.setBool('isLoggedIn', false);
      await prefs.setBool('isFirstOpen', false);

      Get.snackbar("Success", "Đăng ký thành công!");
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> loginUser(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      final savedPassword = prefs.getString('password');
      final savedUsername = prefs.getString('username');

      if (emailController.text.trim() == savedEmail &&
          passwordController.text.trim() == savedPassword) {
        isLoggedIn.value = true;
        username.value = savedUsername ?? "Người dùng";
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isFirstOpen', false);

        Get.snackbar("Login", "Đăng nhập thành công!");
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.snackbar("Login", "Email hoặc mật khẩu không đúng!");
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    isLoggedIn.value = false;
    email.value = '';
    password.value = '';
    username.value = '';
    selectedClass.value = '';
    isClassSelected.value = false;
    subjects.clear();

    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> setSelectedClass(String value) async {
    selectedClass.value = value;
    isClassSelected.value = true;
    updateSubjects();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedClass', value);
    subjects.refresh();
  }

  void updateSubjects() {
    subjects.value = ["Toán", "Khoa Học Tự Nhiên", "Tiếng Anh", "Ngữ Văn"];
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
