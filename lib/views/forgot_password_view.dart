import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realway_manage/controllers/auth_controller.dart';

class ForgotPasswordView extends StatelessWidget {
  final email = TextEditingController();
  final c = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: email, decoration: InputDecoration(labelText: 'Email')),
            ElevatedButton(
              onPressed: () => c.resetPassword(email.text),
              child: Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
