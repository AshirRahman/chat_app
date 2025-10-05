import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var messages = <Map<String, dynamic>>[].obs;
  late String friendUid;
  late String friendEmail;

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    friendUid = args['friendUid'];
    friendEmail = args['friendEmail'];
    listenToMessages();
  }

  String get chatId {
    final myUid = _auth.currentUser?.uid ?? '';
    final sorted = [myUid, friendUid]..sort();
    return sorted.join('_');
  }

  /// 🔹 Realtime listener for messages
  void listenToMessages() {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          messages.value = snapshot.docs.map((d) => d.data()).toList();
        });
  }

  /// 🔹 Send message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderUid': user.uid,
          'senderEmail': user.email,
          'receiverUid': friendUid,
          'receiverEmail': friendEmail,
          'text': text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}
