import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_firebase/constants.dart';
import 'package:chat_firebase/viewmodels/chat_user_viewmodel.dart';
import 'package:chat_firebase/screens/chat_screen.dart';
import 'package:chat_firebase/viewmodels/setting_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  static final id = 'LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ChatUserViewModel>(context, listen: false).initLogin(() {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Provider.of<SettingViewModel>(context, listen: false).resetData();
          Navigator.pushReplacementNamed(context, MainScreen.id);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FireChat',
          style: kAppbarTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  'images/app_icon.png',
                  height: 80,
                ),
                Flexible(
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      TypewriterAnimatedText('FIRE CHAT',
                          textStyle: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: kDarkOrange,
                          ),
                          speed: Duration(
                            milliseconds: 300,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            TextButton(
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(), backgroundColor: Colors.red),
              onPressed: () {
                Provider.of<SettingViewModel>(context, listen: false)
                    .resetData();

                Provider.of<ChatUserViewModel>(context, listen: false)
                    .handleSignIn(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, MainScreen.id);
                  });
                });
              },
              child: Text(
                'SIGN IN WITH GOOGLE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
