import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'foodItemList.dart';
import '../../model/network.dart';

List<String> namelist = ['全部', '水果', '蔬菜', '肉类', '饮品'];

class MyFridgeWidget extends StatelessWidget {
  final CurrentFridgeListProvider curFridgeState = CurrentFridgeListProvider();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CurrentFridgeListProvider>(
        create: (context) => curFridgeState,
        child: Scaffold(
          appBar: AppBar(
            title: TitleHeaderWidget(),
          ),
          body: _FridgeWidget(),
        ));
  }
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
                return List.generate(2, (idx) {
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

  _showDialoge() {
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      barrierColor: const Color(0x77000000),
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return Column(
            children:<Widget>[SizedBox(height: 100) ,CupertinoAlertDialog(title: Text('Alert'))]);
      },
      transitionBuilder: (ctx,animation,_,child){
        return ScaleTransition(
          alignment: Alignment.topLeft,
          scale: animation,
          child: child,
        );
      }
    );
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
