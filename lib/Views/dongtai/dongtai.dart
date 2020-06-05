import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sirilike_flutter/Views/myFridge/foodDetail.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'package:sirilike_flutter/main.dart';
import 'package:sirilike_flutter/model/event.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'package:sirilike_flutter/webpage.dart';
import 'activaties.dart';
import 'package:intl/intl.dart';

class DontaiWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Center(
              child: Text('云冰箱管家', style: TextStyle(color: Colors.white))),
          brightness: Brightness.dark),
      backgroundColor: const Color(0xFFF9F9F9),
      body: DontaiBody(),
    );
  }
}

class DontaiBody extends StatefulWidget {
  @override
  _DontaiBodyState createState() => _DontaiBodyState();
}

class _DontaiBodyState extends State<DontaiBody> {
  Future requestFuture;
  //保存旧布局作为刷新前的缓冲
  Widget old;
  StreamSubscription streamSubscription;

  @override
  void initState() {
    freshData();
    streamSubscription = myEvent.on().listen((e) {
      freshData();
    });
    super.initState();
  }

  @override
  void deactivate() {
    bool isback = ModalRoute.of(context).isCurrent;
    if (isback) {
      print('back');
    }
    super.deactivate();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: const Color(0xFFF9F9F9),
      child: FutureBuilder(
        future: requestFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Response res = snapshot.data;
            if (res.data['err'] != 0) {
              return Center(child: Text('请先登录'));
            }
            DynamicData data = DynamicData.fromJson(res.data['data']);
            old = getUI(data, context);
            return old;
          } else {
            return old ?? Center(child: Text('loading...'));
          }
        },
      ),
    );
  }

  Future requestData() async {
    NetManager manager = NetManager.instance;
    print('reloading  Dongtai。。。。');
    return manager.dio.get('/api/user/home');
  }

  freshData() {
    requestFuture = requestData();
  }
}

Widget getUI(DynamicData data, BuildContext ctx) {
  FriHealth healthState = data.frigeHealth;
  List<Dailyads> dailyAds = data.dailyMealAdvice;
  List<FriendAction> actions = data.actions;
  List<TopItem> items = data.topItems;
  return CustomScrollView(
    shrinkWrap: true,
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Container(
          color: Colors.lightGreen,
          padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('冰箱状态', style: TextStyle(color: Colors.white)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(healthState.title,
                      style: TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
          child: Offstage(
        offstage: data.topItems.isEmpty,
        child: Container(
            color: Colors.lightGreen,
            height: 150,
            child: ListView.builder(
                padding: EdgeInsets.all(13),
                itemExtent: (MediaQuery.of(ctx).size.width - 26) / 5,
                itemCount: items.length,
                itemBuilder: (ctx, idx) {
                  TopItem item = items[idx];
                  AppSharedState state =
                      Provider.of<AppSharedState>(ctx, listen: false);
                  double width = (MediaQuery.of(ctx).size.width - 26) / 5 - 10;
                  return GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(6, 6, 6, 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(width / 2)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            ClipOval(
                                child: Image.network(
                              'http://106.13.105.43:8889/static/images/item-pics/item-${item.id}.jpg',
                              width: width - 12,
                              height: width - 12,
                            )),
                            Text('${item.name}',
                                style: TextStyle(fontSize: 13)),
                            Text('${item.rest}', style: TextStyle(fontSize: 13))
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).push(MaterialPageRoute(
                          builder: (context) => FoodDetailWidget(
                              food: FoodMaterial(
                                  itemId: item.id,
                                  itemName: item.name,
                                  boxId: state.curBoxId))));
                    },
                  );
                },
                scrollDirection: Axis.horizontal)),
      )),
      SliverToBoxAdapter(
          child: Container(
        color: const Color(0xFFF9F9F9),
        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('推荐菜单',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  FlatButton(
                      // onPressed: () {
                      //   Navigator.of(ctx).push(MaterialPageRoute(
                      //       builder: (context) => GlobalLoginPage()));
                      // },
                      onPressed: null,
                      child: Row(
                        children: <Widget>[
                          Text("", style: TextStyle(fontSize: 12)),
                          // Icon(Icons.refresh, size: 13)
                        ],
                      )),
                ]),
            SizedBox(height: 10),
            Container(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dailyAds.length,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(width: 10);
                },
                itemBuilder: (BuildContext context, int index) {
                  Dailyads ads = dailyAds[index];
                  return GestureDetector(
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                              width: 138,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xFFE0E0E0),
                                        offset: Offset(0, 1),
                                        blurRadius: 6)
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Flexible(
                                        flex: 1,
                                        child: CachedNetworkImage(
                                            imageUrl: ads.bgUrl,
                                            height: 90,
                                            fit: BoxFit.fill,
                                            placeholder: (ctx, str) {
                                              return Center(
                                                  child: Image.asset(
                                                      "srouce/loading.gif",
                                                      width: 30,
                                                      height: 30));
                                            })),
                                    Flexible(
                                        flex: 1,
                                        child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                15, 8, 20, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(ads.name,
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children:
                                                        _getDailyText(ads.menu))
                                              ],
                                            )))
                                  ],
                                ),
                              ))),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            settings: RouteSettings(name: '推荐菜单页'),
                            builder: (context) => MainPage(url: ads.url)));
                      });
                },
              ),
            ),
          ],
        ),
      )),
      // SliverToBoxAdapter(
      //   child: Container(
      //     height: 50,
      //     margin: EdgeInsets.all(15),
      //     decoration: BoxDecoration(
      //         color: Colors.white,
      //         borderRadius: BorderRadius.circular(18),
      //         boxShadow: [
      //           BoxShadow(blurRadius: 6, color: const Color(0xffe0e0e0))
      //         ]),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: <Widget>[
      //         Container(
      //           width: 36,
      //           height: 36,
      //           decoration: BoxDecoration(
      //               color: const Color(0xffd8d8d8),
      //               borderRadius: BorderRadius.circular(18)),
      //         ),
      //         Text('午餐打卡',
      //             style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      //         Checkbox(
      //             value: true,
      //             tristate: true,
      //             onChanged: (e) {},
      //             activeColor: Colors.green)
      //       ],
      //     ),
      //   ),
      // ),
      SliverToBoxAdapter(
        child: Container(
            color: const Color(0xFFF9F9F9),
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('动态',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                MaterialButton(
                  padding: EdgeInsets.all(0),
                  child: Row(
                    children: <Widget>[
                      Text('查看更多', style: TextStyle(fontSize: 12)),
                      Icon(Icons.chevron_right)
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (context) => FriendActWidget(actions)));
                  },
                )
              ],
            )),
      ),
      actions.length == 0
          ? SliverToBoxAdapter(
              child: Container(
                  height: ScreenUtil().setHeight(150),
                  child: Center(child: Text('暂无动态'))),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate((ctx, idx) {
              FriendAction action = actions[idx];
              return Container(
                margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipOval(
                            child: FadeInImage.assetNetwork(
                                placeholder: 'srouce/login_logo.png',
                                image: action.avatar,
                                width: 30,
                                height: 30)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                action.name,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(action.message),
                              SizedBox(height: 5),
                              Wrap(children: _getActionsItem(action)),
                            ],
                          ),
                        ),
                        Text(_getActTimeStr(action.lastUpdate),
                            style: TextStyle(fontSize: 10)),
                      ]),
                ),
              );
            }, childCount: data.actions.length > 5 ? 5 : data.actions.length)),
      SliverToBoxAdapter(child: SizedBox(height: 60))
    ],
  );
}

String _getActTimeStr(String timeStr) {
  DateFormat formater = DateFormat('yyyy-MM-ddTHH:mm:ss');
  DateTime create = formater.parse(timeStr);
  Duration duration = DateTime.now().difference(create);

  int days = duration.inDays;
  int hours = duration.inHours;
  int minutes = duration.inMinutes;

  if (days > 30) {
    return '${days ~/ 30}个月前';
  }

  if (days > 0) {
    return '$days天前';
  }

  if (hours > 0) {
    return '$hours小时前';
  }

  if (minutes > 0) {
    return '$minutes分钟前';
  }

  return "刚刚";
}

List<Widget> _getDailyText(List list) {
  return List.generate(list.length, (idx) {
    return Text(list[idx], maxLines: 1, style: TextStyle(fontSize: 11.5));
  });
}

List<Widget> _getActionsItem(FriendAction action) {
  return List.generate(action.items.length, (idx) {
    FoodMaterial item = action.items[idx];
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
              width: 38,
              height: 38,
              placeholder: (ctx, str) {
                return Text('loading...');
              },
              errorWidget: (ctx, str, obj) {
                return Image.asset(
                  'srouce/place.png',
                  width: 38,
                  height: 38,
                );
              },
              imageUrl:
                  "http://106.13.105.43:8889/static/images/item-pics/item-${item.itemId}.jpg")),
    );
  });
}

class DynamicData {
  FriHealth frigeHealth;
  List<Dailyads> dailyMealAdvice;
  List<TopItem> topItems;
  List<FriendAction> actions;

  DynamicData.fromJson(Map<String, dynamic> json)
      : frigeHealth = FriHealth.fromJson(json['health_status']),
        dailyMealAdvice = Dailyads.fromListJson(json['daily_meal_advise']),
        topItems = TopItem.fromListJson(json['top_items']),
        actions = FriendAction.fromListJson(json['activaties']);
}

class FriHealth {
  int score;
  String color;
  String title;

  FriHealth.fromJson(Map<String, dynamic> json)
      : score = json['score'],
        color = json['color'],
        title = json['title'];
}

class Dailyads {
  String name;
  List menu;
  String bgUrl;
  String url;

  Dailyads.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        menu = json['menu'],
        bgUrl = json['bg_url'],
        url = json['url'];

  static List<Dailyads> fromListJson(List list) {
    return List.generate(list.length, (idx) {
      return Dailyads.fromJson(list[idx]);
    });
  }
}

class FriendAction {
  String name;
  String message;
  String lastUpdate;
  String avatar;
  List items;

  FriendAction.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        message = json['message'],
        lastUpdate = json['last_update'],
        avatar = json['avatar'],
        items = FoodMaterial.getList(json['items']);

  static List<FriendAction> fromListJson(List list) {
    return List<FriendAction>.generate(list.length, (idx) {
      return FriendAction.fromJson(list[idx]);
    });
  }
}

class TopItem {
  final int id;
  final String name;
  final int rest;

  TopItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        rest = json['rest'];

  static List<TopItem> fromListJson(List list) {
    return List<TopItem>.generate(list.length, (idx) {
      return TopItem.fromJson(list[idx]);
    });
  }
}
