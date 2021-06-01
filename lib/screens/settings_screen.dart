import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_firebase/viewmodels/chat_user_viewmodel.dart';
import 'package:chat_firebase/viewmodels/setting_viewmodel.dart';
import 'package:chat_firebase/widgets/update_info_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class SettingsScreen extends StatelessWidget {
  static final id = 'SettingsScreen';
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text =
        Provider.of<ChatUserViewModel>(context).currentChatUser.name;
    descriptionController.text =
        Provider.of<ChatUserViewModel>(context).currentChatUser.description;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: kAppbarTextStyle,
        ),
      ),
      body: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 30,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: GestureDetector(
                onTap: () {
                  Provider.of<SettingViewModel>(context, listen: false)
                      .getImage(ImageSource.gallery);
                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage:
                      Provider.of<SettingViewModel>(context).getFile() == null
                          ? CachedNetworkImageProvider(
                              Provider.of<SettingViewModel>(context).imageUrl,
                            )
                          : FileImage(
                              Provider.of<SettingViewModel>(context).getFile()),
                ),
              ),
            ),
            UpdateInfoTextField(
              textController: nameController,
              title: 'Nickname',
              hintText: 'Your name',
            ),
            UpdateInfoTextField(
              textController: descriptionController,
              title: 'About me',
              hintText: 'Description',
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(100, 40),
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                  onPressed: () async {
                    await Provider.of<SettingViewModel>(context, listen: false)
                        .updateInfo(
                            nameController.text, descriptionController.text);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'UPDATE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
        Visibility(
          visible: Provider.of<SettingViewModel>(context).isLoading,
          child: Center(
            child: SpinKitHourGlass(
              color: kOrange,
            ),
          ),
        ),
      ]),
    );
  }
}
