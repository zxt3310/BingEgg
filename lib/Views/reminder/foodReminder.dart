import 'package:flutter/material.dart';
import '../myFridge/myFridge.dart' show FoodMaterial;
import '../../model/network.dart';
import 'dart:convert';

String jsonStr =
    '[{"id": 1, "item_id": null, "item_name": "\u9e21\u86cb", "quantity": 24, "created_at": "2019-12-08 06:23:49"}, {"id": 2, "item_id": null, "item_name": "\u652f\u4e0b", "quantity": 20, "created_at": "2019-12-08 07:36:28"}]';

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
    return Scaffold(
        appBar: AppBar(
          title: Text('提醒'),
        ),
        body: Container(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                child: Text('快过期xxxxx', style: TextStyle(fontSize: 16)),
              )),
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
              SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text('特别提醒', style: TextStyle(fontSize: 16)),
                    ),
                    Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 10,
                          itemBuilder: (context, idx) {
                            return Container(
                              width: 160,
                              margin: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: <Widget>[
                                  Text('data'),
                                  Align(
                                    alignment: Alignment(1.6, 0),
                                    child: Image.asset(
                                        idx % 2 == 0
                                            ? 'srouce/草莓.png'
                                            : 'srouce/苹果.png',
                                        width: 64,
                                        height: 64),
                                  )
                                ],
                              ),
                            );
                          },
                        ))
                  ])),
            ],
          ),
        ));
  }

  _getDataSource() async{
    NetManager ntMgr = NetManager.instance;
    Response res =await ntMgr.dio.get('/api/user-inventory/list');
    
    if(res.data['err'] != 0){
      Scaffold.of(context).showSnackBar(SnackBar(content:Text(res.data['errmsg'])));
      return;
    }
    List datas = res.data['data']['inventories'];

    List<FoodMaterial> foods = List<FoodMaterial>.generate(datas.length, (idx) {
      return FoodMaterial.fromJson(datas[idx]);
    });
    //curState.changeSource(foods);
  }
}
