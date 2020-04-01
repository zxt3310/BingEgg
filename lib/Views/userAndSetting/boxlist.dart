import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'package:sirilike_flutter/main.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'boxAdd.dart';

class BoxListWidget extends StatelessWidget {
  final BuildContext providerContext;
  BoxListWidget({this.providerContext});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '我的冰箱',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        brightness: Brightness.dark,
      ),
      backgroundColor: Colors.lightGreen,
      body: BoxListBody(providerContext),
      bottomNavigationBar: Container(
        height: ScreenUtil.bottomBarHeight,
        color: Colors.white,
      ),
    );
  }
}

class BoxListBody extends StatefulWidget {
  final BuildContext providerContext;
  BoxListBody(this.providerContext);
  @override
  _BoxListBodyState createState() => _BoxListBodyState();
}

class _BoxListBodyState extends State<BoxListBody> {
  int curDefault;
  @override
  Widget build(BuildContext context) {
    AppSharedState state = Provider.of(widget.providerContext, listen: false);
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(31))),
        child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, idx) {
              int len = state.curList.length;
              Fridge fridge;
              if (len != 0 && idx < len) {
                fridge = state.curList[idx];
              }
              return idx == state.curList.length
                  ? Container(
                      color: Colors.white,
                      height: 100 + ScreenUtil.bottomBarHeight,
                      child: Center(
                          child: MaterialButton(
                              padding: EdgeInsets.fromLTRB(70, 14, 70, 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                              color: Colors.lightGreen,
                              textColor: Colors.white,
                              child: Text('添加新冰箱'),
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (ctx) => BoxAddWidget(),
                                        fullscreenDialog: true))
                                    .then((e) {
                                  if (e) {
                                    _getFridgeList();
                                    setState(() {});
                                  }
                                });
                              })),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 6, color: const Color(0xffE0E0E0))
                            ]),
                        child: Column(
                          children: <Widget>[
                            //名称，未知，图标
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                    width: ScreenUtil().setWidth(48),
                                    height: ScreenUtil().setWidth(48),
                                    margin: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            width: 4,
                                            color: const Color(0xfff2f2f2))),
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
                                        Text(
                                          '王府井东方新天地',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: const Color(0xff8A8A8F)),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Align(
                                          alignment:
                                              AlignmentDirectional.topEnd,
                                          child: PopupMenuButton(
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (ctx) {
                                                return [
                                                  PopupMenuItem(
                                                      value: 0,
                                                      child: Text('编辑')),
                                                  PopupMenuItem(
                                                      value: 1,
                                                      child: Text('删除'))
                                                ];
                                              },
                                              onSelected: (e) {
                                                switch (e) {
                                                  case 0:
                                                    break;
                                                  default:
                                                    {
                                                      _deleteFridge(fridge.id);
                                                    }
                                                }
                                              })))
                                ],
                              ),
                            ),
                            // 分享
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        width: 4,
                                        color: const Color(0xffF2F2F2))),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Text('好友添加'),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                              child: Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerStart,
                                                  child: Container(
                                                    height: 16,
                                                    width: 16,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xffC8C7CC),
                                                          width: 1,
                                                        )),
                                                    child: Center(
                                                        child: Text(
                                                      '?',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: const Color(
                                                              0xffC8C7CC)),
                                                    )),
                                                  ))),
                                          CupertinoSwitch(
                                              activeColor: Colors.lightGreen,
                                              value: (fridge.sharecode !=
                                                      null &&
                                                  fridge.sharecode.isNotEmpty),
                                              onChanged: (e) {
                                                if (e) {
                                                  _openShare(fridge.id);
                                                } else {
                                                  _closeShare(fridge.id);
                                                }
                                              })
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                      ),
                                    ),
                                    Offstage(
                                      offstage: fridge.sharecode == null ||
                                          fridge.sharecode.isEmpty,
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(38, 15, 38, 11),
                                        decoration: BoxDecoration(
                                            color: const Color(0xffF2F2F2),
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(18))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text('分享码'),
                                            Text(
                                              fridge.sharecode ?? "",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Icon(Icons.share,
                                                color: Colors.lightGreen)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // 状态
                            Container(
                              //padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _stateContain('物品数量', '12'),
                                  _stateContain('冰箱状态', '充足'),
                                  Container(
                                      width: ScreenUtil().setWidth(100),
                                      height: ScreenUtil().setWidth(80),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          border: Border.all(
                                              width: 4,
                                              color: Colors.lightGreen)),
                                      child: Center(
                                        child: Text(
                                          '查看食材',
                                          style: TextStyle(
                                              color: Colors.lightGreen),
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
            itemCount: state.curList.length + 1),
      ),
    );
  }

  Widget _stateContain(String title, String content) {
    return Container(
      width: ScreenUtil().setWidth(100),
      height: ScreenUtil().setWidth(80),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(width: 4, color: const Color(0xffF2F2F2))),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, color: const Color(0xff666666)),
        ),
        Text(content, style: TextStyle(fontSize: 22))
      ]),
    );
  }

  _changeDefault(int boxid) async {
    await _setDefaultFridge(boxid);
    await _getFridgeList();
    setState(() {});
  }

  _getFridgeList() async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.get('/api/user-box/list');
    if (res.data['err'] != 0) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(res.data['errmsg'])));
      return;
    }
    List sources = res.data['data']['boxes'];
    List<Fridge> fridges = List<Fridge>.generate(sources.length, (idx) {
      return Fridge.fromJson(sources[idx]);
    });
    AppSharedState curProvider =
        Provider.of<AppSharedState>(widget.providerContext, listen: false);
    curProvider.changeBoxList(fridges);
    print(curProvider.curList);
  }

  _setDefaultFridge(int boxid) async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.get('/api/user-box/default?boxid=$boxid');
    if (res.data['err'] != 0) {
      print('set default Error');
      return;
    }
  }

  _openShare(int boxid) async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.get('/api/user-box/generate-sharecode',
        queryParameters: {'boxid': '$boxid'});
    if (res.data['err'] != 0) {
      BotToast.showText(text: '分享码获取失败，请重试');
      print('get share code error');
      return;
    }
    await _getFridgeList();
    setState(() {});
  }

  _closeShare(int boxid) async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.get('/api/user-box/cancel-sharecode',
        queryParameters: {'boxid': '$boxid'});
    if (res.data['err'] != 0) {
      BotToast.showText(text: '网络出错了，请重试');
      print('cloase share code error');
      return;
    }
    await _getFridgeList();
    setState(() {});
  }

  _deleteFridge(int boxid) async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.post('/api/user-box/delete',
        data:"id=$boxid",options: Options(contentType: "application/x-www-form-urlencoded"));
    if (res.data['err'] != 0) {
      BotToast.showText(text: '网络出错了，请重试');
      print('delege fridge error');
      return;
    }
    await _getFridgeList();
    setState(() {});
  }
}
