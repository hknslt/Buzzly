import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post/DetailedTweetPage.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tweetleri yenilemek için (Pull-to-Refresh)
  Future<void> _refreshTweets() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // Tweet beğenme / beğeniyi geri alma işlemi
  void _likeTweet(String tweetId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final tweetRef =
          FirebaseFirestore.instance.collection('tweets').doc(tweetId);
      final tweetSnapshot = await tweetRef.get();
      final tweetData = tweetSnapshot.data() as Map<String, dynamic>;

      final likedBy = List<String>.from(tweetData['likedBy'] ?? []);
      if (likedBy.contains(currentUser.uid)) {
        likedBy.remove(currentUser.uid);
        await tweetRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': likedBy,
        });
      } else {
        likedBy.add(currentUser.uid);
        await tweetRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': likedBy,
        });
      }
    } catch (e) {
      print('Beğeni sırasında hata: $e');
    }
  }

  bool _isLiked(Map<String, dynamic> tweetData) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final likedBy = List<String>.from(tweetData['likedBy'] ?? []);
    return likedBy.contains(currentUser.uid);
  }

  // Tweeti kaydetme işlemi (Saved Tweets)
  void _saveTweet(String tweetId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      await userRef.update({
        'savedTweets': FieldValue.arrayUnion([tweetId]),
      });
      print('Tweet kaydedildi!');
    } catch (e) {
      print('Tweet kaydedilirken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshTweets,
        color: Colors.brown, // Yüklenirken kahverengi bir progress göstergesi
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tweets')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Henüz tweet yok.'));
            }

            final tweets = snapshot.data!.docs;

            return ListView.builder(
              itemCount: tweets.length,
              itemBuilder: (context, index) {
                final tweet = tweets[index].data() as Map<String, dynamic>;
                final tweetId = tweets[index].id;
                final isLiked = _isLiked(tweet);

                return GestureDetector(
                  onTap: () {
                    // Tweet detay sayfasına yönlendir
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedTweetPage(
                          tweetId: tweetId,
                          tweetData: tweet,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.amber.shade50, // Kart arka plan rengi
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2, // Hafif gölge
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Üst kısım (Avatar + İsimler + İçerik)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                // Profil resmi eğer DB'de yoksa local asset'i kullan
                                backgroundImage: tweet['profileImage'] != null
                                    ? NetworkImage(tweet['profileImage'])
                                    : const AssetImage(
                                        'assets/images/default_profile.jpg')
                                        as ImageProvider,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kullanıcı Adı
                                    Row(
                                      children: [
                                        Text(
                                          tweet['name'] ?? 'Anonim',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.brown.shade800,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          tweet['username'] ?? '@anonim',
                                          style: TextStyle(
                                            color: Colors.brown.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // Tweet İçeriği
                                    Text(
                                      tweet['content'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.brown.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Timestamp
                                    Text(
                                      timeago.format(
                                        tweet['timestamp']?.toDate() ??
                                            DateTime.now(),
                                      ),
                                      style: TextStyle(
                                        color: Colors.brown.shade300,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Gönderide resim varsa
                          if (tweet['image'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  tweet['image'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                          const SizedBox(height: 10),

                          // Beğeni ve Kaydet butonu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _likeTweet(tweetId),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isLiked
                                              ? Icons.thumb_up_alt
                                              : Icons.thumb_up_alt_outlined,
                                          size: 20,
                                          color: isLiked
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${tweet['likes'] ?? 0}',
                                          style:
                                              const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailedTweetPage(
                                            tweetId: tweetId,
                                            tweetData: tweet,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.comment_outlined,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.bookmark_border),
                                color: Colors.grey,
                                onPressed: () => _saveTweet(tweetId),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
