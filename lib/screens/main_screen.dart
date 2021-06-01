import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_firebase/constants.dart';
import 'package:chat_firebase/models/chat_user.dart';
import 'package:chat_firebase/screens/settings_screen.dart';
import 'package:chat_firebase/viewmodels/chat_user_viewmodel.dart';
import 'package:chat_firebase/viewmodels/chat_view_model.dart';
import 'package:chat_firebase/widgets/custom_dialog.dart';
import 'package:chat_firebase/widgets/user_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatelessWidget {
  static final id = 'MainScreen';
  PopupMenuItem getPopupItem({IconData icon, String title, int index}) {
    return PopupMenuItem(
        value: index,
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
            ),
            SizedBox(width: 5),
            Text(title),
          ],
        ));
  }

  Future<bool> showConfirmDialog(context) async {
    return showDialog(
      context: context,
      builder: (context) => ExitDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (index) {
              switch (index) {
                case 0:
                  //to setting screen
                  Navigator.pushNamed(context, SettingsScreen.id);
                  break;
                case 1:
                  //log out
                  Provider.of<ChatUserViewModel>(context, listen: false)
                      .logOut(() => showConfirmDialog(context), context);
                  break;
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) {
              return [
                getPopupItem(icon: Icons.settings, title: 'Settings', index: 0),
                getPopupItem(icon: Icons.logout, title: 'Log out', index: 1)
              ];
            },
          )
        ],
        title: Text(
          'MAIN',
          style: kAppbarTextStyle,
        ),
      ),
      body: UserStream(),
    );
  }
}

class UserStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatUser>>(
      stream: Provider.of<ChatUserViewModel>(context).getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
            ),
          );
        } else {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
              break;
            default:
              Provider.of<ChatUserViewModel>(context, listen: false)
                  .addAllUser(snapshot.data);
              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) {
                  ChatUser currentItem =
                      Provider.of<ChatUserViewModel>(context).users[index];
                  return UserDetail(
                    name: currentItem.name,
                    description: currentItem.description,
                    avatarUrl: currentItem.avatarUrl,
                    onTapCallback: () {
                      //nav to chat screen

                      Provider.of<ChatViewModel>(context, listen: false).init();
                      Provider.of<ChatViewModel>(context, listen: false)
                          .setReceiver(currentItem);
                      Navigator.pushNamed(context, ChatScreen.id);
                    },
                  );
                },
                itemCount: Provider.of<ChatUserViewModel>(context).users.length,
              );
              break;
          }
        }
      },
    );
  }
}
