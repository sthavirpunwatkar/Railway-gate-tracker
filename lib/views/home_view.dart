import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realway_manage/constants/app_colors.dart';
import 'package:realway_manage/constants/app_assets.dart';
import 'package:realway_manage/constants/app_text_styles.dart';
import 'package:realway_manage/widget/map_navigation_page.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    return doc.data();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!;
        final name = user['name'] ?? "User";
        final email = user['email'] ?? "";
        final image = user['profile'] ?? "";

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: image.isNotEmpty
                        ? NetworkImage(image)
                        : const AssetImage(AppAssets.defaultUser) as ImageProvider,
                  ),
                  decoration: BoxDecoration(color: AppColors.primary),
                ),
                _drawerItem(Icons.person, "Profile", '/update-Profile'),
                _drawerItem(Icons.add_location_alt, "Add New Destination", '/add-destination'),
                _drawerItem(Icons.railway_alert, "Add New Gate", '/add-railway-gate'),
                const Spacer(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout", style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: Builder(
              builder: (context) => IconButton(
                icon: CircleAvatar(
                  backgroundImage: image.isNotEmpty
                      ? NetworkImage(image)
                      : const AssetImage(AppAssets.defaultUser) as ImageProvider,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text("Hi, $name", style: const TextStyle(color: Colors.black)),
          ),
          body: const MapNavigationWidget(),
        );
      },
    );
  }

  ListTile _drawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Get.toNamed(route),
    );
  }
}
