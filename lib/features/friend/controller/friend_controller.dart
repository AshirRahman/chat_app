import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FriendController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  var allUsers = <Map<String, dynamic>>[].obs;
  var friends = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    listenToAllUsers();
    listenToFriends();
  }

  /// 🔹 Listen to all registered users in Firestore in real-time
  void listenToAllUsers() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      allUsers.value = snapshot.docs.map((d) => d.data()).toList();
    });
  }

  /// 🔹 Listen to the current user's friends list in real-time
  void listenToFriends() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .snapshots()
        .listen((snapshot) {
          friends.value = snapshot.docs.map((d) => d.data()).toList();
        });
  }

  /// 🔹 Add a friend (bidirectional)
  Future<void> addFriend(String friendUid, String friendEmail) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Add friend under current user
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(friendUid)
          .set({
            'uid': friendUid,
            'email': friendEmail,
            'addedAt': FieldValue.serverTimestamp(),
          });

      // Add current user under friend's list
      await _firestore
          .collection('users')
          .doc(friendUid)
          .collection('friends')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'email': user.email,
            'addedAt': FieldValue.serverTimestamp(),
          });

      Get.snackbar('Success', 'Friend added successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add friend: $e');
    }
  }

  /// 🔹 Open a real-time chat screen
  void openChat(String friendUid, String friendEmail) {
    Get.toNamed(
      '/chat',
      arguments: {'friendUid': friendUid, 'friendEmail': friendEmail},
    );
  }
}
