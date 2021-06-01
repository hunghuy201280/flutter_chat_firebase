import 'dart:collection';

import 'package:chat_firebase/models/chat_user.dart';
import 'package:chat_firebase/repository/chat_repository.dart';
import 'package:chat_firebase/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatUserViewModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<ChatUser> _users = [];
  User currentUser;
  ChatUser currentChatUser;
  ChatUser copyOfCurrentChatUser;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );
  void addUser(ChatUser newUSer) {
    _users.add(newUSer);
  }

  void addAllUser(List<ChatUser> users) {
    users.forEach((element) {
      _users.removeWhere((user) => user.uid == element.uid);
    });
    _users.addAll(users);
  }

  UnmodifiableListView<ChatUser> get users => UnmodifiableListView(_users);
  void logOut(Function showDialog, context) async {
    bool dialogResult = await showDialog();
    if (dialogResult) {
      await _auth.signOut();
      await _googleSignIn.signOut();
      Navigator.pushReplacementNamed(context, LoginScreen.id);
    }
  }

  Future<void> handleSignIn(Function NavToMainChat) async {
    try {
      GoogleSignInAccount account = await _googleSignIn.signIn();

      if (account != null) {
        await signInFirebase(account);
        _users.clear();
        notifyListeners();
        NavToMainChat();
      }
    } catch (error) {
      print(error);
    }
  }

  void signInFirebase(GoogleSignInAccount account) async {
    final GoogleSignInAuthentication authentication =
        await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: authentication.accessToken,
      idToken: authentication.idToken,
    );
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      currentUser = userCredential.user;

      await ChatRepo.addNewUserToFireStore(currentUser);
      await getCurrentChatUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // handle the error here
        print(e.code);
      } else if (e.code == 'invalid-credential') {
        // handle the error here
        print(e.code);
      }
    } catch (e) {
      // handle the error here
      print(e);
    }
  }

  void getCurrentChatUser() async {
    var curUser = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: currentUser.uid)
        .get();
    currentChatUser = ChatUser.fromJson(curUser.docs[0].data());
    copyOfCurrentChatUser = ChatUser.copyWith(currentChatUser);
  }

  void initLogin(Function navigateToMainScreen) async {
    if (_auth.currentUser != null) {
      currentUser = _auth.currentUser;
      await getCurrentChatUser();
      notifyListeners();
      _users.clear();
      navigateToMainScreen();
    }
  }

  Stream<List<ChatUser>> getUserStream() async* {
    Stream<QuerySnapshot<Map<String, dynamic>>> listUserStream =
        ChatRepo.getListUserStream(currentUser.uid);
    await for (var doc in listUserStream) {
      yield doc.docChanges.map((e) => ChatUser.fromJson(e.doc.data())).toList();
    }
  }

  Future updateUserInfo(ChatUser user) async {
    await ChatRepo.updateUserProfile(user);
    currentChatUser = user;
    notifyListeners();
  }
}
