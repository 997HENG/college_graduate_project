import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/chat/chat_bloc.dart';

class ChatTextField extends StatefulWidget {
  const ChatTextField({super.key});

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  final TextEditingController _controller = TextEditingController(text: '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 10.0, // 留一些空間在底部
            left: 16.0, // 左邊距
            right: 16.0, // 右邊距
            top: 10.0, // 增加一些上邊距來避免擠在一起
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255), // 輕微灰色背景
                    borderRadius: BorderRadius.circular(25.0), // 圓角
                  ),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      color: Colors.black87, // 設置文字顏色為較深的顏色
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none, // 去掉TextField預設的邊框
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 43, 42, 42)),
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
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    context
                        .read<ChatBloc>()
                        .add(ChatMessageSent(_controller.text));
                    _controller.text = '';
                  },
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
