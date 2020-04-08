import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'foodDetail.dart';

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
                  borderRadius: 5,
                  isHorizal: true,
                  badgeContent: Text('过期',
                      style: TextStyle(fontSize: 10, color: Colors.white)),
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
}
