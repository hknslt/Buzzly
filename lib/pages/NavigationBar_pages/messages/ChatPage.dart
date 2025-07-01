import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;
  final String receiverProfileImage;

  const ChatPage({
    Key? key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverProfileImage,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverProfileImage),
            ),
            const SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(currentUser),
        ],
      ),
    );
  }

  /// Sohbet içerisindeki mesajların listesi (dinamik olarak Firestore'dan çekilir).
  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Henüz mesaj yok.'));
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true, // Son mesajlar altta birikecek şekilde
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            final isSender = message['senderId'] == _auth.currentUser?.uid;

            return Align(
              alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSender ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message['content'] ?? '',
                  style: TextStyle(
                    color: isSender ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Mesaj giriş alanı (TextField + Gönder butonu).
  Widget _buildMessageInput(User? currentUser) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Metin giriş alanı
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Mesaj yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Gönder butonu
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage(currentUser);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Yeni mesajı Firestore'a yazar, `lastMessage` ve `lastMessageTime` alanlarını günceller.
  void _sendMessage(User? currentUser) async {
    if (currentUser == null) return;

    final messageContent = _messageController.text.trim();
    _messageController.clear(); // Metin alanını temizle

    final messageData = {
      'senderId': currentUser.uid,
      'receiverId': widget.receiverId,
      'content': messageContent,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // 'messages' alt koleksiyonuna ekle
    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(messageData);

    // Sohbetin anahat bilgilerini güncelle
    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': messageContent,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }
}
