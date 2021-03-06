import 'package:flutter/material.dart';

class BingEBottomBaviBar extends StatefulWidget {
  final List<BingEBarItemModel> items;
  final bool existCenterDock;
  final Widget centerDock;
  final int curSelectIndex;
  final double height;
  final double itemSize;
  final ImageProvider backgroundImg;
  @required
  final Function onTap;

  BingEBottomBaviBar(
      {this.items,
      this.existCenterDock,
      this.centerDock,
      this.curSelectIndex,
      this.height = 60,
      this.backgroundImg,
      this.itemSize = 30,
      this.onTap})
      : assert(items != null),
        assert(items.length <= 5),
        assert(!(existCenterDock && centerDock == null)),
        assert(!(existCenterDock && items.length % 2 != 0)),
        assert(curSelectIndex != null);

  @override
  _BingEBottomBaviBarState createState() => _BingEBottomBaviBarState();
}

class _BingEBottomBaviBarState extends State<BingEBottomBaviBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
          image:
              DecorationImage(image: widget.backgroundImg, fit: BoxFit.fill)),
      child: Stack(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: drawItems(),
        ),
        Align(
          alignment: AlignmentDirectional.topCenter,
          child: widget.centerDock,
        )
      ]),
    );
  }

  List<Widget> drawItems() {
    List<Widget> items = List.generate(widget.items.length, (idx) {
      BingEBarItemModel itemModel = widget.items[idx];
      return Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.onTap(idx);
              },
              child: BingEBarItem(
                size: widget.itemSize,
                title: itemModel.title,
                selectWid: itemModel.selectWid,
                unselectWid: itemModel.unselectWid,
                selectColor: itemModel.selectColor,
                unselectColor: itemModel.unselectColor,
                selfIndex: idx,
                callback: widget.onTap,
                currentIndex: widget.curSelectIndex,
              )));
    });
    if (widget.existCenterDock) {
      items.insert(
          widget.items.length ~/ 2,
          Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: SizedBox(width: widget.itemSize)));
    }
    return items;
  }
}

class BingEBarItemModel {
  final String title;
  final Widget selectWid;
  final Widget unselectWid;
  final Color selectColor;
  final Color unselectColor;

  BingEBarItemModel(
      {this.title,
      this.selectWid,
      this.unselectWid,
      this.selectColor,
      this.unselectColor});
}

class BingEBarItem extends StatefulWidget {
  final double size;
  final String title;
  final Widget selectWid;
  final Widget unselectWid;
  final Color selectColor;
  final Color unselectColor;
  final int selfIndex;
  final int currentIndex;
  final Function callback;

  BingEBarItem(
      {this.title,
      this.size,
      this.selectWid,
      this.unselectWid,
      this.selectColor,
      this.unselectColor,
      this.selfIndex,
      this.currentIndex,
      this.callback});

  @override
  _BingEBarItemState createState() => _BingEBarItemState();
}

class _BingEBarItemState extends State<BingEBarItem> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            //color: Colors.green,
            child: Column(children: [
              Container(
                  width: widget.size,
                  height: widget.size,
                  child: widget.selfIndex == widget.currentIndex
                      ? widget.selectWid
                      : widget.unselectWid),
              Text(widget.title,
                  style: TextStyle(
                      fontSize: 12,
                      color: widget.selfIndex == widget.currentIndex
                          ? widget.selectColor
                          : widget.unselectColor))
            ])));
  }
}
