
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String username;
  String password;
  String token;
  bool isLogin;

  factory User() => _getInstance();
  static User get instance => _getInstance();
  static User _instance;
  User._internal() {
    isLogin = false;
  }
  static User _getInstance(){
    if(_instance == null){
      _instance = User._internal();
    }
    return _instance;
  }

  loadFromLocal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _instance.username = prefs.get('id');
    _instance.password = prefs.get('pwd');
    _instance.token = prefs.get('token');
    if(_instance.token != null){
      _instance.isLogin = true;
    }
  }

  clear() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    isLogin = false;
  }

  save(String account,String pswd,String author) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('id', account);
    prefs.setString('pwd', pswd);
    prefs.setString('token', author);

    _instance.username = account;
    _instance.password = pswd;
    _instance.token = author;
    _instance.isLogin = true;
  }
}