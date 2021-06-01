import 'dart:io';

import 'package:chat_firebase/models/chat_user.dart';
import 'package:chat_firebase/repository/chat_repository.dart';
import 'package:chat_firebase/viewmodels/chat_user_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class SettingViewModel extends ChangeNotifier {
  bool isLoading = false;
  ImagePicker picker = ImagePicker();
  File _image;
  String imageUrl;
  ChatUser user;
  var uuid = Uuid();
  ChatUserViewModel mChatUserViewModel;
  void resetData() {
    mChatUserViewModel = null;
    user = null;
    imageUrl = null;
    _image = null;
  }

  File getFile() {
    return _image;
  }

  void getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    } else {}
  }

  void updateInfo(String username, String description) async {
    isLoading = true;
    notifyListeners();
    print(user.name);
    imageUrl = await ChatRepo.postFile(
        imageFile: _image, folderPath: 'avatar_photos', fileName: user.uid);
    user.name = username;
    user.description = description;
    user.avatarUrl = imageUrl;
    await mChatUserViewModel.updateUserInfo(user);
    isLoading = false;
    notifyListeners();
  }

  update(ChatUserViewModel chatViewModel) {
    user = chatViewModel.currentChatUser;
    mChatUserViewModel = chatViewModel;
    if (user != null && user.avatarUrl != null)
      imageUrl = chatViewModel.currentChatUser.avatarUrl;
  }
}
