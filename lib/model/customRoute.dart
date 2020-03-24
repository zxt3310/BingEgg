import 'package:flutter/material.dart';

class CustomRoute extends PageRouteBuilder {
  final Widget widget;
  CustomRoute(this.widget)
      : super(
            opaque: false,
            barrierColor: Color(0x7F000000),
            maintainState: true,
            transitionDuration: Duration(milliseconds: 500),
            pageBuilder: (
              BuildContext context,
              Animation<double> animation1,
              Animation<double> animation2,
            ) {
              return widget;
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              return SlideTransition(
                position:
                    Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0, 0.1))
                        .animate(CurvedAnimation(
                            parent: animation1,
                            curve: Curves.fastLinearToSlowEaseIn)),
                child: child,
              );
            });

  CustomRoute.fade(this.widget)
      : super(
            maintainState: true,
            transitionDuration: Duration(milliseconds: 300),
            pageBuilder: (
              BuildContext context,
              Animation<double> animation1,
              Animation<double> animation2,
            ) {
              return widget;
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              return FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: animation1, curve: Curves.decelerate)),
                  child: child);
            });
}
