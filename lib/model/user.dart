
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

String sharekey = "SHARE_KEY";

class User {
  String username;
  String password;
  String avatar;
  String token;
  bool isLogin;

  factory User() => _getInstance();
  static User get instance => _getInstance();
  static User _instance;
  User._internal() {
    isLogin = false;
  }
  static User _getInstance() {
    if (_instance == null) {
      _instance = User._internal();
    }
    return _instance;
  }

  loadFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _instance.username = prefs.get('id');
    _instance.password = prefs.get('pwd');
    _instance.token = prefs.get('token');
    _instance.avatar = prefs.get('avatar');
    if (_instance.token != null) {
      _instance.isLogin = true;
    }
  }

  clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    isLogin = false;
  }

  save(String account, String pswd, String author,String avatar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('id', account);
    prefs.setString('pwd', pswd);
    prefs.setString('token', author);
    prefs.setString('key', avatar);

    _instance.username = account;
    _instance.password = pswd;
    _instance.token = author;
    _instance.avatar = avatar;
    _instance.isLogin = true;
  }

  insertSharecode(String sharecode, int boxid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List codelist = prefs.getStringList(sharekey);
    if (codelist == null) {
      codelist = List();
    }

    Map struct = {boxid.toString(): sharecode};
    String jsonStr = json.encode(struct);
    codelist.add(jsonStr);
    prefs.setStringList(sharekey, codelist);
  }

  Future<String> getSharecodeFromBoxid(int boxid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List codelist = prefs.getStringList(sharekey);
    if (codelist == null) {
      return null;
    } else {
      String code;
      for (String str in codelist) {
        Map struct = json.decode(str);
        if (struct.containsKey(boxid.toString())) {
          code = struct[boxid.toString()];
          break;
        }
      }
      return code;
    }
  }
}


