import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostsListView extends StatelessWidget {
  final Query query;

  const PostsListView({required this.query, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Henüz gönderi yok.'));
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;

            return Card(
              // Kartın ana rengi (daha açık bir amber tonu)
              color: Colors.amber.shade50,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2, // Hafif gölge etkisi
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst kısım: Avatar + İsimler
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: post['profileImage'] != null
                              ? NetworkImage(post['profileImage'])
                              : const AssetImage('assets/images/default_profile.jpg')
                                  as ImageProvider,
                          radius: 24,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // İsim
                            Text(
                              post['name'] ?? 'Anonim',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.brown.shade800,
                              ),
                            ),
                            // Kullanıcı adı
                            Text(
                              '@${post['username'] ?? 'anonim'}',
                              style: TextStyle(
                                color: Colors.brown.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Gönderi içeriği
                    Text(
                      post['content'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Tarih göstergesi (timeago)
                    Text(
                      timeago.format(
                        post['timestamp']?.toDate() ?? DateTime.now(),
                      ),
                      style: TextStyle(
                        color: Colors.brown.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
