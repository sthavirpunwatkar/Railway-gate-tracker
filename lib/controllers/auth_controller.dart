import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var hidePass = true.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔐 Login
  void login(String email, String password) async {
    isLoading.value = true;
    try {
      // 👑 Static admin credentials
      if (email == "admin@gmail.com" && password == "Admin@1234") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAdmin', true);
        Get.offAllNamed('/admin-home');
        return;
      }

      // 🧑 Regular user login
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✍️ Signup
  void signup(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAllNamed('/profile');
    } catch (e) {
      Get.snackbar("Signup Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔁 Reset Password
  void resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Success", "Password reset email sent");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// 🚪 Logout
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAdmin');
    await _auth.signOut();
    Get.offAllNamed('/login');
  }

  /// ✅ Check if admin is logged in (can be used during splash/init)
  Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdmin') ?? false;
  }
}
