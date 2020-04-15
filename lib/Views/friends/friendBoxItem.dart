import 'package:flutter/material.dart';
import 'package:sirilike_flutter/Views/myFridge/foodItemList.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/model/network.dart';

class FriendBoxItemsWidget extends StatefulWidget {
  final String friendId;
  final String boxName;
  FriendBoxItemsWidget({this.friendId,this.boxName});
  @override
  _FriendBoxItemsWidgetState createState() => _FriendBoxItemsWidgetState();
}

class _FriendBoxItemsWidgetState extends State<FriendBoxItemsWidget> {
  Future<List<FoodMaterial>> dataFuture;
  @override
  void initState() {
    dataFuture = requestData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.boxName,style: TextStyle(color: Colors.white)),
        brightness: Brightness.dark,
        centerTitle: true,
      ),
      body: FutureBuilder<List<FoodMaterial>>(
          future: dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return FoodListWidget(snapshot.data);
            }else{
              return Container(child: Center(child: Text('loading......'),),);
            }
          }),
    );
  }

  Future<List<FoodMaterial>> requestData() async {
    Response res = await NetManager.instance.dio
        .get('/api/friend-inventory/list?fid=${widget.friendId}');
    if (res.data['err'] != 0) {
      return null;
    }
    List<FoodMaterial> list =
        FoodMaterial.getList(res.data['data']['inventories']);
    return list;
  }
}
