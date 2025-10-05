import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/friend_controller.dart';

class FriendScreen extends StatelessWidget {
  FriendScreen({super.key});

  final FriendController controller = Get.put(FriendController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: Obx(() {
        if (controller.allUsers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: controller.allUsers.map((user) {
            final isFriend = controller.friends.any(
              (f) => f['email'] == user['email'],
            );

            // Don’t show yourself
            if (user['email'] == controller.currentUser?.email) {
              return const SizedBox.shrink();
            }

            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user['email']),
              subtitle: Text(
                isFriend ? 'Friend' : 'Not friend',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isFriend)
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () =>
                          controller.addFriend(user['uid'], user['email']),
                    ),
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () =>
                        controller.openChat(user['uid'], user['email']),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
