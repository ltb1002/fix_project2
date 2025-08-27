import 'package:get/get.dart';
import 'package:flutter_elearning_application/app/routes/app_routes.dart';
import 'package:flutter_elearning_application/screens/home_screen.dart';
import 'package:flutter_elearning_application/screens/login_screen.dart';
import 'package:flutter_elearning_application/screens/signup_screen.dart';
import 'package:flutter_elearning_application/screens/welcome_screen.dart';

import '../../screens/subject_detail_screen.dart';
import '../../widgets/main_widgets.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.welcome, page: () => WelcomeScreen()),
    GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.main, page: () => MainScreen()),
    GetPage(
      name: AppRoutes.subjectDetail,
      page: () => SubjectDetailScreen(
        grade: Get.arguments['grade'],
        subject: Get.arguments['subject'],
      ),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
