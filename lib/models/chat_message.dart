class Message {
  String messageID;
  String senderID;
  String receiverID;
  String content; // type: 0 = text, 1 = imageUrl, 2 = stickername
  int timeStamp;
  int type; // type: 0 = text, 1 = image, 2 = sticker

  Message(
      {this.messageID,
      this.senderID,
      this.receiverID,
      this.content,
      this.timeStamp,
      this.type});

  Message.fromJson(Map<String, dynamic> json) {
    messageID = json['messageID'];
    senderID = json['senderID'];
    receiverID = json['receiverID'];
    content = json['content'];
    timeStamp = json['timeStamp'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageID'] = this.messageID;
    data['senderID'] = this.senderID;
    data['receiverID'] = this.receiverID;
    data['content'] = this.content;
    data['timeStamp'] = this.timeStamp;
    data['type'] = this.type;
    return data;
  }
}
