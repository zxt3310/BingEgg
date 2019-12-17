import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>{
  @override
  Widget build(BuildContext context) {
    return Container(
        child: WebView(
      initialUrl: 'http://180.76.128.198:8000/h5/my-box/list',
      javascriptMode: JavascriptMode.unrestricted,
    ));
  }
}
