import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

List<String> namelist = ['全部', '水果', '蔬菜', '肉类', '饮品'];

class MyFridgeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _FridgeWidget(),
    );
  }
}

class _FridgeWidget extends StatefulWidget {
  @override
  __FridgeWidgetState createState() => __FridgeWidgetState();
}

class __FridgeWidgetState extends State<_FridgeWidget>
    with SingleTickerProviderStateMixin {
  int curIdx = 0;
  TabController tabcontroller;
  PageController pageController;
  @override
  void initState() {
    pageController = PageController();
    tabcontroller = TabController(vsync: this, length: namelist.length);
    super.initState();
  }

  _onChangeTab(e) {
    //curIdx = e;
    pageController.jumpToPage(e);
  }

  _onChangePage(e) {
    //curIdx = e;
    tabcontroller.index = e;
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
        value: curIdx,
        child: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TabBar(
                  indicator: const BoxDecoration(),
                  controller: tabcontroller,
                  tabs: _getBtns(namelist),
                  onTap: _onChangeTab,
                ),
                Expanded(
                    child: PageView.builder(
                  itemCount: namelist.length,
                  controller: pageController,
                  onPageChanged: _onChangePage,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: index % 2 == 0 ? Colors.blue : Colors.yellow,
                    );
                  },
                )),
              ]),
        ));
  }

  List<Widget> _getBtns(List<String> names) {
    return List<Widget>.generate(
      names.length,
      (idx) {
        return Consumer<int>(builder: (context, int dx, child) {
          return Container(
              child: Column(
            children: <Widget>[
              Icon(Icons.camera,
                  color: idx == dx ? Colors.greenAccent : Colors.grey),
              Text('${names[idx]}',style: TextStyle(color: Colors.black)),
            ],
          ));
        });
      },
    );
  }
}
