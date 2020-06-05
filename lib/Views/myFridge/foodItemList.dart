import 'dart:async';

import 'package:badges/badges.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sirilike_flutter/model/event.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'foodDetail.dart';
import 'package:intl/intl.dart';

class FoodListWidget extends StatefulWidget {
  final List<FoodMaterial> foods;
  FoodListWidget(this.foods);
  @override
  _FoodListWidgetState createState() => _FoodListWidgetState();
}

class _FoodListWidgetState extends State<FoodListWidget>
    with SingleTickerProviderStateMixin {


//平移动画控制器
  AnimationController mAnimationController;
//提供一个曲线，使动画感觉更流畅
  CurvedAnimation offsetCurvedAnimation;
//平移动画
  Animation<double> offsetAnim;
  //编辑通知流
  StreamSubscription subscription;

  bool isEditing = false;

  @override
  void initState() {
    mAnimationController =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    offsetCurvedAnimation =
        new CurvedAnimation(parent: mAnimationController, curve: Curves.linear);
    offsetAnim =
        Tween<double>(begin: 0, end: 0.02).animate(offsetCurvedAnimation);
    subscription = fridgeEditEvent.on().listen((e) {
      isEditing = !isEditing;
      if (isEditing) {
        setState(() {});
        mAnimationController.repeat(reverse: true);
      } else {
        setState(() {});
        mAnimationController.reverse(from: 0);
        mAnimationController.stop();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: ListView.builder(
        itemCount: widget.foods.length,
        itemBuilder: (context, idx) {
          FoodMaterial obj = widget.foods.elementAt(idx);
          return Stack(
            children: <Widget>[
              Padding(
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
                            style:
                                TextStyle(fontSize: 10, color: Colors.white)),
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
                                    : RotationTransition(
                                        turns: offsetAnim,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.network(
                                              'http://106.13.105.43:8889/static/images/item-pics/item-${obj.itemId}.jpg',
                                              width: 64,
                                              height: 64,
                                            )),
                                      ),
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
                                      child: Text(
                                          '数量：${QuantityStr.toStr(obj.quantity, unit: obj.unit)}'))
                                ]))
                              ],
                            )),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            settings: RouteSettings(name: '食材详情页'),
                              builder: (ctx) => FoodDetailWidget(food: obj)));
                        },
                      ))),
              Positioned(
                  top: 8,
                  left: 8,
                  child: Offstage(
                    offstage: !isEditing,
                    child: GestureDetector(
                      onTap: () {
                        removeItem(obj.itemId, obj.boxId);
                      },
                      child: Icon(Icons.cancel, size: 15, color: Colors.red),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  removeItem(int itemId, int boxId) async {
    showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
              title: Text('确认'),
              content: Text('移除该食材'),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text('确定'),
                    onPressed: () async {
                      Response res = await NetManager.instance.dio.get(
                          '/api/user-inventory/reset?itemid=$itemId&boxid=$boxId');
                      if (res.data['err'] != 0) {
                        BotToast.showText(text: '清空该食材出错了哦~');
                        return;
                      }
                      Navigator.of(ctx).pop();
                      myEvent.fire(null);
                    }),
                CupertinoDialogAction(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    }),
              ],
            ));
  }

  bool isExpiring(String timeStr) {
    DateFormat formater = DateFormat('yyyy-MM-dd');
    DateTime target = formater.parse(timeStr);
    DateTime now = DateTime.now().add(Duration(days: 5));
    return now.isAfter(target);
  }

  String expiredStr(String timeStr) {
    DateFormat formater = DateFormat('yyyy-MM-dd');
    DateTime target = formater.parse(timeStr);
    DateTime now = DateTime.now();
    Duration during = target.difference(now);
    if (during.inDays < 0) {
      return "已过期";
    }
    if (during.inDays == 0) {
      return "今天过期";
    }
    if (during.inDays > 0) {
      return "即将过期";
    }
    return "";
  }

  Color expiredColor(String timeStr) {
    DateFormat formater = DateFormat('yyyy-MM-dd');
    DateTime target = formater.parse(timeStr);
    DateTime now = DateTime.now();
    Duration during = target.difference(now);
    if (during.inDays < 0) {
      return Colors.red;
    }
    if (during.inDays == 0) {
      return Colors.orange;
    }
    if (during.inDays > 0) {
      return Colors.yellow;
    }
    return Colors.white;
  }
}
