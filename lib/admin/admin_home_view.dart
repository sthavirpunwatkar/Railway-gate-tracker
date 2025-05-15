import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realway_manage/admin/manage_gates_page.dart';
import 'package:realway_manage/admin/manage_destinations_page.dart';
import 'package:realway_manage/constants/app_colors.dart';
import 'package:realway_manage/constants/app_text_styles.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    ManageGatesPage(),
    ManageDestinationsPage(),
  ];

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: Text(
          _selectedIndex == 0 ? "Manage Railway Gates" : "Manage Destinations",
          style: AppTextStyles.title.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Colors.grey, width: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.security),
              label: 'Manage Gates',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Manage Destinations',
            ),
          ],
        ),
      ),
    );
  }
}
