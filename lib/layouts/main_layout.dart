import 'package:firebase_deneme/pages/Drawer_pages/followRequests.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/NavigationBar_pages/post/CreatePost_page.dart';
import '../pages/NavigationBar_pages/home_page.dart';
import '../pages/NavigationBar_pages/Search_pages/search_page.dart';
import '../pages/NavigationBar_pages/notifications_page.dart';
import '../pages/NavigationBar_pages/messages/messages_page.dart';
import '../pages/Drawer_pages/profile/profile_page.dart';
import '../pages/Drawer_pages/saved_page.dart';
import '../pages/Drawer_pages/settings/settings_page.dart';
import '../pages/log/login_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentIndex = 0; // Alt menüdeki aktif sekme
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Alt menüde gösterilecek sayfalar
  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    NotificationsPage(),
    MessagesPage(),
  ];

  // Kullanıcı bilgileri
  String userName = "Kullanıcı Adı";
  String userEmail = "kullanici@mail.com";
  String profileImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/fir-deneme-d53b4.firebasestorage.app/o/default_profile.jpg?alt=media&token=bd59788c-2bff-41ff-a1e8-681753baa894";
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Animasyon controller
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

    // Animasyonu başlat
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Firestore'dan kullanıcı verilerini çekme
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          userName = data?['name'] ?? "Kullanıcı Adı";
          userEmail = data?['email'] ?? "kullanici@mail.com";
          profileImageUrl = data?['profileImage'] ??
              "https://firebasestorage.googleapis.com/v0/b/fir-deneme-d53b4.firebasestorage.app/o/default_profile.jpg?alt=media&token=bd59788c-2bff-41ff-a1e8-681753baa894";
          userId = user.uid;
        });
      }
    }
  }

  /// Çıkış yapma işlemi
  void _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Scaffold(
          backgroundColor: Colors.amber.shade50,

          appBar: AppBar(
            title: const Text(
              'Buzzly',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.amber.shade600, 
          ),

          // Drawer
          drawer: _buildDrawer(context),

          // Asıl sayfa içeriği
          body: _pages[_currentIndex],

          // Tweet oluşturma butonu
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.amber.shade600,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePostPage()),
              );
            },
            child: const Icon(Icons.add, color: Colors.black),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          // Alt menü
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }

  /// Drawer (yandan açılan menü)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.amber.shade50,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Üst kısım
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber.shade600,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            accountEmail: Text(userEmail),
          ),

          // Profil
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userId: userId),
                ),
              );
            },
          ),

          // Saved
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Saved'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedPage()),
              );
            },
          ),
          // Takip İstekleri
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Takip İstekleri'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowRequestsPage(),
                ),
              );
            },
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(),
          ),
        ],
      ),
    );
  }

  /// Alt Navigation Bar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() {
        _currentIndex = index;
      }),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.brown.shade50, 
      selectedItemColor: Colors.brown.shade700,
      unselectedItemColor: Colors.brown.shade300,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
      ],
    );
  }
}
