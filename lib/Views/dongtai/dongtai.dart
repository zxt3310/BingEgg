import 'package:flutter/material.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'package:sirilike_flutter/webpage.dart';
import 'package:sirilike_flutter/main.dart' show AppSharedState;
import 'activaties.dart';

class DontaiWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title:
              Center(child: Text('动态', style: TextStyle(color: Colors.white))),
          brightness: Brightness.dark),
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
  @override
  void initState() {
    requestFuture = requestData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: FutureBuilder(
        future: requestFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Response res = snapshot.data;
            if (res.data['err'] != 0) {
              return Center(child: Text('请先登录'));
            }
            DynamicData data = DynamicData.fromJson(res.data['data']);
            return getUI(data, context);
          } else {
            return Center(child: Text('loading...'));
          }
        },
      ),
    );
  }

  Future requestData() async {
    NetManager manager = NetManager.instance;
    return manager.dio.get('/api/user/home');
  }
}

Widget getUI(DynamicData data, BuildContext ctx) {
  FriHealth healthState = data.frigeHealth;
  List<Dailyads> dailyAds = data.dailyMealAdvice;
  List<FriendAction> actions = data.actions;
  return CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Container(
          color: Colors.lightGreen,
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('冰箱状态', style: TextStyle(color: Colors.white)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(healthState.title,
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  // MaterialButton(
                  //   minWidth: 50,
                  //   height: 25,
                  //   onPressed: () {
                  //     AppSharedState state =
                  //         Provider.of<AppSharedState>(ctx, listen: false);
                  //     state.tabSwitch(1);
                  //   },
                  //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //   child: Text('去看看'),
                  //   shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
          child: Container(
              color: Colors.lightGreen,
              height: 150,
              child: ListView.builder(
                  padding: EdgeInsets.all(13),
                  itemExtent: (MediaQuery.of(ctx).size.width - 26) / 5,
                  itemCount: 5,
                  itemBuilder: (ctx, idx) {
                    double width =
                        (MediaQuery.of(ctx).size.width - 26) / 5 - 10;
                    return Container(
                      padding: EdgeInsets.all(5),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(6, 6, 6, 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(width / 2)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                width: width - 12,
                                height: width - 12,
                                decoration: BoxDecoration(
                                    color: Colors.lightGreen,
                                    borderRadius: BorderRadius.circular(
                                        (width - 12) / 2))),
                            Text('水果', style: TextStyle(fontSize: 13)),
                            Text('2', style: TextStyle(fontSize: 13))
                          ],
                        ),
                      ),
                    );
                  },
                  scrollDirection: Axis.horizontal))),
      SliverToBoxAdapter(
          child: Container(
        color: const Color(0xFFF9F9F9),
        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
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
                      onPressed: () {},
                      child: Row(
                        children: <Widget>[
                          Text('换一批', style: TextStyle(fontSize: 12)),
                          Icon(Icons.refresh, size: 13)
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
                  return SizedBox(width: 20);
                },
                itemBuilder: (BuildContext context, int index) {
                  Dailyads ads = dailyAds[index];
                  return Container(
                    padding: EdgeInsets.all(10),
                    width: 130,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        color: const Color(0XFF708090)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(ads.name, style: TextStyle(color: Colors.white)),
                        SizedBox(height: 15),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _getDailyText(ads.menu)),
                        SizedBox(height: 15),
                        MaterialButton(
                          padding: EdgeInsets.all(0),
                          color: Colors.white,
                          minWidth: 70,
                          height: 25,
                          child: Text('查看做法'),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MainPage(url: ads.url)));
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )),
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
      SliverFixedExtentList(
          itemExtent: 111,
          delegate: SliverChildBuilderDelegate((ctx, idx) {
            FriendAction action = actions[idx];
            return Container(
              margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(12)),
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(action.name),
                              Text(action.message),
                            ],
                          )
                        ]),
                  ),
                ],
              ),
            );
          }, childCount: data.actions.length > 5 ? 5 : data.actions.length)),
      SliverToBoxAdapter(child: SizedBox(height: 60))
    ],
  );
}

List<Widget> _getDailyText(List list) {
  return List.generate(list.length, (idx) {
    return Text(list[idx], style: TextStyle(color: Colors.white));
  });
}

class DynamicData {
  FriHealth frigeHealth;
  List<Dailyads> dailyMealAdvice;
  List<FriendAction> actions;

  DynamicData.fromJson(Map<String, dynamic> json)
      : frigeHealth = FriHealth.fromJson(json['health_status']),
        dailyMealAdvice = Dailyads.fromListJson(json['daily_meal_advise']),
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
  String url;

  Dailyads.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        menu = json['menu'],
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

  FriendAction.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        message = json['message'],
        lastUpdate = json['last_update'];

  static List<FriendAction> fromListJson(List list) {
    return List<FriendAction>.generate(list.length, (idx) {
      return FriendAction.fromJson(list[idx]);
    });
  }
}
