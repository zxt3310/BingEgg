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
        builder: (BuildContext context, value, Widget child) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 30),
            Text('我的冰箱'),
            PopupMenuButton(
              icon: Icon(Icons.arrow_drop_down),
              itemBuilder: (context) {
                return List.generate(2, (idx) {
                  return PopupMenuItem(child: Text('选项卡'));
                });
              },
            )
          ],
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                    return Consumer<CurrentIndexProvider>(
                        builder: (context, cur, child) {
                      return FoodListWidget(cur.foods);
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
    if (expiryDate.isNotEmpty) {
      int days = 0;
      int hours = 0;
      DateTime expire = DateTime.parse(expiryDate);
      DateTime create = DateTime.parse(lastDateAdd);
      Duration duration = expire.difference(create);
      hours = duration.inHours;
      days = hours ~/ 24;
      if (days > 0) {
        return '$days天 ${hours % 24}小时后过期';
      } else {
        return '$hours小时后过期';
      }
    } else {
      return '放入时间:$lastDateAdd';
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
        isdefault = json['isdefault'] == 0 ? false : true;
}

class CurrentFridgeListProvider with ChangeNotifier {
  List<Fridge> curList;
  int curIndex = 0;

  changeList(List<Fridge> list) {
    curList = list;
    notifyListeners();
  }

  changeIndex(int idx) {
    curIndex = idx;
    notifyListeners();
  }
}
