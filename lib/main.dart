import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:realway_manage/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text("Exit App"),
                content: const Text("Are you sure you want to exit the app?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text("No"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text("Yes"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: GetMaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Login App',
        debugShowCheckedModeBanner: false,
        initialRoute:
            FirebaseAuth.instance.currentUser != null ? '/home' : '/login',
        getPages: AppRoutes.routes,
      ),
    );
  }
}
