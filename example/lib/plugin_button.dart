import 'package:flutter/material.dart';

class PluginButton extends StatelessWidget {
  PluginButton({this.text, this.color, this.onPressed});

  final String text;
  final Color color;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(text),
      color: color,
      onPressed: onPressed,
    );
  }
}
