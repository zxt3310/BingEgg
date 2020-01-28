import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'foodItemList.dart';
import '../../model/network.dart';

import 'package:sirilike_flutter/voiceArs.dart';
import 'package:sirilike_flutter/Views/userAndSetting/mine.dart'
    show CustomRoute;

export 'package:provider/provider.dart';

List<String> namelist = ['全部', '水果', '蔬菜', '肉类', '饮品'];

class MyFridgeWidget extends StatefulWidget {
  @override
  _MyFridgeWidgetState createState() => _MyFridgeWidgetState();
}

class _MyFridgeWidgetState extends State<MyFridgeWidget> with AutomaticKeepAliveClientMixin {
  final CurrentFridgeListProvider curFridgeState = CurrentFridgeListProvider();

  

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CurrentFridgeListProvider>(
        create: (context) => curFridgeState,
        child: Scaffold(
          appBar: AppBar(
            leading: Text(''),
            actions: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () {
                  Navigator.of(context)
                      .push(CustomRoute(AsrTTSModel(provider: curFridgeState)));
                },
                label: Text(''),
              )
            ],
            title: TitleHeaderWidget(),
          ),
          body: _FridgeWidget(),
        ));
  }

  @override

  bool get wantKeepAlive => true;
}


class TitleHeaderWidget extends StatefulWidget {
  @override
  _TitleHeaderWidgetState createState() => _TitleHeaderWidgetState();
}

class _TitleHeaderWidgetState extends State<TitleHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentFridgeListProvider>(
        builder: (BuildContext context, curFridges, Widget child) {
      if (curFridges.curList == null) {
        return Container();
      }
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 30),
            Text('${curFridges.curList[curFridges.curIndex].boxname}'),
            PopupMenuButton(
              icon: Icon(Icons.arrow_drop_down),
              itemBuilder: (context) {
                return List.generate(curFridges.curList.length, (idx) {
                  return PopupMenuItem(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${curFridges.curList[idx].boxname}'),
                          curFridges.curList[idx].id == curFridges.defaultId
                              ? Text('当前默认',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12))
                              : GestureDetector(
                                  child: Text('设为默认',
                                      style: TextStyle(fontSize: 12)),
                                  onTap: () {
                                    _setDefaultFridge(
                                        curFridges.curList[idx].id);
                                  })
                        ],
                      ),
                      value: idx);
                }, growable: true)
                  ..add(PopupMenuItem(
                    child: Center(
                        child: Text('+ 新增冰箱', textAlign: TextAlign.center)),
                    value: 999,
                  ));
              },
              onSelected: (e) {
                if (e == 999) {
                  _showDialoge();
                  return;
                }
                curFridges.changeIndex(e);
              },
            )
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    print('dealloc');
  }

  @override
  void initState() {
    super.initState();
    _getFridgeList();
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
    CurrentFridgeListProvider curProvider =
        Provider.of<CurrentFridgeListProvider>(context);
    curProvider.changeList(fridges);

    for (int i = 0; i < fridges.length; i++) {
      Fridge fridge = fridges.elementAt(i);
      if (fridge.isdefault) {
        curProvider.changeIndex(i);
        curProvider.changeDefaultFridge(fridge.id);
      }
    }

    print(curProvider.curList);
  }

  _setDefaultFridge(int boxid) async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.get('/api/user-box/default?boxid=$boxid');
    if (res.data['err'] != 0) {
      print('set default Error');
      return;
    }
    CurrentFridgeListProvider curProvider =
        Provider.of<CurrentFridgeListProvider>(context);
    curProvider.changeDefaultFridge(boxid);
  }

  String newFridgeName = '';
  _showDialoge() {
    showGeneralDialog(
        context: context,
        barrierLabel: '',
        barrierDismissible: true,
        barrierColor: const Color(0x77000000),
        transitionDuration: Duration(milliseconds: 200),
        pageBuilder: (ctx, anim1, anim2) {
          return Scaffold(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            resizeToAvoidBottomInset: false,
            body: Stack(children: <Widget>[
              Align(
                  alignment: Alignment(0, -0.65),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      width: 300,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          Align(
                            alignment: Alignment(0, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[300]),
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                              margin: EdgeInsets.all(20),
                              child: Row(
                                children: <Widget>[
                                  Text('冰箱名称',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          decoration: TextDecoration.none)),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                          prefix: SizedBox(width: 10),
                                          hintText: "请输入",
                                          border: InputBorder.none),
                                      style: new TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      onChanged: (str) {
                                        newFridgeName = str;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 300,
                            height: 50,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                                Expanded(
                                    child: MaterialButton(
                                  minWidth: 300,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(15))),
                                  child: Text('+ 添加'),
                                  onPressed: () {
                                    if (newFridgeName.isNotEmpty) {
                                      _addFridge(newFridgeName, context);
                                    }
                                  },
                                )),
                              ],
                            ),
                          ),
                        ],
                      ))),
              Align(
                alignment: Alignment(0, -0.8),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.circular(35)),
                  child: ClipOval(
                      child: Image.asset('srouce/fridge_icon.jpg',
                          fit: BoxFit.contain)),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.1),
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.grey[300]),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ]),
          );
        },
        transitionBuilder: (ctx, animation, _, child) {
          return ScaleTransition(
            alignment: Alignment.topLeft,
            scale: animation,
            child: child,
          );
        });
  }

  _addFridge(String name, BuildContext ctx) async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.post('/api/user-box/add',
        data: {"name": name},
        options: Options(contentType: "application/x-www-form-urlencoded"));
    if (res.data['err'] != 0) {
      Navigator.of(ctx).pop();
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('${res.data['errmsg']}')));
      return;
    }
    Navigator.of(ctx).pop();
    _getFridgeList();
  }
}

class _FridgeWidget extends StatefulWidget {
  @override
  __FridgeWidgetState createState() => __FridgeWidgetState();
}

class __FridgeWidgetState extends State<_FridgeWidget>
    with SingleTickerProviderStateMixin {
  CurrentIndexProvider curState = CurrentIndexProvider();

  TabController tabcontroller;
  PageController pageController;
  @override
  void initState() {
    pageController = PageController();
    tabcontroller = TabController(vsync: this, length: namelist.length);
    super.initState();
  }

  _onChangeTab(e) {
    curState.changeIdx(e);
    pageController.animateToPage(e,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
  }

  _onChangePage(e) {
    curState.changeIdx(e);
    tabcontroller.index = e;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => curState,
        child: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TabBar(
                  indicator: const BoxDecoration(),
                  controller: tabcontroller,
                  isScrollable: true,
                  tabs: _getBtns(namelist),
                  onTap: _onChangeTab,
                ),
                Expanded(
                    child: PageView.builder(
                  itemCount: namelist.length,
                  controller: pageController,
                  onPageChanged: _onChangePage,
                  itemBuilder: (BuildContext context, int index) {
                    return Consumer<CurrentFridgeListProvider>(
                        builder: (context, curFri, child) {
                      return Consumer<CurrentIndexProvider>(
                          builder: (context, cur, child) {
                        if (cur.filterOfBoxid(curFri.curBoxid).isEmpty) {
                          return Container(
                            child: Center(
                              child: Text('冰箱是空的哦'),
                            ),
                          );
                        }
                        return FoodListWidget(
                            cur.filterOfBoxid(curFri.curBoxid));
                      });
                    });
                  },
                )),
              ]),
        ));
  }

  List<Widget> _getBtns(List<String> names) {
    return List<Widget>.generate(
      names.length,
      (idx) {
        return Consumer<CurrentIndexProvider>(builder: (context, cur, child) {
          return Container(
              padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
              child: Column(
                children: <Widget>[
                  Icon(Icons.camera,
                      color:
                          idx == cur.curIdx ? Colors.greenAccent : Colors.grey),
                  Text('${names[idx]}', style: TextStyle(color: Colors.black)),
                ],
              ));
        });
      },
    );
  }

  _getDataSource() async {
    NetManager ntMgr = NetManager.instance;
    Response res = await ntMgr.dio.get('/api/user-inventory/list');

    if (res.data['err'] != 0) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(res.data['errmsg'])));
      return;
    }
    List datas = res.data['data']['inventories'];

    List<FoodMaterial> foods = List<FoodMaterial>.generate(datas.length, (idx) {
      return FoodMaterial.fromJson(datas[idx]);
    });
    curState.changeSource(foods);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context == this.context) {
      _getDataSource();
    }
  }
}

class CurrentIndexProvider with ChangeNotifier {
  int curIdx = 0;
  List<FoodMaterial> foods = [];

  changeIdx(int newIdx) {
    curIdx = newIdx;
    notifyListeners();
  }

  changeSource(List<FoodMaterial> source) {
    foods = source;
    notifyListeners();
  }

  List<FoodMaterial> filterOfBoxid(int boxid) {
    List<FoodMaterial> result = [];
    for (FoodMaterial food in foods) {
      if (food.boxId == boxid) {
        result.add(food);
      }
    }
    return result;
  }
}

class FoodMaterial {
  final int id;
  final int itemId;
  final int boxId;
  final String itemName;
  final int quantity;
  final String createdAt;
  final String expiryDate;
  final String lastDateAdd;

  FoodMaterial(this.id, this.itemId, this.boxId, this.itemName, this.quantity,
      this.createdAt, this.expiryDate, this.lastDateAdd);
  FoodMaterial.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        itemId = json['item_id'],
        boxId = json['box_id'],
        itemName = json['item_name'],
        quantity = json['quantity'],
        createdAt = json['created_at'],
        expiryDate = json['expiry_date'],
        lastDateAdd = json['last_dateadd'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        'box_id': boxId,
        'item_name': itemName,
        'quantity': quantity,
        'create_at': createdAt,
        'expiry_date': expiryDate,
        'last_dateadd': lastDateAdd
      };

  String getRemindDate() {
    DateTime create = DateTime.parse(lastDateAdd);
    if (expiryDate.isNotEmpty) {
      int days = 0;
      int hours = 0;
      DateTime expire = DateTime.parse(expiryDate);
      Duration duration = expire.difference(create);
      hours = duration.inHours;
      days = hours ~/ 24;
      if (days > 0) {
        return '$days天后过期';
      } else {
        return '$hours小时后过期';
      }
    } else {
      Duration duration = DateTime.now().difference(create);
      int days = duration.inDays;
      int hours = duration.inHours;
      return hours > 0 ? days > 0 ? '已放入$days天' : '已放入$hours小时' : '刚刚放入';
    }
  }
}

class Fridge {
  final int id;
  final String boxname;
  final bool isdefault;
  Fridge(this.id, this.boxname, this.isdefault);

  Fridge.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        boxname = json['box_name'],
        isdefault = json['is_default'] == 0 ? false : true;
}

class CurrentFridgeListProvider with ChangeNotifier {
  List<Fridge> curList;
  int curIndex = 0;
  int curBoxid = 0;
  int defaultId = 0;

  changeList(List<Fridge> list) {
    curList = list;
    notifyListeners();
  }

  changeIndex(int idx) {
    curIndex = idx;
    curBoxid = curList[idx].id;
    notifyListeners();
  }

  changeDefaultFridge(int boxid) {
    defaultId = boxid;
  }
}
