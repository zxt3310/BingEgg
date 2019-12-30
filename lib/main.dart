import 'package:flutter/material.dart';
import 'package:sirilike_flutter/login/ui/home_page.dart';
import 'mainpage.dart';
import 'voiceArs.dart';
import 'login/ui/user_provider.dart';
import 'model/user.dart';
import 'imageList.dart';
import 'package:provider/provider.dart';
import 'Views/myFridge.dart';

const List barList = ["提醒", "冰箱", "统计", "我的"];
const List iconListUnselect = [
  Icon(Icons.home),
  Icon(Icons.record_voice_over),
  Icon(Icons.shop),
  Icon(Icons.assignment_ind)
];

const List iconListSelect = [
  Icon(Icons.bluetooth),
  Icon(Icons.blur_linear),
  Icon(Icons.bookmark),
  Icon(Icons.call_missed_outgoing)
];

void main() {
  //在加载app前 载入所有插件
  WidgetsFlutterBinding.ensureInitialized();
  realRunApp();
}

void realRunApp() async {
  await User.instance.loadFromLocal();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Voice Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BottomNavigationBarItem> items;
  int curidx = 0;
  PageController controller;
  User user = User.instance;

  @override
  void initState() {
    controller = PageController();
    items = List.generate(barList.length, (idx) {
      return BottomNavigationBarItem(
          title: Text('${barList[idx]}'), icon: iconListUnselect[idx]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
        actions: <Widget>[
          FlatButton(
            child: Text(user.isLogin ? user.username : '登录',
                style: TextStyle(color: Colors.white)),
            textTheme: ButtonTextTheme.primary,
            onPressed: user.isLogin?(){}:() {
              Navigator.of(context).push(CustomRoute(UserContainer(
                user: null,
                child: AuthorPage(),
              )));
            },
          )
        ],
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[MainPage(), MyFridgeWidget(), ImageListView()],
        controller: controller,
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: items,
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.blue,
          iconSize: 20,
          currentIndex: curidx,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (idx) {
            curidx = idx;
            setState(() {
              controller.jumpToPage(idx);
            });
          }),
      floatingActionButton: IconButton(
          icon: Icon(Icons.cancel),
          iconSize: 60,
          onPressed: () async {
            await user.clear();
            setState(() {});
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class CustomRoute extends PageRouteBuilder {
  final Widget widget;
  CustomRoute(this.widget)
      : super(
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
                    Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0, 0))
                        .animate(CurvedAnimation(
                            parent: animation1,
                            curve: Curves.fastLinearToSlowEaseIn)),
                child: child,
              );
            });
}
