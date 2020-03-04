import 'package:flutter/material.dart';
import 'package:sirilike_flutter/model/mainModel.dart';

class FoodListWidget extends StatelessWidget {
  final List<FoodMaterial> foods;
  FoodListWidget(this.foods);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15),
        itemCount: foods.length,
        itemBuilder: (context, idx) {
          FoodMaterial obj = foods.elementAt(idx);
          return Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              //borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                obj.itemId == null
                    ? Text('图片')
                    : Image.network(
                        'http://106.13.105.43:8889/static/images/item-pics/item-${obj.itemId}.jpg',
                        fit: BoxFit.fitWidth,
                        scale: 2),
                Expanded(
                    child: Center(
                        child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text('${obj.itemName}'),
                    Text('数量：${obj.quantity}'),
                    Text(obj.getRemindDate(), textAlign: TextAlign.right)
                  ],
                )))
              ],
            ),
          );
        },
      ),
    );
  }
}
