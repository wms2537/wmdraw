/*
Author: Soh Wei Meng (swmeng@yes.my)
Date: 12 September 2019
Sparta App
*/

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final BuildContext ctx;
  final dynamic _message;
  final String _title;

  ErrorDialog(this.ctx, this._title, this._message);

  @override
  Widget build(BuildContext context) {
    String _displayText;
    if (this._message is DioError) {
      try {
        _displayText = _message.response.data['message'];
      } catch (e) {
        _displayText = _message.toString();
      }
    } else {
      _displayText = _message.toString();
    }
    return AlertDialog(
      title: Text(_title),
      content: Text(_displayText),
      actions: <Widget>[
        TextButton(
          child: Text('Okay'),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    );
  }
}
