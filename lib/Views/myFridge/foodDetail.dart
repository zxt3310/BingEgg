import 'package:flutter/material.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'package:sirilike_flutter/webpage.dart';

class FoodDetailWidget extends StatefulWidget {
  final FoodMaterial food;
  FoodDetailWidget({Key key, this.food}) : super(key: key);

  @override
  _FoodDetailWidgetState createState() => _FoodDetailWidgetState();
}

class _FoodDetailWidgetState extends State<FoodDetailWidget> {
  Future requestFuture;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
          title: Text('${widget.food.itemName}',
              style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0,
          brightness: Brightness.dark),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(31))),
        child: FutureBuilder(
          future: requestFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Response res = snapshot.data;
              if (res.data['err'] != 0) {
                return Center(child: Text('琼求出错'));
              } else {
                FoodPageStruct data = FoodPageStruct.fromJson(res.data['data']);
                return getUI(data);
              }
            } else {
              return Center(child: Text('loading...'));
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    requestFuture = requestData();
  }

  Future requestData() {
    return NetManager.instance.dio.get(
        '/api/user-inventory/detail?itemid=${widget.food.itemId}&boxid=${widget.food.boxId}');
  }

  Widget getUI(FoodPageStruct data) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            //标题 图片
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(5),
                          child: Text('${widget.food.itemName}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.fromLTRB(15, 3, 15, 3),
                          child: Text(
                            '2天过期',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ))
                    ],
                  ),
                  Image.network(
                      'http://106.13.105.43:8889/static/images/item-pics/item-${widget.food.itemId}.jpg',
                      width: 64,
                      height: 64)
                ]),
            SizedBox(height: 10),
            //剩余 即将过期  一共
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                Widget>[
              Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(width: 3, color: Colors.grey[300]))),
              Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(width: 3, color: Colors.grey[300]))),
              Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(width: 3, color: Colors.grey[300]))),
            ]),
            SizedBox(height: 20),
            //库存
            Text('库存',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Container(
                height: 152,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.greenAccent)),
            SizedBox(height: 20),
            Text('推荐菜谱',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
        ),
        SliverGrid(
          delegate: SliverChildBuilderDelegate((context, idx) {
            Cookbooks book = data.cookbooks[idx];
            return GestureDetector(
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFFE0E0E0),
                                  offset: Offset(0, 1),
                                  blurRadius: 6)
                            ]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Flexible(
                                  child: Image.network(book.imgUrl,
                                      fit: BoxFit.fitWidth)),
                              Flexible(child: Center(child: Text(book.title)))
                            ],
                          ),
                        ))),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MainPage(url: book.webUrl)));
                });
          }, childCount: data.cookbooks.length),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 25,
              crossAxisSpacing: 25,
              childAspectRatio: 0.8),
        )
      ],
    );
  }
}
