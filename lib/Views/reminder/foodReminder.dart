import 'package:flutter/material.dart';
import '../myFridge/myFridge.dart' show FoodMaterial;
import 'dart:convert';

String jsonStr =
    '[{"id": 1, "item_id": null, "item_name": "\u9e21\u86cb", "quantity": 24, "created_at": "2019-12-08 06:23:49"}, {"id": 2, "item_id": null, "item_name": "\u652f\u4e0b", "quantity": 20, "created_at": "2019-12-08 07:36:28"}, {"id": 3, "item_id": null, "item_name": "\u852c\u83dc", "quantity": 20, "created_at": "2019-12-08 07:37:27"}, {"id": 5, "item_id": null, "item_name": "\u9e21", "quantity": 1, "created_at": "2019-12-08 13:36:15"}, {"id": 6, "item_id": null, "item_name": "\u8304\u5b50", "quantity": 4, "created_at": "2019-12-08 13:36:24"}, {"id": 7, "item_id": null, "item_name": "\u72d7", "quantity": 3, "created_at": "2019-12-08 13:49:16"}, {"id": 9, "item_id": null, "item_name": "\u80e1\u841d\u535c", "quantity": 1, "created_at": "2019-12-10 02:15:37"}, {"id": 10, "item_id": null, "item_name": "\u9999\u8549", "quantity": 1, "created_at": "2019-12-11 11:08:18"}]';

class FoodReminderWidget extends StatefulWidget {
  @override
  _FoodReminderWidgetState createState() => _FoodReminderWidgetState();
}

class _FoodReminderWidgetState extends State<FoodReminderWidget> {
  @override
  Widget build(BuildContext context) {
    List datas = json.decode(jsonStr);
    List<FoodMaterial> foods = List<FoodMaterial>.generate(datas.length, (idx) {
      return FoodMaterial.fromJson(datas[idx]);
    });
    return Container(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    FoodMaterial obj = foods.elementAt(index);
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text('${obj.itemName}'),
                          Text('数量：${obj.quantity}'),
                          Text('放入时间：${obj.createdAt}',
                              textAlign: TextAlign.center)
                        ],
                      ),
                    );
                  }, childCount: foods.length))),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, idx) {
                      return Container(
                        width: 70,
                        height: 70,
                        margin: EdgeInsets.all(10),
                        color: Colors.redAccent,
                      );
                    },
                  ))
            ]),
          ),
        ],
      ),
    );
  }
}
