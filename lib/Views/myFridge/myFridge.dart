import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sirilike_flutter/Views/userAndSetting/boxAdd.dart';
import 'package:sirilike_flutter/main.dart';
import 'foodItemList.dart';
import '../../model/network.dart';
import 'package:sirilike_flutter/model/event.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/main.dart' show AppSharedState;
export 'package:provider/provider.dart';

//List<String> namelist = ['全部', '水果', '蔬菜', '肉类', '饮品'];
const int catMax = 7;

class MyFridgeWidget extends StatefulWidget {
  @override
  _MyFridgeWidgetState createState() => _MyFridgeWidgetState();
}

class _MyFridgeWidgetState extends State<MyFridgeWidget> {
  Future requestFuture;
  @override
  void initState() {
    requestFuture = requestCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TitleHeaderWidget(),
        brightness: Brightness.dark,
        centerTitle: true,
        leading: Text(""),
        actions: <Widget>[_EditeBtn()],
      ),
      body: FutureBuilder(
        future: requestFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Response res = snapshot.data;
            if (res.data['err'] != 0) {
              return Container(
                child: Center(child: Text('loading...')),
              );
            } else {
              List category = res.data['data']['categories'];
              if (category[0]['id'] != 0) {
                category.insert(0, {'name': '全部', 'id': 0});
              }
              return _FridgeWidget(category);
            }
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Future requestCategory() async {
    NetManager manager = NetManager.instance;
    return manager.dio.get('/api/basic-data/fetch');
  }
}

//冰箱页主体
class TitleHeaderWidget extends StatefulWidget {
  @override
  _TitleHeaderWidgetState createState() => _TitleHeaderWidgetState();
}

class _TitleHeaderWidgetState extends State<TitleHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppSharedState>(
        builder: (BuildContext context, curFridges, Widget child) {
      if (curFridges.curList.isEmpty) {
        return Center(
            child: FlatButton(
          child: Text('点击此处添加冰箱',
              style: TextStyle(color: Colors.white, fontSize: 13)),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (ctx) => BoxAddWidget(fridge: Fridge())))
                .then((e) {
              if (e) {
                _getFridgeList();
              }
            });
          },
        ));
      }
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 30),
            Text('${curFridges.curList[curFridges.curBoxIndex].boxname}',
                style: TextStyle(color: Colors.white)),
            PopupMenuButton(
              offset: Offset(0, 40),
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              itemBuilder: (context) {
                return List.generate(curFridges.curList.length, (idx) {
                  return PopupMenuItem(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${curFridges.curList[idx].boxname}'),
                          Checkbox(
                              value: idx == curFridges.curBoxIndex,
                              onChanged: (e) {})
                        ],
                      ),
                      value: idx);
                }, growable: true);
              },
              onSelected: (e) {
                curFridges.changeCurIndex(e);
                curFridges.freshBox(curFridges.curList[e].id);
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
    AppSharedState curProvider =
        Provider.of<AppSharedState>(context, listen: false);
    curProvider.changeBoxList(fridges);

    for (int i = 0; i < fridges.length; i++) {
      Fridge fridge = fridges.elementAt(i);
      if (fridge.isdefault) {
        curProvider.changeCurIndex(i);
        curProvider.freshBox(fridge.id);
      }
    }

    print(curProvider.curList);
  }
}

class _FridgeWidget extends StatefulWidget {
  @override
  __FridgeWidgetState createState() => __FridgeWidgetState();

  final List nameList;

  _FridgeWidget(this.nameList);
}

class __FridgeWidgetState extends State<_FridgeWidget>
    with SingleTickerProviderStateMixin {
  CurrentIndexProvider curState = CurrentIndexProvider();
  TabController tabcontroller;
  PageController pageController;

  StreamSubscription subscription;
  @override
  void initState() {
    pageController = PageController();
    tabcontroller = TabController(
      vsync: this,
      length: min(widget.nameList.length, catMax),
    );
    super.initState();
    _getDataSource();

    subscription = myEvent.on().listen((event) {
      _getDataSource();
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  _onChangeTab(e) {
    curState.changeIdx(e);
    pageController.animateToPage(e,
        duration: Duration(milliseconds: 300), curve: Curves.linear);
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
                  //indicator: const BoxDecoration(),
                  controller: tabcontroller,
                  isScrollable: true,
                  tabs: _getBtns(widget.nameList),
                  onTap: _onChangeTab,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                ),
                Expanded(
                    child: PageView.builder(
                  itemCount: min(widget.nameList.length, catMax),
                  controller: pageController,
                  onPageChanged: _onChangePage,
                  itemBuilder: (BuildContext context, int index) {
                    return Consumer<AppSharedState>(
                        builder: (context, curFri, child) {
                      return Consumer<CurrentIndexProvider>(
                          builder: (context, cur, child) {
                        if (curFri.curList.length == 0) {
                          return Center(
                              child: FlatButton(
                            child: Text('点击此处添加冰箱',
                                style: TextStyle(fontSize: 13)),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (ctx) =>
                                          BoxAddWidget(fridge: Fridge())))
                                  .then((e) {
                                if (e) {
                                  //_getFridgeList();
                                }
                              });
                            },
                          ));
                        }
                        if (cur.filterOfBoxid(curFri.curBoxId, index).isEmpty) {
                          return Container(
                            child: Center(
                              child: Text('未放入此类食品'),
                            ),
                          );
                        }
                        return FoodListWidget(
                            cur.filterOfBoxid(curFri.curBoxId, index));
                      });
                    });
                  },
                )),
              ]),
        ));
  }

  List<Widget> _getBtns(List names) {
    return List<Widget>.generate(
      min(names.length, catMax),
      (idx) {
        return Consumer<CurrentIndexProvider>(builder: (context, cur, child) {
          return Container(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: <Widget>[
                  idx < catMax - 1
                      ? Image.asset(
                          "srouce/category/ico_cat_$idx.png",
                          width: 38,
                          height: 38,
                        )
                      : Image.asset(
                          "srouce/category/ico_cat_other.png",
                          width: 38,
                          height: 38,
                        ),
                  Text(idx < catMax - 1 ? '${names[idx]['name']}' : '其他',
                      style: TextStyle(
                          color: idx == cur.curIdx
                              ? Colors.lightGreen
                              : Colors.grey)),
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

    print('food items reloading ....');
  }
}

class _EditeBtn extends StatefulWidget {
  @override
  __EditeBtnState createState() => __EditeBtnState();
}

class __EditeBtnState extends State<_EditeBtn> {
  bool isEditing = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
        onPressed: () {
          setState(() {
            isEditing = !isEditing;
          });
          fridgeEditEvent.fire(null);
        },
        icon: Icon(
          isEditing ? Icons.done : Icons.edit,
          size: 15,
          color: Colors.white,
        ),
        label: Text(isEditing ? '完成' : '编辑',
            style: TextStyle(color: Colors.white)));
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

  List<FoodMaterial> filterOfBoxid(int boxid, int catagory) {
    List<FoodMaterial> result = [];
    for (FoodMaterial food in foods) {
      if (food.boxId == boxid) {
        if (catagory == 0 || catagory == food.category) {
          result.add(food);
          continue;
        }

        if (food.category >= catMax - 1 && catagory >= catMax - 1) {
          result.add(food);
          continue;
        }
      }
    }
    return result;
  }
}

// class CurrentFridgeListProvider with ChangeNotifier {
//   List<Fridge> curList;
//   int curIndex = 0;
//   int curBoxid = 0;
//   int defaultId = 0;

//   changeList(List<Fridge> list) {
//     curList = list;
//     notifyListeners();
//   }

//   changeIndex(int idx) {
//     curIndex = idx;
//     curBoxid = curList[idx].id;
//     notifyListeners();
//   }

//   changeDefaultFridge(int boxid) {
//     defaultId = boxid;
//   }
// }
