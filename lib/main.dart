import 'package:flutter/material.dart';
import 'package:flutter_elearning_application/app/routes/app_page.dart';
import 'package:flutter_elearning_application/app/routes/app_routes.dart';
import 'package:flutter_elearning_application/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/main_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  Get.put(AuthController());
  Get.put(MainController());

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Learning App',
      initialRoute: isLoggedIn ? AppRoutes.main : AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}
