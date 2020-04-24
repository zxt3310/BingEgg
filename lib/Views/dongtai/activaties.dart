import 'package:flutter/material.dart';
import 'dongtai.dart' show FriendAction;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sirilike_flutter/model/mainModel.dart';

class FriendActWidget extends StatefulWidget {
  final List data;

  FriendActWidget(this.data);
  @override
  _FriendActWidgetState createState() => _FriendActWidgetState();
}

class _FriendActWidgetState extends State<FriendActWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('好友动态', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: widget.data.length == 0
          ? Container(
              child: Center(
                child: Text('暂无动态'),
              ),
            )
          : Container(
              color: const Color(0xFFF9F9F9),
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    FriendAction action = widget.data[index];
                    return Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClipOval(
                                  child: FadeInImage.assetNetwork(
                                      placeholder: 'srouce/login_logo.png',
                                      image: action.avatar,
                                      width: 30,
                                      height: 30)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Text(action.name),
                                    SizedBox(height: 5),
                                    Text(action.message, maxLines: 1),
                                    SizedBox(height: 5),
                                    Wrap(children: _getActionsItem(action)),
                                  ],
                                ),
                              ),
                              Text(_getActTimeStr(action.lastUpdate),
                                  style: TextStyle(fontSize: 10)),
                            ]),
                      ),
                    );
                  },
                  itemCount: widget.data.length)),
    );
  }

  List<Widget> _getActionsItem(FriendAction action) {
    return List.generate(action.items.length, (idx) {
      FoodMaterial item = action.items[idx];
      return Padding(
        padding: const EdgeInsets.all(3.0),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
                width: 38,
                height: 38,
                placeholder: (ctx, str) {
                  return Text('loading...');
                },
                errorWidget: (ctx, str, obj) {
                  return Text('faild');
                },
                imageUrl:
                    "http://106.13.105.43:8889/static/images/item-pics/item-${item.itemId}.jpg")),
      );
    });
  }

  String _getActTimeStr(String timeStr) {
    DateFormat formater = DateFormat('yyyy-MM-ddTHH:mm:ss');
    DateTime create = formater.parse(timeStr);
    Duration duration = DateTime.now().difference(create);

    int days = duration.inDays;
    int hours = duration.inHours;
    int minutes = duration.inMinutes;

    if (days > 30) {
      return '${days ~/ 30}个月前';
    }

    if (days > 0) {
      return '$days天前';
    }

    if (hours > 0) {
      return '$hours小时前';
    }

    if (minutes > 0) {
      return '$minutes分钟前';
    }

    return "刚刚";
  }
}
