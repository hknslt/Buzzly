import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailedTweetPage extends StatefulWidget {
  final String tweetId;
  final Map<String, dynamic> tweetData;

  const DetailedTweetPage({
    required this.tweetId,
    required this.tweetData,
    Key? key,
  }) : super(key: key);

  @override
  _DetailedTweetPageState createState() => _DetailedTweetPageState();
}

class _DetailedTweetPageState extends State<DetailedTweetPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();

  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final tweetRef = _firestore.collection('tweets').doc(widget.tweetId);
    final doc = await tweetRef.get();

    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _likeCount = data?['likes'] ?? 0;
        _isLiked = (data?['likedBy'] as List?)?.contains(user.uid) ?? false;
      });
    }
  }

  void _toggleLike() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final tweetRef = _firestore.collection('tweets').doc(widget.tweetId);

    try {
      if (_isLiked) {
        await tweetRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        await tweetRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([user.uid]),
        });
      }

      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Beğeni sırasında hata oluştu: $e')),
      );
    }
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      final name = userData['name'] ?? 'Anonim';
      final profileImage = userData['profileImage'] ??
          'https://firebasestorage.googleapis.com/v0/b/fir-deneme-d53b4.firebasestorage.app/o/default_profile.jpg?alt=media&token=bd59788c-2bff-41ff-a1e8-681753baa894';

      await _firestore
          .collection('tweets')
          .doc(widget.tweetId)
          .collection('comments')
          .add({
        'content': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'name': name,
        'profileImage': profileImage,
      });

      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum eklendi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum eklerken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tweet = widget.tweetData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tweet Detayı'),
        centerTitle: true,
        backgroundColor: Colors.amber.shade600,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tweet İçerik Kartı
            Card(
              color: Colors.amber.shade50,
              margin: const EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil, ad-soyad, kullanıcı adı
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            tweet['profileImage'] ??
                                'https://firebasestorage.googleapis.com/v0/b/fir-deneme-d53b4.firebasestorage.app/o/default_profile.jpg?alt=media&token=bd59788c-2bff-41ff-a1e8-681753baa894',
                          ),
                          radius: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tweet['name'] ?? 'Anonim',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tweet['username'] ?? '@anonim',
                                style: TextStyle(
                                  color: Colors.brown.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tweet içeriği (metin)
                    if (tweet['content'] != null &&
                        tweet['content'].toString().isNotEmpty)
                      Text(
                        tweet['content'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown.shade700,
                        ),
                      ),
                    // Tweet resmi
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
                    const Divider(),
                    // Beğeni & yorum ikonları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isLiked
                                    ? Icons.thumb_up_alt
                                    : Icons.thumb_up_alt_outlined,
                                color: _isLiked ? Colors.blue : Colors.grey,
                              ),
                              onPressed: _toggleLike,
                            ),
                            Text(
                              '$_likeCount',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          color: Colors.grey,
                          onPressed: () {
                            // Altta yer alan yorum alanına odaklanma vs. yapılabilir
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Yorum Ekleme Alanı (Card içinde)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                color: Colors.amber.shade50,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: 'Yorum ekle',
                          labelStyle: TextStyle(color: Colors.brown.shade800),
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber.shade600),
                          ),
                        ),
                        maxLines: null,
                        style: TextStyle(color: Colors.brown.shade800),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _addComment,
                          child: const Text(
                            'Yorum Yap',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Yorumlar Listesi
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tweets')
                  .doc(widget.tweetId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('Henüz yorum yok.')),
                  );
                }

                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final comment =
                        comments[index].data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.amber.shade50,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            comment['profileImage'] ??
                                'https://firebasestorage.googleapis.com/v0/b/fir-deneme-d53b4.firebasestorage.app/o/default_profile.jpg?alt=media&token=bd59788c-2bff-41ff-a1e8-681753baa894',
                          ),
                        ),
                        title: Text(
                          comment['name'] ?? 'Anonim',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        subtitle: Text(
                          comment['content'] ?? '',
                          style: TextStyle(color: Colors.brown.shade700),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
