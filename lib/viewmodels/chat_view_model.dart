import 'dart:collection';
import 'dart:io';

import 'package:chat_firebase/models/chat_message.dart';
import 'package:chat_firebase/models/chat_room.dart';
import 'package:chat_firebase/models/chat_user.dart';
import 'package:chat_firebase/repository/chat_repository.dart';
import 'package:chat_firebase/viewmodels/chat_user_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatViewModel extends ChangeNotifier {
  ChatUser sender;
  ChatUser receiver;
  ChatRoom _mChatRoom;
  ChatUserViewModel mChatUserViewModel;
  Stream<List<Message>> messageStream;
  Uuid uuid = Uuid();
  String _content;
  bool isLoading = false;
  var picker = ImagePicker();
  File _image;
  bool isShowSticker = false;
  int type = 0; // type: 0 = text, 1 = image, 2 = sticker

  void setContent(int type, String value) {
    this.type = type;
    _content = value;
  }

  void addMessage(Message mes) {
    //if (!_messages.any((element) => element.messageID == mes.messageID))
    _mChatRoom.messages.add(mes);
  }

  void addAllMessages(List<Message> messages) {
    _mChatRoom.messages.addAll(messages);
  }

  UnmodifiableListView<Message> get messages =>
      UnmodifiableListView(_mChatRoom.messages);
  void resetData() {
    _image = null;
    isLoading = false;
    isShowSticker = false;
    messageStream = null;
  }

  void init() async {
    resetData();
  }

  Stream<List<Message>> getMessageStream() async* {
    await getChatRoom();
    Stream<QuerySnapshot<Map<String, dynamic>>> mesStream =
        await ChatRepo.getMessagesStream(roomID: _mChatRoom.chatID);
    await for (var doc in mesStream) {
      List<Message> temp = doc.docChanges
          .map((mes) => Message.fromJson(mes.doc.data()))
          .toList();
      yield temp;
    }
  }

  Future getChatRoom() async {
    DocumentSnapshot<Object> chatRoom = await ChatRepo.getChatRoom(
        senderID: sender.uid, receiverID: receiver.uid);
    _mChatRoom = ChatRoom.fromJson(chatRoom.data());
  }

  void setReceiver(ChatUser newReceiver) async {
    receiver = newReceiver;
  }

  void update(ChatUserViewModel userViewModel) {
    mChatUserViewModel = userViewModel;
    sender = mChatUserViewModel.currentChatUser;
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
    } else {}
  }

  void onPictureTap() async {
    await getImage(ImageSource.gallery);
    if (_image == null) return;
    isLoading = true;
    notifyListeners();
    String imageUrl = await ChatRepo.postFile(
        imageFile: _image, folderPath: 'chat_photos', fileName: uuid.v4());
    setContent(1, imageUrl);
    await sendMessage();
    isLoading = false;
    notifyListeners();
  }

  void onStickerTap() {
    isShowSticker = !isShowSticker;
    notifyListeners();
  }

  void onStickerSelected(String stickerName) {
    setContent(2, stickerName);
    onStickerTap();
    sendMessage();
  }

  void turnOffStickerPicker() {
    isShowSticker = false;
    notifyListeners();
  }

  Future<bool> onBackTap() async {
    bool canPop = true;
    if (isShowSticker) {
      isShowSticker = false;
      canPop = false;
      notifyListeners();
    }
    return Future.value(canPop);
  }

  void onSendTap(String text) {
    if (text.trim() == '') return;
    setContent(0, text);
    sendMessage();
  }

  Future sendMessage() async {
    Message newMes = Message(
        messageID: uuid.v4(),
        senderID: sender.uid,
        receiverID: receiver.uid,
        content: _content,
        type: type,
        timeStamp: DateTime.now().millisecondsSinceEpoch);
    var documentReference = FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(_mChatRoom.chatID)
        .collection('messages')
        .doc(newMes.messageID);
    await documentReference.set(newMes.toJson());
  }
}
