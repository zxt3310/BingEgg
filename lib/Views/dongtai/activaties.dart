import 'package:flutter/material.dart';
import 'dongtai.dart' show FriendAction;

class FriendActWidget extends StatefulWidget {
  final List data;

  FriendActWidget(this.data);
  @override
  _FriendActWidgetState createState() => _FriendActWidgetState();
}

class _FriendActWidgetState extends State<FriendActWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('好友动态'), centerTitle: true),
      body: Container(
          child: ListView.builder(
              itemExtent: 100,
              itemBuilder: (context, index) { 
                FriendAction action = widget.data[index];
                return Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.all(10),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1),
                                      borderRadius: BorderRadius.circular(25))),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text(action.name),
                                  Text(action.message),
                                ],
                              )
                            ]),
                      ),
                      Container(height: 1, color: Colors.grey[400])
                    ],
                  ),
                );
              },
              itemCount: widget.data.length)),
    );
  }
}
