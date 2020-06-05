import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sirilike_flutter/Views/friends/addFriend.dart';
import 'package:sirilike_flutter/Views/friends/friendBoxItem.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/model/network.dart';

class FriendBoxListWidget extends StatelessWidget {
  final BuildContext providerContext;
  FriendBoxListWidget({this.providerContext});
  @override
  Widget build(BuildContext context) {
    final BoxListBody body = BoxListBody();
    return ChangeNotifierProvider<FriendBoxState>(
      create: (ctx) => FriendBoxState(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '好友冰箱',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          brightness: Brightness.dark,
          actions: <Widget>[
            FlatButton.icon(
                onPressed: () {
                  body.freshData();
                },
                splashColor: Colors.lightGreen,
                icon: Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  '添加',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ))
          ],
        ),
        backgroundColor: Colors.lightGreen,
        body: body,
        bottomNavigationBar: Container(
          height: ScreenUtil.bottomBarHeight,
          color: Colors.white,
        ),
      ),
    );
  }
}

class BoxListBody extends StatefulWidget {
  final _BoxListBodyState state = _BoxListBodyState();
  BoxListBody();
  @override
  _BoxListBodyState createState() => state;

  void freshData() {
    state.freshData();
  }
}

class _BoxListBodyState extends State<BoxListBody> {
  @override
  void initState() {
    _getFridgeList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendBoxState>(builder: (context, state, child) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(31))),
          child: state.friendBoxList == null
              ? Container(
                  child: Center(
                  child: Text('loading....'),
                ))
              : state.friendBoxList.isEmpty
                  ? Container(
                      child: Center(
                      child: Text('您尚未添加好友'),
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemBuilder: (context, idx) {
                        FriendBox fridge = state.friendBoxList[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 6,
                                      color: const Color(0xffE0E0E0))
                                ]),
                            child: Column(
                              children: <Widget>[
                                //名称，未知，图标
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        width: ScreenUtil().setWidth(48),
                                        height: ScreenUtil().setWidth(48),
                                        margin: EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 4,
                                                color:
                                                    const Color(0xfff2f2f2))),
                                        child: Image.asset(
                                          'srouce/icotype/ico_type_${fridge.boxtype + 1}_p.png',
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              fridge.boxname,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.location_on,
                                                    size: 16,
                                                    color: const Color(
                                                        0xffC8C7CC)),
                                                Text(
                                                  fridge.addr,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: const Color(
                                                          0xff8A8A8F)),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                          child: Align(
                                              alignment:
                                                  AlignmentDirectional.topEnd,
                                              child: PopupMenuButton(
                                                  offset: Offset(0, 30),
                                                  padding: EdgeInsets.zero,
                                                  itemBuilder: (ctx) {
                                                    return [
                                                      PopupMenuItem(
                                                          value: 0,
                                                          child: Text('删除'))
                                                    ];
                                                  },
                                                  onSelected: (e) {
                                                    switch (e) {
                                                      case 0:
                                                        {
                                                          showCupertinoDialog(
                                                              context: context,
                                                              builder: (ctx) {
                                                                return CupertinoAlertDialog(
                                                                  title: Text(
                                                                      '确认删除'),
                                                                  actions: <
                                                                      Widget>[
                                                                    CupertinoDialogAction(
                                                                        child: Text(
                                                                            '确定'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(ctx)
                                                                              .pop();
                                                                          _deleteFridge(
                                                                              fridge.friendBoxId,
                                                                              idx);
                                                                        }),
                                                                    CupertinoDialogAction(
                                                                        onPressed: () =>
                                                                            Navigator.of(ctx)
                                                                                .pop(),
                                                                        child: Text(
                                                                            '取消'))
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                        break;
                                                      default:
                                                    }
                                                  })))
                                    ],
                                  ),
                                ),
                                // 状态
                                Container(
                                  //padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      _stateContain(
                                          '物品数量', '${fridge.foodCount}'),
                                      Container(
                                          width: 1,
                                          height: 50,
                                          color: const Color(0xffF2F2F2)),
                                      _stateContain('冰箱状态', fridge.state),
                                      Container(
                                          width: 1,
                                          height: 50,
                                          color: const Color(0xffF2F2F2)),
                                      Container(
                                          width: ScreenUtil().setWidth(100),
                                          height: ScreenUtil().setWidth(80),
                                          child: Center(
                                            child: FlatButton(
                                              child: Text(
                                                '查看食材',
                                                style: TextStyle(
                                                    color: Colors.lightGreen),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      settings: RouteSettings(name: '朋友冰箱食材页'),
                                                        builder: (ctx) =>
                                                            FriendBoxItemsWidget(
                                                                boxName: fridge
                                                                    .boxname,
                                                                friendId: fridge
                                                                    .userId)));
                                              },
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: state.friendBoxList.length),
        ),
      );
    });
  }

  Widget _stateContain(String title, String content) {
    return Container(
      width: ScreenUtil().setWidth(100),
      height: ScreenUtil().setWidth(80),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, color: const Color(0xff666666)),
        ),
        Text(content, style: TextStyle(fontSize: 20))
      ]),
    );
  }

  freshData() {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (ctx) => FriendAddWidget(), fullscreenDialog: true))
        .then((e) async {
      if (e is bool && e) {
        _getFridgeList();
      }
    });
  }

  _getFridgeList() async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.get('/api/friend-box/list');
    if (res.data['err'] != 0) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(res.data['errmsg'])));
      return;
    }
    List sources = res.data['data'];
    List<FriendBox> fridges = List<FriendBox>.generate(sources.length, (idx) {
      return FriendBox.fromJson(sources[idx]);
    });
    Provider.of<FriendBoxState>(context, listen: false).changeSource(fridges);
  }

  _deleteFridge(String boxid, int boxIndex) async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.get('/api/friend/delete?fboxid=$boxid');
    if (res.data['err'] != 0) {
      BotToast.showText(text: '网络出错了，请重试');
      print('delege fridge error');
      return;
    }
    _getFridgeList();
  }
}

class FriendBoxState with ChangeNotifier {
  List<FriendBox> friendBoxList;

  changeSource(List<FriendBox> boxlist) {
    friendBoxList = boxlist;
    notifyListeners();
  }
}

class FriendBox extends Fridge {
  final String friendBoxId;
  final String userId;
  FriendBox.fromJson(Map json)
      : friendBoxId = json['box_id'],
        userId = json['user_id'],
        super.fromJson(json);
}
