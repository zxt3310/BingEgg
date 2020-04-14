import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'foodDetail.dart';
import 'package:intl/intl.dart';

class FoodListWidget extends StatelessWidget {
  final List<FoodMaterial> foods;
  FoodListWidget(this.foods);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: ListView.builder(
        itemCount: foods.length,
        itemBuilder: (context, idx) {
          FoodMaterial obj = foods.elementAt(idx);
          return Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Badge(
                  position: BadgePosition.topRight(top: 5),
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  shape: BadgeShape.square,
                  badgeColor: expiredColor(obj.expiryDate),
                  borderRadius: 5,
                  isHorizal: true,
                  badgeContent: Offstage(
                    offstage: !isExpiring(obj.expiryDate),
                    child: Text(expiredStr(obj.expiryDate),
                        style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                  child: GestureDetector(
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            obj.itemId == null
                                ? Text('图片')
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      'http://106.13.105.43:8889/static/images/item-pics/item-${obj.itemId}.jpg',
                                      width: 64,
                                      height: 64,
                                    )),
                            SizedBox(width: 15),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('${obj.itemName}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                Text(obj.getRemindDate(),
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.right)
                              ],
                            ),
                            Expanded(
                                child: Stack(children: [
                              Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: Text('数量：${QuantityStr.toStr(obj.quantity,unit:obj.unit)}'))
                            ]))
                          ],
                        )),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => FoodDetailWidget(food: obj)));
                    },
                  )));
        },
      ),
    );
  }

  bool isExpiring(String timeStr){
    DateFormat formater = DateFormat('yyyy-MM-dd');
    DateTime target = formater.parse(timeStr);
    DateTime now = DateTime.now().add(Duration(days: 5));
    return now.isAfter(target);
  }

  String expiredStr(String timeStr){
    DateFormat formater = DateFormat('yyyy-MM-dd');
    DateTime target = formater.parse(timeStr);
    DateTime now = DateTime.now();
    Duration during = target.difference(now);
    if(during.inDays <0){
      return "已过期";
    }
    if(during.inDays == 0){
      return "今天过期";
    }
    if(during.inDays>0){
      return "即将过期";
    }
    return "";
  }

  Color expiredColor(String timeStr){
    DateFormat formater = DateFormat('yyyy-MM-dd');
    DateTime target = formater.parse(timeStr);
    DateTime now = DateTime.now();
    Duration during = target.difference(now);
    if(during.inDays <0){
      return Colors.red;
    }
    if(during.inDays == 0){
      return Colors.orange;
    }
    if(during.inDays>0){
      return Colors.yellow;
    }
    return Colors.white;
  }
}
