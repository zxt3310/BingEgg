import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'user.dart';

export 'package:dio/dio.dart';

const baseurl = 'http://106.13.105.43:8889';

class NetManager {
  Dio dio;

  factory NetManager() => _getInstance();
  static NetManager get instance => _getInstance();
  static NetManager _instance;
  NetManager._internal() {
    dio = Dio();
    dio.options.baseUrl = baseurl;

    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //   client.findProxy = (uri) {
    //     return "PROXY 192.168.1.126:8888";
    //   };
    // };
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      options.headers.addAll({'Authorization': User.instance.token});
      
    }, onResponse: (res) {
      int err = res.data['err'];
      if (err == 999) {
        return dio.reject(DioError(error: 'need relogin'));
      }
      return dio.resolve(res);
    },onError: (err){
      print(err);
      return dio.resolve(Response(data: {'err':990,'errmsg':'网络连接失败'}));
    }));
  }
  static NetManager _getInstance() {
    if (_instance == null) {
      _instance = NetManager._internal();
    }
    return _instance;
  }
}
