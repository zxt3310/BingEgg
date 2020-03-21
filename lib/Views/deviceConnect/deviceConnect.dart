import 'dart:async';

import 'package:flutter/material.dart';
import 'package:esptouch_flutter/esptouch_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:location_permissions/location_permissions.dart';

class WIFIConnectWidget extends StatefulWidget {
  @override
  _WIFIConnectWidgetState createState() => _WIFIConnectWidgetState();
}

class _WIFIConnectWidgetState extends State<WIFIConnectWidget> {
  String password;
  StreamSubscription subscription;

  String ssid = '';
  String bssid = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(children: <Widget>[
          Text('当前wifi'),
          Text('SSID: $ssid}'),
          Text('bSSID: $bssid}'),
          SizedBox(height: 30),
          Container(
              width: 200,
              child: TextField(
                  decoration: InputDecoration(labelText: 'wifi密码'),
                  onChanged: (e) {
                    password = e;
                  })),
          SizedBox(
            height: 20,
          ),
          FlatButton(
              onPressed: () {},
              child: Text('连接设备'),
              shape: RoundedRectangleBorder(side: BorderSide(width: 1))),
          SizedBox(height: 40),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      getCurWifi();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurWifi();
  }


  getCurWifi() async {
    PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
    if (permission != PermissionStatus.granted){
      await LocationPermissions().requestPermissions();
    }
    
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.none) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
      ssid = await Connectivity().getWifiName();
      bssid = await Connectivity().getWifiBSSID();
      setState(() {});
    }
  }
}
