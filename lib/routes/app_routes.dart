import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:realway_manage/admin/admin_home_view.dart';
import 'package:realway_manage/admin/edit_gate_page.dart';
import 'package:realway_manage/views/add_destination_page.dart';
import 'package:realway_manage/views/add_railway_gate_page.dart';
import 'package:realway_manage/views/home_view.dart';
import 'package:realway_manage/auth/login_view.dart';
import 'package:realway_manage/auth/profile_setup_view.dart';
import 'package:realway_manage/views/profile_update_page.dart';
import 'package:realway_manage/auth/signup_view.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/login', page: () => LoginView()),
    GetPage(name: '/signup', page: () => SignupView()),
    // GetPage(name: '/forgot', page: () => ForgotPasswordView()),
    GetPage(name: '/profile', page: () => ProfileSetupView()),
    GetPage(name: '/home', page: () => HomeView()),
    GetPage(name: '/add-destination', page: () => const AddDestinationPage()),
    GetPage(name: '/add-railway-gate', page: () => const AddRailwayGatePage()),
    GetPage(name: '/update-Profile', page: () => const ProfileUpdatePage()),
    GetPage(name: '/admin-home', page: () => const AdminHomeView()),
    GetPage(name: '/edit-gates', page: () => const EditGatePage(gateData: {},)),

  ];
}
