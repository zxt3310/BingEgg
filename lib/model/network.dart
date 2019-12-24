import 'package:dio/dio.dart';

const baseurl = 'http://106.13.105.43:8888';

class NetManager {
  Dio dio;

  factory NetManager() => _getInstance();
  static NetManager get instance => _getInstance();
  static NetManager _instance;
  NetManager._internal() {
    dio = Dio();
    dio.options.baseUrl = baseurl;
  }
  static NetManager _getInstance() {
    if (_instance == null) {
      _instance = NetManager._internal();
    }
    return _instance;
  }
}
