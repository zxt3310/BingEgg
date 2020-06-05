import 'package:flutter/cupertino.dart';
import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';

class NaviObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route previousRoute) {
    String pageName = previousRoute.settings.name;
    if (pageName == "/") {
      pageName = "主页";
    }
    if (pageName != null) {
      UmengAnalyticsPlugin.pageEnd(pageName);
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route previousRoute) {
    String pageName = route.settings.name;
    if (pageName == "/") {
      pageName = "主页";
    }
    if (pageName != null) {
      UmengAnalyticsPlugin.pageStart(pageName);
    }
    super.didPush(route, previousRoute);
  }

  // @override
  // void didRemove(Route route, Route previousRoute) {
  //   String pageName = route.settings.name;
  //   if(pageName != null){
  //     print('切换到$pageName');
  //   }
  //   super.didRemove(route, previousRoute);
  // }
}
