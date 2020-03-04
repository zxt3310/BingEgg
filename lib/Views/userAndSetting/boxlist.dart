import 'package:flutter/material.dart';
import 'package:sirilike_flutter/model/network.dart';

class BoxListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的冰箱'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add_circle_outline), onPressed: () {})
        ],
      ),
      floatingActionButton: IconButton(
          icon: Icon(Icons.add_circle_outline), iconSize: 40, onPressed: () {}),
    );
  }
}

class BoxListBody extends StatefulWidget {
  @override
  _BoxListBodyState createState() => _BoxListBodyState();
}

class _BoxListBodyState extends State<BoxListBody> {
  
  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }

  Future requestData(){
    return NetManager.instance.dio.get('');
  }
}
