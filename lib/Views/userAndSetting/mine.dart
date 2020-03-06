import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sirilike_flutter/login/ui/home_page.dart';
import '../../model/user.dart';
import '../../login/ui/user_provider.dart';
import 'boxlist.dart';
import 'userinfo.dart';
import 'package:sirilike_flutter/main.dart' show AppSharedState;
export 'package:sirilike_flutter/main.dart' show AppSharedState;

List optionList = ['我的冰箱', '个人信息', '选项卡'];

class UserCenterWidget extends StatelessWidget {
  final User user = User.instance;
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
              icon: Icon(Icons.share, color: Colors.black),
              onPressed: user.isLogin
                  ? () {}
                  : () {
                      Navigator.of(context).push(CustomRoute(
                          UserContainer(user: null, child: AuthorPage())));
                    })
        ],
      ),
      body: Container(
        color: Colors.grey[300],
        child: Column(
          children: <Widget>[
            UserHeaderWidget(),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: optionList.length,
                    itemBuilder: (ctx, idx) {
                      return GestureDetector(
                          onTap: () {
                            switch (idx) {
                              case 0:
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => BoxListWidget(
                                        providerContext: context)));
                                break;
                              case 1:
                                 Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => UserInfoWidget()));
                                break;
                              default:
                            }
                          },
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
                                          label: Text(optionList[idx]),
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

class UserHeaderWidget extends StatefulWidget {
  @override
  _UserHeaderWidgetState createState() => _UserHeaderWidgetState();
}

class _UserHeaderWidgetState extends State<UserHeaderWidget> {
  User user = User.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(15),
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 4, color: Colors.orangeAccent)),
                  child: ClipOval(
                      child: Image.network(
                          'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=612723378,2699755568&fm=11&gp=0.jpg')))),
          Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('${user.username == null ? '小冰的箱' : user.username}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 15),
              Text('手机登录', style: TextStyle(color: Colors.grey[500]))
            ],
          )),
        ],
      ),
    );
  }
}

class CustomRoute extends PageRouteBuilder {
  final Widget widget;
  CustomRoute(this.widget)
      : super(
            opaque: false,
            barrierColor: Color(0x7F000000),
            maintainState: true,
            transitionDuration: Duration(milliseconds: 500),
            pageBuilder: (
              BuildContext context,
              Animation<double> animation1,
              Animation<double> animation2,
            ) {
              return widget;
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              return SlideTransition(
                position:
                    Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0, 0.1))
                        .animate(CurvedAnimation(
                            parent: animation1,
                            curve: Curves.fastLinearToSlowEaseIn)),
                child: child,
              );
            });
}
