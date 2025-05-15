import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realway_manage/constants/app_assets.dart';
import 'package:realway_manage/constants/app_colors.dart';
import 'package:realway_manage/constants/app_text_styles.dart';
import 'package:realway_manage/controllers/auth_controller.dart';

class SignupView extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final c = Get.find<AuthController>();

  SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
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
            const SizedBox(height: 40),
            Text("Sign Up", style: AppTextStyles.title),
            const SizedBox(height: 30),

            // 📧 Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // 🔒 Password Field
            Obx(
              () => TextField(
                controller: passwordController,
                obscureText: c.hidePass.value,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      c.hidePass.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => c.hidePass.value = !c.hidePass.value,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔁 Confirm Password Field
            Obx(
              () => TextField(
                controller: confirmController,
                obscureText: c.hidePass.value,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ✅ Sign Up Button
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
                        ),
                        onPressed: () {
                          if (passwordController.text ==
                              confirmController.text) {
                            c.signup(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                          } else {
                            Get.snackbar("Error", "Passwords do not match");
                          }
                        },
                        child: Text("Sign Up", style: AppTextStyles.buttonText),
                      ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Get.offAllNamed('/login'),
              child: Text(
                "Already have an account? Login",
                style: AppTextStyles.linkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
