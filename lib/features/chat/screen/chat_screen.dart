import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController controller = Get.put(ChatController());
  final TextEditingController messageInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.friendEmail)),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              if (msgs.isEmpty) {
                return const Center(child: Text('No messages yet'));
              }

              return ListView.builder(
                reverse: true,
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final msg = msgs[index];
                  final isMine =
                      msg['senderUid'] == controller.currentUser?.uid;
                  return Align(
                    alignment: isMine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMine
                            ? Colors.blueAccent.withOpacity(0.8)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: isMine ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageInput,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      controller.sendMessage(messageInput.text);
                      messageInput.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
