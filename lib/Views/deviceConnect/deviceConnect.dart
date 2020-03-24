import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:esptouch_flutter/esptouch_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:location_permissions/location_permissions.dart';

class WIFIConnectWidget extends StatefulWidget {
  @override
  _WIFIConnectWidgetState createState() => _WIFIConnectWidgetState();
}

class _WIFIConnectWidgetState extends State<WIFIConnectWidget> {
  String password = '';
  StreamSubscription subscription;
  StreamSubscription espStream;

  String ssid = '';
  String bssid = '';

  String connectResult = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备连接'),
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
              onPressed: () {
                if (ssid == null || bssid == null) {
                  BotToast.showText(text: '未能正确获取wifi');
                  return;
                }
                BotToast.showLoading();
                ESPTouchTask task = ESPTouchTask(
                    ssid: ssid,
                    bssid: bssid,
                    password: password,
                    packet: ESPTouchPacket.broadcast,
                    taskParameter: ESPTouchTaskParameter(
                        waitUdpReceiving: Duration(seconds: 10)));
                Stream<ESPTouchResult> stream = task.execute();
                espStream = stream.listen((e) {
                  print(e);
                  espStream.cancel();
                  BotToast.closeAllLoading();

                  if (e.bssid == null) {
                    connectResult = '连接失败';
                  } else {
                    connectResult = 'device:${e.bssid} ip: ${e.ip}';
                  }
                  setState(() {});
                });
              },
              child: Text('连接设备'),
              shape: RoundedRectangleBorder(side: BorderSide(width: 1))),
          SizedBox(height: 40),
          Text(connectResult)
        ]),
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    if(espStream != null){
       espStream.cancel();
    }
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
    PermissionStatus permission =
        await LocationPermissions().checkPermissionStatus();
    if (permission != PermissionStatus.granted) {
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
