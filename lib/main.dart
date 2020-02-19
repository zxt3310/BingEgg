import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/user.dart';
import 'Views/myFridge/myFridge.dart';
import 'Views/statistics/foodAnalyze.dart';
import 'Views/reminder/foodReminder.dart';
import 'Views/userAndSetting/mine.dart';
import 'Views/dongtai/dongtai.dart';
import 'voiceArs.dart';

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

  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.green,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
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
          primarySwatch: Colors.lightGreen,
          splashColor: Colors.transparent,
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
      body: IndexedStack(
        index: curidx,
        children: <Widget>[
          DontaiWidget(),
          MyFridgeWidget(),
          FoodAnalyzeWidgit(),
          UserCenterWidget()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: items,
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.green,
          currentIndex: curidx,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (idx) {
            curidx = idx;
            setState(() {
              
            });
          }),
      floatingActionButton: IconButton(
          icon: Icon(Icons.add_circle_outline), iconSize: 60, onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
