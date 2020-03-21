import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sirilike_flutter/login/ui/home_page.dart';
import '../../model/user.dart';
import '../../login/ui/user_provider.dart';
import 'boxlist.dart';
import 'userinfo.dart';
import 'package:sirilike_flutter/Views/deviceConnect/deviceConnect.dart';
export 'package:sirilike_flutter/main.dart' show AppSharedState;

List optionList = ['我的冰箱', '个人信息', '选项卡'];

class UserCenterWidget extends StatelessWidget {
  final User user = User.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightGreen,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: Container(
              child: Column(
                children: <Widget>[
                  UserHeaderWidget(),
                ],
              ),
            )),
            SliverToBoxAdapter(
                child: Container(
              padding: EdgeInsets.all(16),
              color: const Color(0xfff9f9f9),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: <Widget>[
                        OptionsSelectWidget(
                            title: '个人信息',
                            icon: Icons.my_location,
                            onTap: () {}),
                        OptionsSelectWidget(
                            title: '账号绑定', icon: Icons.alarm, onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) =>
                                      WIFIConnectWidget()));
                            }),
                        OptionsSelectWidget(
                            title: '冰箱列表',
                            icon: Icons.phone,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) =>
                                      BoxListWidget(providerContext: context)));
                            },
                            showSeprate: false)
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: <Widget>[
                        OptionsSelectWidget(
                            title: '新手引导',
                            icon: Icons.my_location,
                            onTap: () {}),
                        OptionsSelectWidget(
                            title: '联系我们', icon: Icons.alarm, onTap: () {}),
                        OptionsSelectWidget(
                            title: '隐私政策',
                            icon: Icons.phone,
                            onTap: () {},
                            showSeprate: false)
                      ],
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Center(
                      child: FlatButton(
                          onPressed: null,
                          child: Text('退出登录',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xfff5635e)))),
                    ),
                  )
                ],
              ),
            )),
          ]),
        ));
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
      color: Colors.lightGreen,
      padding: EdgeInsets.all(15),
      child: Column(children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(15),
                child: ClipOval(
                    child: Image.network(
                  'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1584699083702&di=7cf57bf8d0bb6f7662ebf1721b1cd9a7&imgtype=0&src=http%3A%2F%2Fwx1.sinaimg.cn%2Forj360%2Fdc1ebfbdly1gc0oora8g9j21hc0u0dkg.jpg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.fitHeight,
                ))),
            Container(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${user.username == null ? '小冰的箱' : user.username}',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                Text('手机登录',
                    style:
                        TextStyle(fontSize: 10, color: const Color(0xff437722)))
              ],
            )),
          ],
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          height: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(31),
              color: const Color(0xff659E40)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('xxx的冰箱', style: TextStyle(color: Colors.white)),
              Text('食材充足', style: TextStyle(color: Colors.white))
            ],
          ),
        )
      ]),
    );
  }
}

class OptionsSelectWidget extends StatelessWidget {
  @required
  final String title;
  @required
  final Function onTap;
  final IconData icon;
  final bool showSeprate;
  OptionsSelectWidget(
      {this.title, this.onTap, this.icon, this.showSeprate = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(children: [
            Row(
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffF9F9F9),
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.all(10),
                    child: Icon(icon, color: Colors.lightGreen, size: 20)),
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)))),
                Icon(Icons.keyboard_arrow_right,
                    size: 23, color: const Color(0xffc8c7cc))
              ],
            ),
            SizedBox(height: 10),
            showSeprate
                ? Divider(
                    height: 1, thickness: 1, color: const Color(0xffEFEFF4))
                : SizedBox()
          ]),
        ));
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
