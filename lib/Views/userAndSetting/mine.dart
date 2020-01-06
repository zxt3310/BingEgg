import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserCenterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        brightness: Brightness.light,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () => {}),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share, color: Colors.black), onPressed: () => {})
        ],
      ),
      body: Container(
        color: Colors.grey[300],
        child: Column(
          children: <Widget>[
            Container(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(15),
                      child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 4, color: Colors.orangeAccent)),
                          child: ClipOval(
                              child: Image.network(
                                  'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=612723378,2699755568&fm=11&gp=0.jpg')))),
                  Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('小冰箱的箱', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 15),
                      Text('微信登录', style: TextStyle(color: Colors.grey[500]))
                    ],
                  )),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, idx) {
                      return GestureDetector(
                          onTap: () => print('option Taped'),
                          child: Container(
                            color: Colors.white,
                            child: Column(children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 5, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      FlatButton.icon(
                                          icon: Icon(Icons.android),
                                          label: Text('选项卡'),
                                          splashColor: Colors.transparent,
                                          onPressed: () {}),
                                      Icon(Icons.chevron_right,
                                          color: Colors.grey[500], size: 30)
                                    ],
                                  )),
                              Container(height: 1, color: Colors.grey[400])
                            ]),
                          ));
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
