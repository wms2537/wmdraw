import 'dart:async';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wmdraw/widgets/error_dialog.dart';

class Captcha extends StatefulWidget {
  Function(bool success) callback;
  Captcha(this.callback);
  @override
  State<StatefulWidget> createState() {
    return CaptchaState();
  }
}

class CaptchaState extends State<Captcha> {
  late WebViewController webViewController;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(
          'hcaptcha-html',
          (int viewId) => html.IFrameElement()
            ..src = "https://hcaptcha.wmtech.cc"
            // ..addEventListener('Captcha', (html.Event event) {
            //   print(event);
            //   var data = (event as html.MessageEvent).data;
            //   print(data);
            //   print(data['sender']);
            //   print(data['message']);
            //   // setState(() {
            //   //   //...
            //   // });
            // })
            ..style.border = 'none'
            ..width = '320'
            ..height = '240');
    }
    html.window.onMessage.forEach((element) {
      verifyToken(element.data);
    });
  }

  Future<void> verifyToken(String token) async {
    try {
      final String url = "https://hcaptcha.wmtech.cc/api/siteverify/$token";
      final res = await Dio().get(
        url,
      );
      final decoded = res.data;
      if (res.statusCode != 200) {
        widget.callback(false);
        throw Exception(decoded['message']);
      }
      widget.callback(true);
    } catch (e) {
      widget.callback(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: kIsWeb
            ? HtmlElementView(viewType: 'hcaptcha-html')
            : WebView(
                initialUrl: "https://hcaptcha.wmtech.cc",
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: Set.from([
                  JavascriptChannel(
                      name: 'Captcha',
                      onMessageReceived: (JavascriptMessage message) async {
                        // message contains the 'h-captcha-response' token.
                        // Send it to your server in the login or other
                        // data for verification via /siteverify
                        // see: https://docs.hcaptcha.com/#server
                        // print(message.message);
                        verifyToken(message.message);
                        Navigator.of(context).pop();
                      })
                ]),
                onWebViewCreated: (WebViewController w) {
                  webViewController = w;
                },
              ));
  }
}
