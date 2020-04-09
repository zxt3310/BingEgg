import 'package:shanyan/shanyan.dart';
import 'dart:io';

class QuickCheckManager {
  OneKeyLoginManager oneKeyLoginManager;
  Future preCheck;
  factory QuickCheckManager() => _getInstance();
  static QuickCheckManager get instance => _getInstance();
  static QuickCheckManager _instance;
  QuickCheckManager._internal() {
    oneKeyLoginManager = new OneKeyLoginManager();
  }
  static QuickCheckManager _getInstance() {
    if (_instance == null) {
      _instance = QuickCheckManager._internal();
    }
    return _instance;
  }

  Future<bool> initQuickCheck() async {
    //初始化校验
    Map res = await oneKeyLoginManager.init(
      appId: "QLMrcjQI",
    );
    int code = res['code'];
    print(res['result']);
    if (!_isSucc(code)) {
      return false;
    }
    //预取号
    Map prePhone = await oneKeyLoginManager.getPhoneInfo();
    code = prePhone['code'];
    return code == 1022;
  }

  bool _isSucc(int code) {
    return (Platform.isAndroid && code == 1022) ||
        (Platform.isIOS && code == 1000);
  }

  void reCheck(){
    preCheck = initQuickCheck();
  }
}
