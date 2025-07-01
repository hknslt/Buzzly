import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _tweetController = TextEditingController();
  int _characterCount = 0;
  bool _isTweetButtonEnabled = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  void _postTweet() async {
    if (_tweetController.text.isNotEmpty || _selectedImage != null) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı oturum açmamış.')),
        );
        return;
      }

      try {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final userMap = userData.data() as Map<String, dynamic>?;

        if (userMap == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kullanıcı bilgileri bulunamadı.')),
          );
          return;
        }

        String? imageUrl;
        if (_selectedImage != null) {
          final fileName = 'tweets/${user.uid}/${DateTime.now().toIso8601String()}';
          final ref = FirebaseStorage.instance.ref().child(fileName);
          await ref.putFile(_selectedImage!);
          imageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('tweets').add({
          'content': _tweetController.text.trim(),
          'image': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
          'name': userMap['name'] ?? 'Anonim',
          'username': userMap['username'] ?? '@anonim',
          'profileImage': userMap['profileImage'] ?? 'assets/images/default_profile.jpg',
          'likes': 0,
          'retweets': 0,
          'comments': 0,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tweet başarıyla gönderildi!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isTweetButtonEnabled = _tweetController.text.isNotEmpty || _selectedImage != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Tweet'),
        actions: [
          TextButton(
            onPressed: _isTweetButtonEnabled ? _postTweet : null,
            child: Text(
              'Tweet',
              style: TextStyle(
                color: _isTweetButtonEnabled ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tweetController,
              maxLines: null,
              maxLength: 280,
              decoration: const InputDecoration(
                hintText: "What's happening?",
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: (text) {
                setState(() {
                  _characterCount = text.length;
                  _isTweetButtonEnabled = text.isNotEmpty || _selectedImage != null;
                });
              },
            ),
            if (_selectedImage != null)
              Stack(
                children: [
                  Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _isTweetButtonEnabled = _tweetController.text.isNotEmpty;
                        });
                      },
                    ),
                  ),
                ],
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: _pickImage,
                ),
                Text(
                  '${_characterCount}/280',
                  style: TextStyle(
                    color: _characterCount > 280 ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
