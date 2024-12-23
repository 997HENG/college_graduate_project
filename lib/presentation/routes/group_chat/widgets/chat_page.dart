import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group/group.dart';
import '../../exam/exam_route.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatPage({super.key, required this.groupId, required this.groupName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50], // 设置背景颜色
      appBar: AppBar(
        backgroundColor: Colors.amber[200], // 修改标题背景颜色
        title: Text(widget.groupName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "測驗") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamRoute(groupId: widget.groupId),
                  ),
                );
              }
            },
            itemBuilder: (context) {
              return ['測驗', '公告', '作業'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('沒有訊息'));
                }

                final messages = snapshot.data!.docs
                    .map((doc) => Message.fromDocument(doc))
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message.senderId == currentUserId;

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color.fromARGB(255, 240, 188, 33)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isUser
                                ? const Radius.circular(12)
                                : const Radius.circular(0),
                            bottomRight: isUser
                                ? const Radius.circular(0)
                                : const Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDateTime(message.timestamp),
                              style: TextStyle(
                                color:
                                    isUser ? Colors.white70 : Colors.black54,
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
            ),
          ),
          ChatTextField(
            onSend: (String text) {
              FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .add({
                'text': text,
                'senderId': currentUserId,
                'timestamp': Timestamp.now(),
              });
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}

String formatDateTime(Timestamp timestamp) {
  final dateTime = timestamp.toDate();
  return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
}

class ChatTextField extends StatefulWidget {
  final void Function(String) onSend;

  const ChatTextField({super.key, required this.onSend});

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black45),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            width: 45.0,
            height: 45.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber[500],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  widget.onSend(_controller.text.trim());
                  _controller.clear();
                }
              },
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
