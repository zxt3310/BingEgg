import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'package:sirilike_flutter/main.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/model/network.dart';

class BoxListWidget extends StatelessWidget {
  final BuildContext providerContext;
  BoxListWidget({this.providerContext});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的冰箱'),
        centerTitle: true,
      ),
      body: BoxListBody(providerContext),
    );
  }
}

class BoxListBody extends StatefulWidget {
  final BuildContext providerContext;
  BoxListBody(this.providerContext);
  @override
  _BoxListBodyState createState() => _BoxListBodyState();
}

class _BoxListBodyState extends State<BoxListBody> {
  int curDefault;
  @override
  Widget build(BuildContext context) {
    AppSharedState state = Provider.of(widget.providerContext);
    return ListView.separated(
        padding: EdgeInsets.all(20),
        itemBuilder: (context, idx) {
          return Container(
            height: 40, 
            child: Center(
                child: idx < state.curList.length
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(state.curList[idx].boxname),
                            state.curList[idx].isdefault == true
                                ? Text('默认冰箱',
                                    style: TextStyle(color: Colors.grey))
                                : FlatButton(
                                    onPressed: () {
                                      _changeDefault(state.curList[idx].id);
                                    },
                                    child: Text('设为默认冰箱',
                                        style: TextStyle(color: Colors.blue)))
                          ])
                    : FlatButton.icon(
                        onPressed: _popAddUI,
                        icon: Icon(Icons.add_circle_outline),
                        label: Text('新增冰箱'))),
          );
        },
        separatorBuilder: (context, idx) {
          return Container(
            height: 1,
            color: Colors.grey,
          );
        },
        itemCount: state.curList.length + 1);
  }

  _changeDefault(int boxid) async {
    await _setDefaultFridge(boxid);
    await _getFridgeList();
    setState(() {});
  }

  _getFridgeList() async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.get('/api/user-box/list');
    if (res.data['err'] != 0) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(res.data['errmsg'])));
      return;
    }
    List sources = res.data['data']['boxes'];
    List<Fridge> fridges = List<Fridge>.generate(sources.length, (idx) {
      return Fridge.fromJson(sources[idx]);
    });
    AppSharedState curProvider =
        Provider.of<AppSharedState>(widget.providerContext);
    curProvider.changeBoxList(fridges);
    print(curProvider.curList);
  }

  _setDefaultFridge(int boxid) async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.get('/api/user-box/default?boxid=$boxid');
    if (res.data['err'] != 0) {
      print('set default Error');
      return;
    }
  }

  //弹出添加
  String newFridgeName = '';
  _popAddUI() {
    showGeneralDialog(
        context: context,
        barrierLabel: '',
        barrierDismissible: true,
        barrierColor: const Color(0x77000000),
        transitionDuration: Duration(milliseconds: 200),
        pageBuilder: (ctx, anim1, anim2) {
          return Scaffold(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            resizeToAvoidBottomInset: false,
            body: Stack(children: <Widget>[
              Align(
                  alignment: Alignment(0, -0.65),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      width: 300,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          Align(
                            alignment: Alignment(0, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[300]),
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                              margin: EdgeInsets.all(20),
                              child: Row(
                                children: <Widget>[
                                  Text('冰箱名称',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          decoration: TextDecoration.none)),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                          prefix: SizedBox(width: 10),
                                          hintText: "请输入",
                                          border: InputBorder.none),
                                      style: new TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      onChanged: (str) {
                                        newFridgeName = str;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 300,
                            height: 50,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                                Expanded(
                                    child: MaterialButton(
                                  minWidth: 300,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(15))),
                                  child: Text('+ 添加'),
                                  onPressed: () {
                                    if (newFridgeName.isNotEmpty) {
                                      _addFridge(newFridgeName, context);
                                    }
                                  },
                                )),
                              ],
                            ),
                          ),
                        ],
                      ))),
              Align(
                alignment: Alignment(0, -0.8),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.circular(35)),
                  child: ClipOval(
                      child: Image.asset('srouce/fridge_icon.jpg',
                          fit: BoxFit.contain)),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.1),
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.grey[300]),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ]),
          );
        },
        transitionBuilder: (ctx, animation, _, child) {
          return ScaleTransition(
            alignment: Alignment.topLeft,
            scale: animation,
            child: child,
          );
        });
  }

  _addFridge(String name, BuildContext ctx) async {
    NetManager manager = NetManager.instance;
    Response res = await manager.dio.post('/api/user-box/add',
        data: {"name": name},
        options: Options(contentType: "application/x-www-form-urlencoded"));
    if (res.data['err'] != 0) {
      Navigator.of(ctx).pop();
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('${res.data['errmsg']}')));
      return;
    }
    Navigator.of(ctx).pop();
    await _getFridgeList();
    setState(() {});
  }
}
