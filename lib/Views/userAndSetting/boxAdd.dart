import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'package:sirilike_flutter/Views/userAndSetting/addr.dart';
import 'package:sirilike_flutter/model/mainModel.dart';
import 'package:sirilike_flutter/model/network.dart';

class BoxAddWidget extends StatelessWidget {
  const BoxAddWidget({Key key, this.fridge}) : super(key: key);
  final Fridge fridge;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BoxState>(
        create: (context) => BoxState(curTypeIdx: fridge.boxtype),
        child: Scaffold(
            backgroundColor: Colors.lightGreen,
            appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.white),
                brightness: Brightness.dark,
                title: Text('添加冰箱', style: TextStyle(color: Colors.white)),
                elevation: 0,
                leading: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    })),
            body: _AddBody(fridge)));
  }
}

class _AddBody extends StatefulWidget {
  final Fridge fridge;
  _AddBody(this.fridge);
  @override
  __AddBodyState createState() => __AddBodyState();
}

class __AddBodyState extends State<_AddBody> {
  TextEditingController nameCtl = TextEditingController();
  TextEditingController addrCtl = TextEditingController();
  //FocusNode addrFocurs = FocusNode();
  @override
  void initState() {
    nameCtl.text = widget.fridge.boxname;
    addrCtl.text = widget.fridge.addr;
    super.initState();
  }

  @override
  void dispose() {
    nameCtl.dispose();
    addrCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(31))),
      child: Column(
        children: <Widget>[
          Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Text('冰箱名称'),
                TextField(
                  controller: nameCtl,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              width: 2,
                              color: Colors.lightGreen,
                              style: BorderStyle.solid)),
                      contentPadding: EdgeInsets.only(left: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              width: 2,
                              color: Colors.lightGreen,
                              style: BorderStyle.solid))),
                )
              ])),
          SizedBox(height: 20),
          FridgeSortWidget(),
          SizedBox(height: 20),
          Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Text('地点'),
                TextField(
                  controller: addrCtl,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              width: 2,
                              color: Colors.lightGreen,
                              style: BorderStyle.solid)),
                      contentPadding: EdgeInsets.only(left: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              width: 2,
                              color: Colors.lightGreen,
                              style: BorderStyle.solid))),
                  readOnly: true,
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (ctx) => BoxAddrWidget()))
                        .then((e) {
                      if (e is String) {
                        addrCtl.text = e;
                      }
                    });
                  },
                )
              ])),
          Expanded(
              child: Align(
            alignment: Alignment(0, 0.6),
            child: FlatButton(
                color: Colors.lightGreen,
                padding: EdgeInsets.fromLTRB(90, 15, 90, 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                onPressed: () {
                  String name = nameCtl.text;
                  String addr = addrCtl.text;
                  if (name.isEmpty) {
                    BotToast.showText(
                        text: '填写冰箱名称', align: const Alignment(0, 0));
                    return;
                  }

                  if (widget.fridge.id == null) {
                    _addNewFridge(context, name, addr);
                  } else {
                    _editFridge(context, name, addr);
                  }
                },
                child: Text(widget.fridge.id == null?'添  加':'修  改', style: TextStyle(color: Colors.white))),
          ))
        ],
      ),
    );
  }

  _addNewFridge(BuildContext ctx, String name, String addr) async {
    int boxtype = Provider.of<BoxState>(ctx, listen: false).curTypeIdx;
    Response res = await NetManager.instance.dio.post("/api/user-box/add",
        data: {"name": name, "gpsaddr": addr, "type": boxtype});
    if (res.data["err"] != 0) {
      BotToast.showText(text: '添加失败，请重试');
      return;
    } else {
      BotToast.showText(text: "添加成功");
      Navigator.of(context).pop(true);
    }
  }

  _editFridge(BuildContext ctx, String name, String addr) async {
    int boxtype = Provider.of<BoxState>(ctx, listen: false).curTypeIdx;
    Response res = await NetManager.instance.dio.post("/api/user-box/edit",
        data: {
          "id": widget.fridge.id,
          "name": name,
          "gpsaddr": addr,
          "type": boxtype
        });
    if (res.data["err"] != 0) {
      BotToast.showText(text: '修改失败，请重试');
      return;
    } else {
      BotToast.showText(text: "修改成功");
      Navigator.of(context).pop(true);
    }
  }
}

class FridgeSortWidget extends StatefulWidget {
  @override
  _FridgeSortWidgetState createState() => _FridgeSortWidgetState();
}

class _FridgeSortWidgetState extends State<FridgeSortWidget> {
  @override
  Widget build(BuildContext context) {
    return Selector<BoxState, int>(
        selector: (context, state) => state.curTypeIdx,
        builder: (context, curIdx, child) {
          return Container(
            child: Column(
              children: <Widget>[
                Row(children: [
                  Text('冰箱类型'),
                  SizedBox(width: 20),
                  Text(Fridgetype.values[curIdx].cn)
                ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: getBtnList(curIdx)),
              ],
            ),
          );
        });
  }

  List<Widget> getBtnList(int curIdx) {
    return List.generate(6, (idx) {
      return SingleSelectWidget(
        curIndex: curIdx,
        index: idx,
        child: Image.asset(
          'srouce/icotype/ico_type_${idx + 1}_${idx == curIdx ? 'p' : 'n'}.png',
          width: 40,
          height: 40,
          fit: BoxFit.fitHeight,
        ),
        onTap: () {
          Provider.of<BoxState>(context, listen: false).changeTypeId(idx);
        },
      );
    });
  }
}

class SingleSelectWidget extends StatefulWidget {
  final int curIndex;
  final int index;
  final Function onTap;
  final Widget child;

  SingleSelectWidget({this.curIndex, this.index, this.onTap, this.child});
  @override
  _SingleSelectWidgetState createState() => _SingleSelectWidgetState();
}

class _SingleSelectWidgetState extends State<SingleSelectWidget> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
              width: widget.curIndex == widget.index ? 4 : 1,
              color: widget.curIndex == widget.index
                  ? const Color(0xffe2e2e2)
                  : const Color(0xffe2e2e2))),
      onPressed: widget.onTap,
      child: widget.child,
    );
  }
}

class BoxState with ChangeNotifier {
  int curTypeIdx = 0;
  BoxState({this.curTypeIdx});

  changeTypeId(int idx) {
    curTypeIdx = idx;
    notifyListeners();
  }
}
