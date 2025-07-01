import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  File? _coverPhoto;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      final data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        nameController.text = data['name'] ?? '';
        bioController.text = data['bio'] ?? '';
        locationController.text = data['location'] ?? '';
        websiteController.text = data['website'] ?? '';
        birthdateController.text = data['birthdate'] ?? '';
      }
    }
  }

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _coverPhoto = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      String? profileImageUrl;
      String? coverPhotoUrl;

      if (_profileImage != null) {
        profileImageUrl =
            await _uploadImage(_profileImage!, 'users/${user.uid}/profile.jpg');
      }

      if (_coverPhoto != null) {
        coverPhotoUrl =
            await _uploadImage(_coverPhoto!, 'users/${user.uid}/cover.jpg');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'name': nameController.text.trim(),
        'bio': bioController.text.trim(),
        'location': locationController.text.trim(),
        'website': websiteController.text.trim(),
        'birthdate': birthdateController.text.trim(),
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
        if (coverPhotoUrl != null) 'coverPhoto': coverPhotoUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Kaydet',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery, false),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        image: _coverPhoto != null
                            ? DecorationImage(
                                image: FileImage(_coverPhoto!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _coverPhoto == null
                          ? const Center(
                              child: Icon(Icons.camera_alt, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery, true),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/fir-deneme-d53b4.firebasestorage.app/o/default_profile.jpg?alt=media&token=bd59788c-2bff-41ff-a1e8-681753baa894'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              _buildTextField(
                controller: nameController,
                label: 'Ad Soyad',
                hint: 'Adınızı ve Soyadınızı Girin',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: bioController,
                label: 'Biyografi',
                hint: 'Kendinizi Tanımlayın',
                maxLength: 160,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: locationController,
                label: 'Lokasyon',
                hint: 'Nerede yaşıyorsunuz?',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: websiteController,
                label: 'Web Sitesi',
                hint: 'Web sitenizi girin',
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    birthdateController.text =
                        "${selectedDate.toLocal()}".split(' ')[0];
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: birthdateController,
                    label: 'Doğum Tarihi',
                    hint: 'Doğum tarihinizi seçin',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            counterText: maxLength != null ? '' : null,
          ),
          maxLength: maxLength,
        ),
      ],
    );
  }
}
