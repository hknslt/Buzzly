import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_deneme/pages/Drawer_pages/profile/widget/liked_posts_list_view.dart';
import 'package:firebase_deneme/pages/Drawer_pages/profile/widget/posts_list_view.dart';
import 'package:firebase_deneme/pages/Drawer_pages/profile/widget/EditProfile_page.dart';
import 'package:firebase_deneme/pages/Drawer_pages/profile/widget/FollowersPage.dart';
import 'package:firebase_deneme/pages/Drawer_pages/profile/widget/FollowingPage.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> _userFuture;

  /// Animasyon controller ve animasyon tanımları
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot> _loadUserData() {
    return _firestore.collection('users').doc(widget.userId).get();
  }

  Future<void> _refreshData() async {
    setState(() {
      _userFuture = _loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TabController'ı manuel oluşturmak yerine DefaultTabController kullanacağız.
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.white, 

            appBar: AppBar(
              backgroundColor: Colors.amber.shade600,
              elevation: 0,
              title: const Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage()),
                    );
                    _refreshData();
                  },
                ),
              ],
            ),

            body: RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.brown,
              child: FutureBuilder<DocumentSnapshot>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Kullanıcı bilgileri bulunamadı.'));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final profileImage =
                      data['profileImage'] ?? 'assets/images/default_profile.jpg';
                  final coverPhoto =
                      data['coverPhoto'] ?? 'assets/images/default_cover.jpg';
                  final followers = (data['followers'] ?? []).length;
                  final following = (data['following'] ?? []).length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kapak ve Profil Fotoğrafı
                      Stack(
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: coverPhoto.startsWith('assets')
                                    ? AssetImage(coverPhoto) as ImageProvider
                                    : NetworkImage(coverPhoto),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -30,
                            left: 16,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.amber.shade50,
                              backgroundImage: profileImage.startsWith('assets')
                                  ? AssetImage(profileImage) as ImageProvider
                                  : NetworkImage(profileImage),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // İsim, kullanıcı adı ve bio
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? 'Ad yok',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${data['username'] ?? 'kullaniciadi'}',
                              style: TextStyle(
                                color: Colors.brown.shade400,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (data['bio'] != null && data['bio'].isNotEmpty)
                              Text(
                                data['bio'],
                                style: const TextStyle(fontSize: 16),
                              )
                            else
                              Text(
                                'Biyografi henüz eklenmedi.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.brown.shade300,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Takipçi / Takip Edilen
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FollowersPage(userId: widget.userId),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        '$followers',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.brown.shade800,
                                        ),
                                      ),
                                      Text(
                                        'Takipçi',
                                        style: TextStyle(
                                          color: Colors.brown.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FollowingPage(userId: widget.userId),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        '$following',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.brown.shade800,
                                        ),
                                      ),
                                      Text(
                                        'Takip Edilen',
                                        style: TextStyle(
                                          color: Colors.brown.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Sekmeler: Gönderiler & Beğenilenler
                      const SizedBox(height: 12),
                      Container(
                        color: Colors.white,
                        child: const TabBar(
                          labelColor: Colors.black,
                          indicatorColor: Colors.brown,
                          tabs: [
                            Tab(text: 'Gönderiler'),
                            Tab(text: 'Beğenilenler'),
                          ],
                        ),
                      ),

                      // Tab içerikleri
                      Expanded(
                        child: TabBarView(
                          children: [
                            PostsListView(
                              query: _firestore
                                  .collection('tweets')
                                  .where('userId', isEqualTo: widget.userId)
                                  .orderBy('timestamp', descending: true),
                            ),
                            LikedPostsListView(
                              query: _firestore
                                  .collection('tweets')
                                  .where('likedBy', arrayContains: widget.userId)
                                  .orderBy('timestamp', descending: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
