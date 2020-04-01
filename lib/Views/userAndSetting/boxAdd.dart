import 'package:flutter/material.dart';

class BoxAddWidget extends StatelessWidget {
  const BoxAddWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          brightness: Brightness.dark,
          title: Text('添加冰箱', style: TextStyle(color: Colors.white)),
          elevation: 0),
      body: Container(
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
            Expanded(
                child: Align(
              alignment: Alignment(0, 0.6),
              child: FlatButton(
                  color: Colors.lightGreen,
                  padding: EdgeInsets.fromLTRB(90, 15, 90, 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  onPressed: () {},
                  child: Text('添  加', style: TextStyle(color: Colors.white))),
            ))
          ],
        ),
      ),
    );
  }
}

class FridgeSortWidget extends StatefulWidget {
  @override
  _FridgeSortWidgetState createState() => _FridgeSortWidgetState();
}

class _FridgeSortWidgetState extends State<FridgeSortWidget> {
  int curIdx = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(children: [Text('冰箱类型'), SizedBox(width: 20), Text('双门')]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: getBtnList()),
        ],
      ),
    );
  }

  List<Widget> getBtnList() {
    return List.generate(6, (idx) {
      return SingleSelectWidget(
        curIndex: curIdx,
        index: idx,
        child: Container(width: 48, height: 48),
        onTap: () {
          setState(() {
            curIdx = idx;
          });
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
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
              width: widget.curIndex == widget.index ? 4 : 1,
              color: widget.curIndex == widget.index
                  ? const Color(0xff71B047)
                  : const Color(0xffF2F2F2))),
      onPressed: widget.onTap,
      child: widget.child,
    );
  }
}
