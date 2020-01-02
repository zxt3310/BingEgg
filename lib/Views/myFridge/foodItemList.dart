import 'package:flutter/material.dart';
import 'myFridge.dart' show FoodMaterial;

class FoodListWidget extends StatelessWidget {
  final List<FoodMaterial> foods;
  FoodListWidget(this.foods);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: foods.length,
        itemBuilder: (context, idx) {
          FoodMaterial obj = foods.elementAt(idx);
          return Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('${obj.itemName}'),
                Text('数量：${obj.quantity}'),
                Text('放入时间：${obj.createdAt}', textAlign: TextAlign.center)
              ],
            ),
          );
        },
      ),
    );
  }
}
