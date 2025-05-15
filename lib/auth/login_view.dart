import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realway_manage/constants/app_colors.dart';
import 'package:realway_manage/constants/app_text_styles.dart';
import 'package:realway_manage/constants/app_assets.dart';
import 'package:realway_manage/controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  final email = TextEditingController();
  final pass = TextEditingController();
  final c = Get.put(AuthController());

  void _handleLogin() {
    final enteredEmail = email.text.trim();
    final enteredPass = pass.text.trim();

    if (enteredEmail == "admin@gmail.com" && enteredPass == "Admin@1234") {
      Get.offAllNamed('/admin-home');
    } else {
      c.login(enteredEmail, enteredPass);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            // 🔵 Circular logo image with increased size
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                AppAssets.logo,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),
            Text("Railways Gate Finder", style: AppTextStyles.title),
            const SizedBox(height: 40),

            // Email TextField
            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password TextField
            Obx(
              () => TextField(
                controller: pass,
                obscureText: c.hidePass.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      c.hidePass.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => c.hidePass.value = !c.hidePass.value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.toNamed('/forgot'),
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Login Button
            Obx(
              () =>
                  c.isLoading.value
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 80,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        onPressed: _handleLogin,
                        child: Text("Login", style: AppTextStyles.buttonText),
                      ),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.toNamed('/signup'),
              child: Text(
                "Don't have an account? Sign Up",
                style: AppTextStyles.linkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
