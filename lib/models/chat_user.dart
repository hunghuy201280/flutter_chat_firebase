class ChatUser {
  String name, description, avatarUrl, uid;
  static final defaultAvatar =
      'https://firebasestorage.googleapis.com/v0/b/friendlychar-2df38.appspot.com/o/chat_photos%2Fimage%3A5774?alt=media&token=049a5a9a-fcc6-433a-b20a-07554f081d88';
  ChatUser({this.name, this.description, this.avatarUrl, this.uid});
  static ChatUser fromJson(Map<String, dynamic> input) {
    var Name, Description, AvatarUrl, Uid;
    Name = input['name'];
    AvatarUrl = input['avatarUrl'];
    Description = input['description'];
    Uid = input['uid'];
    return ChatUser(
        name: Name != null ? Name : 'No Name',
        description: Description != null ? Description : 'No Description',
        avatarUrl: AvatarUrl != null ? AvatarUrl : defaultAvatar,
        uid: Uid);
  }

  static ChatUser copyWith(ChatUser copyUser) {
    return ChatUser(
      name: copyUser.name,
      description: copyUser.description,
      avatarUrl: copyUser.avatarUrl,
      uid: copyUser.uid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
    };
  }
}
