import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar + Tên
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Text(
                        authController.username.value.isNotEmpty
                            ? authController.username.value[0].toUpperCase()
                            : "U",
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authController.username.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authController.email.value,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Thông tin chi tiết + Dropdown chọn lớp học
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: const Text("Username"),
                      subtitle: Text(authController.username.value),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.orange),
                      title: const Text("Email"),
                      subtitle: Text(authController.email.value),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: const Text("Phone"),
                      subtitle: const Text("+84 123 456 789"), // Có thể thêm field phone sau
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.class_, color: Colors.purple),
                      title: const Text("Lớp học hiện tại"),
                      subtitle: Obx(() => DropdownButton<String>(
                        value: authController.selectedClass.value.isNotEmpty
                            ? authController.selectedClass.value
                            : null,
                        hint: const Text("Chọn lớp học"),
                        isExpanded: true,
                        items: authController.classes
                            .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text("Lớp $value"),
                        ))
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            authController.setSelectedClass(newValue);
                            Get.snackbar(
                              "Cập nhật lớp học",
                              "Bạn đã chọn lớp $newValue",
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        },
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Nút đăng xuất
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => authController.logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
