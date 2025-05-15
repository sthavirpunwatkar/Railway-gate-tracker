import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realway_manage/constants/app_colors.dart';
import 'package:realway_manage/constants/app_text_styles.dart';
import 'package:realway_manage/constants/app_assets.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final cityController = TextEditingController();

  File? _pickedImage;
  String? _imageUrl;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _loadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      ageController.text = data['age'] ?? '';
      cityController.text = data['city'] ?? '';
      setState(() {
        _imageUrl = data['profile'];
      });
    }
  }

  Future<void> _submitProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    setState(() => _isUploading = true);

    try {
      String imageUrl = _imageUrl ?? "";

      if (_pickedImage != null) {
        final ref = FirebaseStorage.instance.ref().child(
          "profile_images/$uid.jpg",
        );
        await ref.putFile(_pickedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "name": nameController.text.trim(),
        "age": ageController.text.trim(),
        "city": cityController.text.trim(),
        "profile": imageUrl,
      });

      Get.snackbar("✅ Success", "Profile updated successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = FirebaseAuth.instance.currentUser!.email;
    if (email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar("Success", "Password reset link sent to $email");
    } catch (e) {
      Get.snackbar("Error", "Failed to send reset email: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _pickedImage != null || (_imageUrl?.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Update Profile"),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_imageUrl != null && _imageUrl!.isNotEmpty
                                ? NetworkImage(_imageUrl!)
                                : const AssetImage(AppAssets.defaultUser))
                            as ImageProvider,
                child:
                    !hasImage ? const Icon(Icons.add_a_photo, size: 30) : null,
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 30),

            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _submitProfile,
                  icon: const Icon(Icons.save, color: AppColors.white),
                  label: const Text(
                    "Update Profile",
                    style: TextStyle(color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size.fromHeight(50),
                    textStyle: AppTextStyles.buttonText,
                  ),
                ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.lock_reset),
              label: const Text("Reset Password via Email"),
              onPressed: _sendPasswordResetEmail,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
