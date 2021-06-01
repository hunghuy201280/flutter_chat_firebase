import 'chat_message.dart';

class ChatRoom {
  String chatID;
  List<Message> messages = [];

  ChatRoom({this.chatID, this.messages});

  ChatRoom.fromJson(Map<String, dynamic> json) {
    chatID = json['chatID'];
    if (json['messages'] != null) {
      messages = [];
      json['messages'].forEach((v) {
        messages.add(new Message.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatID'] = this.chatID;
    if (this.messages != null) {
      data['messages'] = this.messages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
