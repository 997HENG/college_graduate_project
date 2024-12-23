import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_model/llm_model.dart';
import 'package:tutor_app/blocs/llm/llm_bloc.dart';

class GemmaChatInput extends StatefulWidget {
  const GemmaChatInput({super.key});

  @override
  State<GemmaChatInput> createState() => _GemmaChatInputState();
}

class _GemmaChatInputState extends State<GemmaChatInput> {
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
            top: 5.0, // 增加一些上邊距來避免擠在一起
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: Builder(
                  builder: (context) {
                    final llmIsTyping = context
                        .select((LlmBloc bloc) => bloc.state.isLlmTyping);

                    final widget = switch (llmIsTyping) {
                      true => Container(
                          width: 45.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue, // 背景顏色
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            color: Colors.white,
                            Icons.radio_button_checked,
                          ),
                        ),
                      false => Container(
                          width: 45.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue, // 背景顏色
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
                              context.read<LlmBloc>().add(
                                    LlmMessageAdded(
                                      ChatMessage.user(_controller.text),
                                    ),
                                  );
                              _controller.text = '';
                            },
                            icon: const Icon(
                              color: Colors.white,
                              Icons.arrow_forward,
                            ),
                          ),
                        ),
                    };

                    return widget;
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
