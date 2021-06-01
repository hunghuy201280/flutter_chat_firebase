import 'dart:io';

import 'package:chat_firebase/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatRepo {
  static Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getMessagesStream(
      {@required String roomID}) async {
    Stream<QuerySnapshot<Map<String, dynamic>>> chatStream;
    chatStream = FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(roomID)
        .collection('messages')
        .orderBy('timeStamp', descending: false)
        .snapshots();
    return chatStream;
  }

  static Future<DocumentSnapshot<Object>> getChatRoom(
      {@required String senderID, @required String receiverID}) async {
    String chatRoomId;
    if (senderID.hashCode <= receiverID.hashCode) {
      chatRoomId = '$senderID-$receiverID';
    } else {
      chatRoomId = '$receiverID-$senderID';
    }
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .set({'chatID': chatRoomId});
    DocumentSnapshot<Object> chatRoom;
    chatRoom = await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .get();
    return chatRoom;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getListUserStream(
      String currentUserID) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: currentUserID)
        .snapshots();
  }

  static Future updateUserProfile(ChatUser user) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  static Future<String> postFile(
      {@required File imageFile,
      @required String folderPath,
      @required String fileName}) async {
    Reference reference =
        FirebaseStorage.instance.ref().child(folderPath).child(fileName);

    TaskSnapshot storageTaskSnapshot = await reference.putFile(imageFile);

    String dowUrl = await storageTaskSnapshot.ref.getDownloadURL();

    return dowUrl;
  }

  static void addNewUserToFireStore(User user) async {
    final firestore = FirebaseFirestore.instance;
    final result = await firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get();

    if (result.docs.isEmpty) {
      firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName,
        'avatarUrl': user.photoURL
      });
    }
  }
}
