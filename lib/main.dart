import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
// import 'package:package_info/package_info.dart';
import 'package:sirilike_flutter/Views/GlobalUser/GlobalLogin.dart';
import 'package:sirilike_flutter/Views/statistics/foodStatistics.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/observer/naviobserver.dart';
// import 'package:sirilike_flutter/model/network.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'model/user.dart';
import 'Views/myFridge/myFridge.dart';
import 'Views/userAndSetting/mine.dart';
import 'Views/dongtai/dongtai.dart';
import 'Views/chat/chat.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'Views/bottomBar/bingEBottomNaviBar.dart';
import 'package:sirilike_flutter/model/event.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sirilike_flutter/model/quick_check.dart';
import 'package:fluwx_no_pay/fluwx_no_pay.dart';
import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';

const List barList = ["首页", "冰箱", "统计", "我的"];

void main() {
  //在加载app前 载入所有插件
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  registerWxApi(
          appId: "wx5a52d3333de8086b",
          universalLink: "https://bingbox.xiaomap.cn")
      .then((succed) {
    if (succed) {
      print('微信初始化成功');
    } else {
      print('微信认证失败');
    }
  });
  //预取号
  QuickCheckManager.instance.reCheck();
  realRunApp();
}

void realRunApp() async {
  await User.instance.loadFromLocal();
  await UmengAnalyticsPlugin.init(
      androidKey: "5ea6e240dbc2ec07fc259e1a",
      iosKey: "5ea6e2b4dbc2ec07fc259e1e");
  runApp(MyApp());
  UmengAnalyticsPlugin.event("App",label: "启动");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
        child: MaterialApp(
            routes: {
              'homeRoute': (context) => MyHomePage(),
              'loginRoute': (context) => GlobalLoginPage()
            },
            title: 'Voice Demo',
            navigatorObservers: [BotToastNavigatorObserver(),NaviObserver()],
            theme: ThemeData(
              primarySwatch: Colors.lightGreen,
              scaffoldBackgroundColor: Colors.white,
              buttonTheme: ButtonThemeData(minWidth: 20),
              //splashColor: Colors.transparent,
            ),
            home: User.instance.isLogin ? MyHomePage() : GlobalLoginPage()));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppSharedState appSharedState;
  PageController controller;
  List<BingEBarItemModel> items;
  User user = User.instance;

  //检查更新
  // _requestUpdate(BuildContext ctx) async {
  //   PackageInfo info = await PackageInfo.fromPlatform();
  //   NetManager.instance.dio
  //       .get(
  //           '/api/up2date?platform=${Platform.isIOS ? 'ios' : 'android'}&verion=${info.version}')
  //       .then((e) {
  //     if (e.data['err'] == 0) {
  //       if (e.data['data'] != null) {
  //         if (Platform.isIOS) {
  //           showCupertinoDialog(
  //               context: ctx,
  //               builder: (contxt) {
  //                 return CupertinoAlertDialog(
  //                   title: Text('发现更新'),
  //                   content: Text('新版本：${e.data['data']['whatsnew']}'),
  //                   actions: <Widget>[
  //                     CupertinoDialogAction(
  //                         child: Text('知道了'),
  //                         onPressed: () {
  //                           Navigator.of(contxt).pop();
  //                         }),
  //                   ],
  //                 );
  //               });
  //         } else {
  //           showDialog(
  //               context: ctx,
  //               child: AlertDialog(
  //                 title: Text('发现更新'),
  //                 content: Text('新版本：${e.data['data']['whatsnew']}'),
  //                 actions: <Widget>[
  //                   FlatButton(
  //                       onPressed: () {
  //                         Navigator.of(ctx).pop();
  //                         launch(e.data['data']['link']);
  //                       },
  //                       child: Text('去升级')),
  //                   FlatButton(
  //                       onPressed: () {
  //                         Navigator.of(ctx).pop();
  //                       },
  //                       child: Text('取消')),
  //                 ],
  //               ));
  //         }
  //       }
  //     }
  //   });
  // }

  @override
  void dispose() {
    print('home page dealloc');
    super.dispose();
  }

  @override
  void initState() {
    //_requestUpdate(this.context);
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

  Future<bool> _requestPop() async {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('退出'),
            content: Text('是否退出？'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text('确定')),
              FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('取消')),
            ],
          );
        });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 375, height: 667, allowFontScaling: false);
    return ChangeNotifierProvider<AppSharedState>(
        create: (ctx) => appSharedState,
        child: Selector<AppSharedState, int>(
            selector: (context, state) => state.curTabIndex,
            shouldRebuild: (index, next) => index != next,
            builder: (ctx, curTabIndex, child) {
              return WillPopScope(
                onWillPop: _requestPop,
                child: Scaffold(
                  body: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 34),
                      child: IndexedStack(
                        index: curTabIndex,
                        children: <Widget>[
                          DontaiWidget(),
                          MyFridgeWidget(),
                          FoodStatistics(),
                          UserCenterWidget()
                        ],
                      )),
                  extendBody: true,
                  bottomNavigationBar: SafeArea(
                      child: BingEBottomBaviBar(
                    height: 60,
                    items: items,
                    existCenterDock: true,
                    curSelectIndex: curTabIndex,
                    backgroundImg: const AssetImage('srouce/bottom/nva_bg.png'),
                    itemSize: 25,
                    onTap: (idx) {
                      appSharedState.tabSwitch(idx);
                      UmengAnalyticsPlugin.event("TAB导航",label: "切换tab$idx");
                    },
                    centerDock: GestureDetector(
                        child: Image.asset('srouce/bottom/nva_add.png',
                            width: 60, height: 60, fit: BoxFit.fitHeight),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                settings: RouteSettings(name: "存取页"),
                                  builder: (context) =>
                                      ChatWidget(appSharedState.curBoxId),
                                  fullscreenDialog: true))
                              .then((e) {
                            myEvent.fire(null);
                          });
                        }),
                  )),
                ),
              );
            }));
  }
}

class AppSharedState with ChangeNotifier {
  int curBoxId = 0;
  int curBoxIndex = 0; //当前选中冰箱
  List<Fridge> curList = List();
  int curTabIndex = 0;

  @override
  dispose() {
    super.dispose();
  }

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
