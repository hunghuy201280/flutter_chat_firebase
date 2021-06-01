import 'package:flutter/material.dart';

class UpdateInfoTextField extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController textController;
  const UpdateInfoTextField(
      {@required this.title,
      @required this.hintText,
      @required this.textController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, right: 30, left: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.blueGrey[800],
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: textController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: hintText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
