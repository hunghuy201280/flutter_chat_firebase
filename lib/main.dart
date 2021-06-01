import 'package:chat_firebase/constants.dart';
import 'package:chat_firebase/viewmodels/chat_user_viewmodel.dart';
import 'package:chat_firebase/screens/chat_screen.dart';
import 'package:chat_firebase/screens/main_screen.dart';
import 'package:chat_firebase/screens/settings_screen.dart';
import 'package:chat_firebase/screens/login_screen.dart';
import 'package:chat_firebase/viewmodels/chat_view_model.dart';
import 'package:chat_firebase/viewmodels/setting_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatUserViewModel>(
          create: (context) => ChatUserViewModel(),
        ),
        ChangeNotifierProxyProvider<ChatUserViewModel, SettingViewModel>(
          update: (_, chatViewModel, settingViewModel) =>
              settingViewModel..update(chatViewModel),
          create: (_) => SettingViewModel(),
        ),
        ChangeNotifierProxyProvider<ChatUserViewModel, ChatViewModel>(
          update: (_, userViewModel, chatViewModel) =>
              chatViewModel..update(userViewModel),
          create: (_) => ChatViewModel(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData.light().copyWith(
          appBarTheme: AppBarTheme(
            color: kLightOrange,
          ),
        ),
        routes: {
          LoginScreen.id: (context) => LoginScreen(),
          MainScreen.id: (context) => MainScreen(),
          ChatScreen.id: (context) => ChatScreen(),
          SettingsScreen.id: (context) => SettingsScreen(),
        },
        initialRoute: LoginScreen.id,
      ),
    );
  }
}
