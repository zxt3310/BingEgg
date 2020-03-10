import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'model/user.dart';
import 'Views/myFridge/myFridge.dart';
import 'Views/statistics/foodAnalyze.dart';
import 'Views/userAndSetting/mine.dart';
import 'Views/dongtai/dongtai.dart';
import 'Views/chat/chat.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'Views/bottomBar/bingEBottomNaviBar.dart';

const List barList = ["提醒", "冰箱", "统计", "我的"];

void main() {
  //在加载app前 载入所有插件
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  realRunApp();
}

void realRunApp() async {
  await User.instance.loadFromLocal();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
        child: MaterialApp(
            title: 'Voice Demo',
            navigatorObservers: [BotToastNavigatorObserver()],
            theme: ThemeData(
              primarySwatch: Colors.lightGreen,
              splashColor: Colors.transparent,
            ),
            home: MyHomePage()));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BingEBarItemModel> items;
  PageController controller;
  User user = User.instance;
  AppSharedState appSharedState;

  @override
  void initState() {
    appSharedState = AppSharedState();
    controller = PageController();
    items = List.generate(barList.length, (idx) {
      return BingEBarItemModel(
          title: barList[idx],
          selectWid: Image.asset('srouce/bottom/nav${idx + 1}_p.png',
              width: 20, height: 20),
          unselectWid: Image.asset('srouce/bottom/nav${idx + 1}_n.png',
              width: 20, height: 20),
          selectColor: Colors.green,
          unselectColor: Colors.black);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppSharedState>(
        create: (ctx) => appSharedState,
        child: Consumer<AppSharedState>(builder: (ctx, state, child) {
          return Scaffold(
            body: IndexedStack(
              index: state.curTabIndex,
              children: <Widget>[
                DontaiWidget(),
                MyFridgeWidget(),
                FoodAnalyzeWidgit(),
                UserCenterWidget()
              ],
            ),
            extendBody: true,
            bottomNavigationBar: SafeArea(
                child: BingEBottomBaviBar(
              height: 60,
              items: items,
              existCenterDock: true,
              curSelectIndex: state.curTabIndex,
              backgroundImg: const AssetImage('srouce/bottom/nva_bg.png'),
              itemSize: 25,
              onTap: (idx) {
                state.tabSwitch(idx);
              },
              centerDock: GestureDetector(
                  child: Image.asset('srouce/bottom/nva_add.png',
                      width: 60, height: 60, fit: BoxFit.fitHeight),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatWidget(state.curBoxId),
                        fullscreenDialog: true));
                  }),
            )),
          );
        }));
  }
}

class AppSharedState with ChangeNotifier {
  int curTabIndex = 0;
  int curBoxId = 0;
  int curBoxIndex = 0; //当前选中冰箱
  List<Fridge> curList = List();

  tabSwitch(int index) {
    curTabIndex = index;
    notifyListeners();
  }

  freshBox(int boxId) {
    curBoxId = boxId;
  }

  changeBoxList(List<Fridge> list) {
    curList = list;
    notifyListeners();
  }

  changeCurIndex(int idx) {
    curBoxIndex = idx;
    notifyListeners();
  }
}
