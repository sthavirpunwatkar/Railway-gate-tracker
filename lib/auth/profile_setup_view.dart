import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realway_manage/constants/app_colors.dart';
import 'package:realway_manage/constants/app_text_styles.dart';

class ProfileSetupView extends StatefulWidget {
  @override
  _ProfileSetupViewState createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final cityController = TextEditingController();

  File? _pickedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String imageUrl = "";
      if (_pickedImage != null) {
        final ref = FirebaseStorage.instance.ref().child(
          "profile_images/$uid.jpg",
        );
        await ref.putFile(_pickedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": nameController.text.trim(),
        "age": ageController.text.trim(),
        "city": cityController.text.trim(),
        "profile": imageUrl,
        "email": FirebaseAuth.instance.currentUser!.email,
        "created_at": Timestamp.now(),
      });

      Get.offAllNamed("/home");
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Setup Profile"),
        backgroundColor: AppColors.background,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    _pickedImage != null ? FileImage(_pickedImage!) : null,
                child:
                    _pickedImage == null
                        ? const Icon(
                          Icons.add_a_photo,
                          size: 30,
                          color: Colors.black54,
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 30),

            _buildTextField(nameController, "Name", Icons.person),
            const SizedBox(height: 16),
            _buildTextField(
              ageController,
              "Age",
              Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(cityController, "City", Icons.location_city),

            const SizedBox(height: 30),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(
                    "Continue to Home",
                    style: AppTextStyles.buttonText,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
