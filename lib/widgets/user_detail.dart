import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class UserDetail extends StatelessWidget {
  UserDetail(
      {@required this.name,
      @required this.description,
      @required this.avatarUrl,
      @required this.onTapCallback});
  final String name;
  final String description;
  final String avatarUrl;
  final Function onTapCallback;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: ListTile(
          onTap: onTapCallback,
          title: Text(
            'Nickname: $name',
            style: kMainUserTextStyle,
          ),
          subtitle: Text(
            'About me: $description',
            style: kMainUserTextStyle,
          ),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
        ),
      ),
    );
  }
}
