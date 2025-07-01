import 'package:firebase_deneme/pages/Drawer_pages/profile/widget/FollowersPage.dart';
import 'package:firebase_deneme/pages/Drawer_pages/profile/widget/FollowingPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchProfilePage extends StatefulWidget {
  final String userId;

  const SearchProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchProfilePageState createState() => _SearchProfilePageState();
}

class _SearchProfilePageState extends State<SearchProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (userDoc.exists) {
      final followingList = userDoc.data()?['following'] ?? [];
      setState(() {
        isFollowing = followingList.contains(widget.userId);
      });
    }
  }

  Future<void> _toggleFollow() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userRef = _firestore.collection('users').doc(currentUser.uid);
    final targetUserRef = _firestore.collection('users').doc(widget.userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final targetUserDoc = await transaction.get(targetUserRef);

      if (!userDoc.exists || !targetUserDoc.exists) return;

      final currentUserData = userDoc.data() as Map<String, dynamic>;
      final targetUserData = targetUserDoc.data() as Map<String, dynamic>;

      final followingList = currentUserData['following'] ?? [];
      final followersList = targetUserData['followers'] ?? [];

      if (isFollowing) {
        // Takibi bırak
        followingList.remove(widget.userId);
        followersList.remove(currentUser.uid);
      } else {
        // Takip et
        followingList.add(widget.userId);
        followersList.add(currentUser.uid);
      }

      transaction.update(userRef, {'following': followingList});
      transaction.update(targetUserRef, {'followers': followersList});
    });

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Kullanıcı bulunamadı."));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final profileImage = userData['profileImage'] ??
              'https://firebasestorage.googleapis.com/v0/b/fir-deneme-d53b4.appspot.com/o/default_profile.jpg?alt=media';
          final coverPhoto = userData['coverPhoto'] ??
              'https://firebasestorage.googleapis.com/v0/b/fir-deneme-d53b4.appspot.com/o/default_cover.jpg?alt=media';
          final name = userData['name'] ?? 'Kullanıcı';
          final username = userData['username'] ?? 'kullaniciadi';
          final bio = userData['bio'] ?? '';
          final followers = userData['followers'] ?? [];
          final following = userData['following'] ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kapak fotoğrafı
                Stack(
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        image: DecorationImage(
                          image: NetworkImage(coverPhoto),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            
                    Positioned(
                      bottom: -30,
                      left: 16,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profileImage),
                      ),
                    ),
                  ],
                ),

   
                const SizedBox(height: 40),

       
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@$username',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bio.isNotEmpty ? bio : '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
           
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                     
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowersPage(
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  '${followers.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Text('Takipçi'),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
            
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowingPage(
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  '${following.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Text('Takip Edilen'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
            
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _toggleFollow,
                          child: Text(
                            isFollowing ? "Takibi Bırak" : "Takip Et",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

