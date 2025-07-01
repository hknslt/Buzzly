import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ChatPage.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Messages")),
        body: const Center(child: Text("Lütfen oturum açın.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (_isDisposed) {
            // Widget dispose edildi, herhangi bir widget döndürmeden çık
            return const SizedBox.shrink();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz bir mesajınız yok.'));
          }

          final conversations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final chatDoc = conversations[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;
              final lastMessage = chatData['lastMessage'] ?? '';
              final lastMessageTime = (chatData['lastMessageTime'] as Timestamp?)
                  ?.toDate();
              final participants = chatData['participants'] as List<dynamic>;

              final receiverId = participants.firstWhere(
                (id) => id != currentUser.uid,
                orElse: () => null,
              );

              if (receiverId == null) {
                return const SizedBox.shrink();
              }

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(receiverId).get(),
                builder: (context, userSnapshot) {
                  if (_isDisposed) {
                    // Tekrar dispose kontrolü
                    return const SizedBox.shrink();
                  }

                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(title: Text('Yükleniyor...'));
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const ListTile(title: Text('Kullanıcı bilgisi yok.'));
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = userData['name'] ?? 'Kullanıcı';
                  final profileImage = userData.containsKey('profileImage')
                      ? userData['profileImage']
                      : 'https://via.placeholder.com/150';

                  String displayMessage =
                      lastMessage.isNotEmpty ? lastMessage : "Henüz mesaj yok.";
                  String displayTime = '';
                  if (lastMessageTime != null) {
                    final hour = lastMessageTime.hour.toString().padLeft(2, '0');
                    final minute =
                        lastMessageTime.minute.toString().padLeft(2, '0');
                    displayTime = "$hour:$minute";
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    title: Text(userName),
                    subtitle: Text(displayMessage),
                    trailing: displayTime.isNotEmpty
                        ? Text(displayTime, style: const TextStyle(color: Colors.grey))
                        : null,
                    onTap: () {
                      if (!_isDisposed) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatId: chatDoc.id,
                              receiverId: receiverId,
                              receiverName: userName,
                              receiverProfileImage: profileImage,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () => _startNewChat(context),
      ),
    );
  }

  void _startNewChat(BuildContext context) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final allUsers = await _firestore.collection('users').get();
    if (_isDisposed) return;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: allUsers.docs.length,
          itemBuilder: (context, index) {
            final userDoc = allUsers.docs[index];
            if (userDoc.id == currentUser.uid) return const SizedBox.shrink();

            final userData = userDoc.data() as Map<String, dynamic>;
            final userName = userData['name'] ?? 'Kullanıcı';
            final profileImage = userData.containsKey('profileImage')
                ? userData['profileImage']
                : 'https://via.placeholder.com/150';

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(profileImage),
              ),
              title: Text(userName),
              onTap: () async {
                Navigator.pop(context);
                final chatId =
                    await _createOrGetChatId(currentUser.uid, userDoc.id);
                if (!_isDisposed) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: chatId,
                        receiverId: userDoc.id,
                        receiverName: userName,
                        receiverProfileImage: profileImage,
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Future<String> _createOrGetChatId(String userId1, String userId2) async {
    final chatQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId1)
        .get();

    for (var doc in chatQuery.docs) {
      final participants = doc['participants'] as List<dynamic>;
      if (participants.contains(userId2)) {
        return doc.id;
      }
    }

    final newChat = await _firestore.collection('chats').add({
      'participants': [userId1, userId2],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return newChat.id;
  }
}
