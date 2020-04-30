//import 'dart:io';
import 'package:dio/dio.dart';
//import 'package:dio/adapter.dart';
import 'user.dart';

export 'package:dio/dio.dart';

const baseurl = 'http://106.13.105.43:8889';
const doMain = 'http://api.bingbox.net';

class NetManager {
  Dio dio;
  //判断域名是否连通 0未知/1连通/2不通
  int domainConnectState = 0;

  factory NetManager() => _getInstance();
  static NetManager get instance => _getInstance();
  static NetManager _instance;
  NetManager._internal() {
    _checkDomain();
    dio = Dio();
    dio.options.baseUrl = doMain;
    dio.options.contentType = "application/x-www-form-urlencoded";
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //   client.findProxy = (uri) {
    //     return "PROXY 192.168.1.2:8888";
    //   };
    // };
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async{
      while (domainConnectState == 0) {
        await Future.delayed(Duration(seconds: 1),null);
      }
      if(domainConnectState == 2){
        options.baseUrl = baseurl;
      }
      options.headers.addAll({'Authorization': User.instance.token});
    }, onResponse: (res) {
      int err = res.data['err'];
      if (err == 999) {
        return dio.reject(DioError(error: 'need relogin'));
      }
      return dio.resolve(res);
    }, onError: (err) {
      print(err);
      return dio.resolve(Response(data: {'err': 990, 'errmsg': '网络连接失败'}));
    }));
  }
  static NetManager _getInstance() {
    if (_instance == null) {
      _instance = NetManager._internal();
    }
    return _instance;
  }

  _checkDomain() {
    Dio checkDio = new Dio();
    checkDio.get('$doMain/api/basic-data/fetch').then((e) {
      domainConnectState = 1;
    })
      ..catchError((onError) {
        domainConnectState = 2;
      });
  }
}
