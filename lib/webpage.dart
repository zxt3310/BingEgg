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
          brightness: Brightness.dark,
          title: Text('详情',style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: WebView(
          debuggingEnabled: true,
          initialUrl: widget.url,
          onWebViewCreated: (e){
     
          },
          //javascriptMode: JavascriptMode.unrestricted,
          onPageStarted: (e) {
            BotToast.showLoading(duration: Duration(seconds: 3));
          },
          onPageFinished: (e) {
            BotToast.closeAllLoading();
          },
        ));
  }
}
