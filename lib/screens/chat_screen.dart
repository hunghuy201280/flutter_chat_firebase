import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_firebase/models/chat_message.dart';
import 'package:chat_firebase/viewmodels/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class ChatScreen extends StatelessWidget {
  static final id = 'ChatScreen';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Provider.of<ChatViewModel>(context, listen: false).onBackTap,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Provider.of<ChatViewModel>(context).receiver.name,
            style: kAppbarTextStyle,
          ),
        ),
        body: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ChatContent(),
              StickerPicker(),
              BottomChatBar(),
            ],
          ),
          Loading(),
        ]),
      ),
    );
  }
}

class StickerPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: Provider.of<ChatViewModel>(context).isShowSticker,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: double.infinity,
        height: 200,
        color: Colors.grey[200],
        child: SingleChildScrollView(
          child: Wrap(
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            runSpacing: 30,
            spacing: 20,
            direction: Axis.horizontal,
            children: [
              for (String stickerName in kStickers)
                GestureDetector(
                  onTap: () {
                    Provider.of<ChatViewModel>(context, listen: false)
                        .onStickerSelected(stickerName);
                  },
                  child: Image.asset(
                    'images/$stickerName',
                    fit: BoxFit.scaleDown,
                    width: 100,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: Provider.of<ChatViewModel>(context).isLoading,
      child: Center(
        child: SpinKitCubeGrid(
          color: kYellow,
        ),
      ),
    );
  }
}

class ChatContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('chat content rebuild');
    return Expanded(
      child: StreamBuilder<List<Message>>(
        stream: Provider.of<ChatViewModel>(context, listen: false)
            .getMessageStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text('No Message'),
            );
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                    child: SpinKitRing(
                  color: kYellow,
                ));
                break;
              default:
                Provider.of<ChatViewModel>(context)
                    .addAllMessages(snapshot.data);
                return MessagesListBuilder();
                break;
            }
          }
        },
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  final Message mes;

  const MessageItem({@required this.mes});

  @override
  Widget build(BuildContext context) {
    bool isMe = mes.senderID == Provider.of<ChatViewModel>(context).sender.uid;
    return Row(
      textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: CircleAvatar(
            radius: 20,
            backgroundImage: isMe
                ? CachedNetworkImageProvider(
                    Provider.of<ChatViewModel>(context).sender.avatarUrl)
                : CachedNetworkImageProvider(
                    Provider.of<ChatViewModel>(context).receiver.avatarUrl),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        mes.type == 0
            // Text
            ? Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: isMe ? Colors.lightBlueAccent : Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Text(
                        mes.content,
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black54,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ),
              )
            : mes.type == 1
                // Image
                ? Container(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, string) {
                          return Container(
                            child: Center(
                              child: SpinKitFoldingCube(
                                color: kYellow,
                              ),
                            ),
                            width: 200.0,
                            height: 200.0,
                            padding: EdgeInsets.all(70.0),
                          );
                        },
                        errorWidget: (context, string, _) {
                          return Material(
                            child: Image.asset(
                              'images/img_not_available.png',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          );
                        },
                        imageUrl: mes.content,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
                  )
                // Sticker
                : Container(
                    child: new Image.asset(
                      'images/${mes.content}',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                    margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
                  )
      ],
    );
  }
}

class MessagesListBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Message> messages =
        Provider.of<ChatViewModel>(context).messages.reversed.toList();
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageItem(mes: messages[index]);
      },
      reverse: true,
    );
  }
}

class BottomChatBar extends StatefulWidget {
  @override
  _BottomChatBarState createState() => _BottomChatBarState();
}

class _BottomChatBarState extends State<BottomChatBar> {
  TextEditingController textController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).addListener(() {
      Provider.of<ChatViewModel>(context, listen: false).turnOffStickerPicker();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          GestureDetector(
            child: Icon(Icons.image, color: Colors.blue[900]),
            onTap: () {
              Provider.of<ChatViewModel>(context, listen: false).onPictureTap();
            },
          ),
          SizedBox(
            width: 20,
          ),
          GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                Provider.of<ChatViewModel>(context, listen: false)
                    .onStickerTap();
              },
              child: Icon(Icons.emoji_emotions, color: Colors.blue[900])),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
              child: Icon(Icons.send, color: Colors.blue[900]),
              onTap: () {
                Provider.of<ChatViewModel>(context, listen: false)
                    .onSendTap(textController.text);
                textController.clear();
              }),
        ],
      ),
    );
  }
}
