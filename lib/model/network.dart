
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'user.dart';

const baseurl = 'http://106.13.105.43:8888';

class NetManager {
  Dio dio;

  factory NetManager() => _getInstance();
  static NetManager get instance => _getInstance();
  static NetManager _instance;
  NetManager._internal() {
    dio = Dio();
    dio.options.baseUrl = baseurl;
    
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client){
    //   client.findProxy = (uri){
    //     return "PROXY 192.168.1.148:8888";
    //   };
    // };
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      options.headers.addAll({'Authorization': User.instance.token});
    }));
  }
  static NetManager _getInstance() {
    if (_instance == null) {
      _instance = NetManager._internal();
    }
    return _instance;
  }
}
