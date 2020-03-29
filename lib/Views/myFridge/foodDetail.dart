import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'package:sirilike_flutter/webpage.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                return Center(child: Text('请求出错'));
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
                              color: const Color(0xffFF8B6B),
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
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _statusWidget(
                      '剩余',
                      data.itemStatus.totalRest.toDouble(),
                      data.itemStatus.unit,
                      const Color(0xff437722),
                      const Color(0xffD8F0BF)),
                  _statusWidget(
                      '即将过期',
                      data.itemStatus.expireSoon.toDouble(),
                      data.itemStatus.unit,
                      const Color(0xffF5635E),
                      const Color(0xffFBF5F0)),
                  _statusWidget(
                      '一共吃掉',
                      data.itemStatus.totalTaken.toDouble(),
                      data.itemStatus.unit,
                      const Color(0xff66B7A6),
                      const Color(0xffCFECEB))
                ]),
            SizedBox(height: 20),
            //库存
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text('库存',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Table(
                columnWidths: {
                  0: FlexColumnWidth(6),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                },
                children: batchesTale(data.batches,data.itemStatus.totalRest),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text('推荐菜谱',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
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
                                  child: CachedNetworkImage(
                                imageUrl: book.imgUrl,
                                fit: BoxFit.fitWidth,
                                placeholder: (ctx, str) {
                                  return Center(
                                      child: Image.asset("srouce/loading.gif",width: 30,height: 30));
                                },
                              )),
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

  Widget _statusWidget(String content, double count, String unit,
      Color borderColor, Color color) {
    return Container(
      width: ScreenUtil().setWidth(100),
      height: ScreenUtil().setWidth(80),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(width: 3, color: Colors.grey[300])),
      child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(content,
                      style: TextStyle(
                          fontSize: 13, color: const Color(0xff666666))),
                  Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 2,
                          color: borderColor,
                        )),
                  )
                ],
              ),
              Row(
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: <Widget>[
                  Text(count.toStringAsFixed(0),
                      style: TextStyle(fontSize: 22)),
                  SizedBox(width: 3),
                  Text(unit,
                      style: TextStyle(
                          fontSize: 10, color: const Color(0xff666666)))
                ],
              )
            ],
          )),
    );
  }

  List<TableRow> batchesTale(List<ItemBatch> list, double totalrest) {
    TableRow firstRow = TableRow(
        decoration: BoxDecoration(color: const Color(0xffD9D2B6)),
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 13, 0, 5),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '时间',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 13, 0, 5),
            child: Center(
              child: Text(
                '放入',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 13, 0, 5),
            child: Center(
              child: Text(
                '剩余',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          )
        ]);

    TableRow lastRow = TableRow(
        decoration: BoxDecoration(color: const Color(0xffFBF5F0)),
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 13, 0, 13),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '总计',
                  style: TextStyle(fontSize: 13),
                ),
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 13, 0, 13),
            child: Center(
              child: Text(
                ' ',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 13, 0, 13),
            child: Center(
              child: Text(
                totalrest.toStringAsFixed(0),
                style: TextStyle(fontSize: 13),
              ),
            ),
          )
        ]);

    return List.generate(list.length, (idx) {
      ItemBatch batch = list[idx];
      return TableRow(
          decoration: BoxDecoration(color: const Color(0xffFBF5F0)),
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 0, 4),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    batch.addDate,
                    style: TextStyle(fontSize: 13),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Text(
                  batch.quantity.toStringAsFixed(0),
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Text(
                  batch.rest.toStringAsFixed(0),
                  style: TextStyle(fontSize: 13),
                ),
              ),
            )
          ]);
    }, growable: true)
      ..insert(0, firstRow)..add(lastRow);
  }
}
