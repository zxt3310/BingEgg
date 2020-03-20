import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.url}) : super(key: key);
  final String url;
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('详情'),
        ),
        body: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onPageStarted: (e) {
            BotToast.showLoading(duration: Duration(seconds: 3));
          },
          onPageFinished: (e) {
            BotToast.closeAllLoading();
          },
        ));
  }
}
