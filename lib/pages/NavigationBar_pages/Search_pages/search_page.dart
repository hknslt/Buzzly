import 'package:firebase_deneme/pages/Drawer_pages/profile/SearchProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for tweets or users',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (query) {
            setState(() {
              _searchQuery = query.trim().toLowerCase();
            });
          },
        ),
      ),
      body: _searchQuery.isEmpty
          ? const Center(child: Text('Search for tweets or users.'))
          : _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        _buildUserResults(),
        const Divider(),
        _buildTweetResults(),
      ],
    );
  }

  Widget _buildUserResults() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs.where((user) {
            final userData = user.data() as Map<String, dynamic>;
            final name = userData['name']?.toLowerCase() ?? '';
            final username = userData['username']?.toLowerCase() ?? '';
            return name.contains(_searchQuery) || username.contains(_searchQuery);
          }).toList();

          if (users.isEmpty) {
            return const Center(child: Text('No matching users found.'));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final user = userDoc.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    user['profileImage'] ??
                        'https://firebasestorage.googleapis.com/.../default_profile.jpg',
                  ),
                ),
                title: Text(user['name'] ?? 'Anonymous'),
                subtitle: Text('@${user['username']}'),
                onTap: () {
                  // Kullanıcı profiline yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchProfilePage(userId: userDoc.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTweetResults() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tweets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tweets found.'));
          }

          final tweets = snapshot.data!.docs.where((tweet) {
            final tweetData = tweet.data() as Map<String, dynamic>;
            final content = tweetData['content']?.toLowerCase() ?? '';
            return content.contains(_searchQuery);
          }).toList();

          if (tweets.isEmpty) {
            return const Center(child: Text('No matching tweets found.'));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: tweets.length,
            itemBuilder: (context, index) {
              final tweetDoc = tweets[index];
              final tweet = tweetDoc.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    tweet['profileImage'] ??
                        'https://firebasestorage.googleapis.com/.../default_profile.jpg',
                  ),
                ),
                title: Text(tweet['name'] ?? 'Anonymous'),
                subtitle: Text(tweet['content'] ?? ''),
                onTap: () {
                  // Detaylı tweet sayfasına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TweetDetailPage(tweetId: tweetDoc.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class TweetDetailPage extends StatelessWidget {
  final String tweetId;

  TweetDetailPage({required this.tweetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tweet Detail")),
      body: Center(
        child: Text('Tweet Detail for ID: $tweetId'),
        // Firebase'den tweetId ile ilgili detayları çekip burada göster.
      ),
    );
  }
}
