import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'foodItemList.dart';
import 'dart:convert';

List<String> namelist = ['全部', '水果', '蔬菜', '肉类', '饮品'];
String jsonStr =
    '[{"id": 1, "item_id": null, "item_name": "\u9e21\u86cb", "quantity": 24, "created_at": "2019-12-08 06:23:49"}, {"id": 2, "item_id": null, "item_name": "\u652f\u4e0b", "quantity": 20, "created_at": "2019-12-08 07:36:28"}, {"id": 3, "item_id": null, "item_name": "\u852c\u83dc", "quantity": 20, "created_at": "2019-12-08 07:37:27"}, {"id": 5, "item_id": null, "item_name": "\u9e21", "quantity": 1, "created_at": "2019-12-08 13:36:15"}, {"id": 6, "item_id": null, "item_name": "\u8304\u5b50", "quantity": 4, "created_at": "2019-12-08 13:36:24"}, {"id": 7, "item_id": null, "item_name": "\u72d7", "quantity": 3, "created_at": "2019-12-08 13:49:16"}, {"id": 9, "item_id": null, "item_name": "\u80e1\u841d\u535c", "quantity": 1, "created_at": "2019-12-10 02:15:37"}, {"id": 10, "item_id": null, "item_name": "\u9999\u8549", "quantity": 1, "created_at": "2019-12-11 11:08:18"}]';

class MyFridgeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _FridgeWidget(),
    );
  }
}

class _FridgeWidget extends StatefulWidget {
  @override
  __FridgeWidgetState createState() => __FridgeWidgetState();
}

class __FridgeWidgetState extends State<_FridgeWidget>
    with SingleTickerProviderStateMixin {
  CurrentIndexProvider curIdx = CurrentIndexProvider();

  TabController tabcontroller;
  PageController pageController;
  @override
  void initState() {
    pageController = PageController();
    tabcontroller = TabController(vsync: this, length: namelist.length);
    super.initState();
  }

  _onChangeTab(e) {
    curIdx.changeIdx(e);
    pageController.jumpToPage(e);
  }

  _onChangePage(e) {
    curIdx.changeIdx(e);
    tabcontroller.index = e;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => curIdx,
        child: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TabBar(
                  indicator: const BoxDecoration(),
                  controller: tabcontroller,
                  tabs: _getBtns(namelist),
                  onTap: _onChangeTab,
                ),
                Expanded(
                    child: PageView.builder(
                  itemCount: namelist.length,
                  controller: pageController,
                  onPageChanged: _onChangePage,
                  itemBuilder: (BuildContext context, int index) {
                    List datas = json.decode(jsonStr);
                    List <FoodMaterial> foods = List<FoodMaterial>.generate(datas.length, (idx){
                      return FoodMaterial.fromJson(datas[idx]);
                    });
                    return FoodListWidget(foods);
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
              child: Column(
            children: <Widget>[
              Icon(Icons.camera,
                  color: idx == cur.curIdx ? Colors.greenAccent : Colors.grey),
              Text('${names[idx]}', style: TextStyle(color: Colors.black)),
            ],
          ));
        });
      },
    );
  }
}

class CurrentIndexProvider with ChangeNotifier {
  int curIdx = 0;
  changeIdx(int newIdx) {
    curIdx = newIdx;
    notifyListeners();
  }
}

class FoodMaterial {
  final int id;
  final int itemId;
  final String itemName;
  final int quantity;
  final String createdAt;

  FoodMaterial(
      this.id, this.itemId, this.itemName, this.quantity, this.createdAt);
  FoodMaterial.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        itemId = json['item_id'],
        itemName = json['item_name'],
        quantity = json['quantity'],
        createdAt = json['created_at'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        'item_name': itemName,
        'quantity': quantity,
        'create_at': createdAt
      };
}
