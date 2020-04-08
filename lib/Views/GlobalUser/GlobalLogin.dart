import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shanyan/shanyan.dart';
import 'package:sirilike_flutter/Views/GlobalUser/ShanYanUIConfig.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'package:sirilike_flutter/main.dart';
import 'package:sirilike_flutter/model/customRoute.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'package:sirilike_flutter/model/user.dart';

class GlobalLoginPage extends StatelessWidget {
  const GlobalLoginPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginPageState>(
      create: (context) => LoginPageState(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('登录', style: TextStyle(color: Colors.white)),
          brightness: Brightness.dark,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        backgroundColor: Colors.lightGreen,
        body: _LoginUI(),
      ),
    );
  }
}

class _LoginUI extends StatefulWidget {
  _LoginUI({Key key, this.code}) : super(key: key);
  final int code;
  @override
  __LoginUIState createState() => __LoginUIState();
}

class __LoginUIState extends State<_LoginUI> {
  OneKeyLoginManager oneKeyLoginManager = new OneKeyLoginManager();
  Future builderFuture;
  @override
  void initState() {
    builderFuture = initQuickCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<LoginPageState, bool>(
        selector: (context, state) => state.isQuickCheck,
        builder: (context, isQuick, child) {
          return Container(
            padding: const EdgeInsets.all(30),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                isQuick ? _QuickCheckWidget() : _MessageCheckWidget(),
                FutureBuilder<QuickLogCheck>(
                    future: builderFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.data.isSupport
                            ? FlatButton(
                                onPressed: authorQuickCheck,
                                //  () {
                                //   // LoginPageState state =
                                //   //     Provider.of(context, listen: false);
                                //   // state.changeMode(!isQuick);

                                // },
                                child: Text(
                                  isQuick ? "短信验证登录" : "本机号码登录",
                                  style: TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.grey),
                                ))
                            : SizedBox();
                      } else {
                        return Text('检测一键登录......');
                      }
                    })
              ],
            ),
          );
        });
  }

  Future<QuickLogCheck> initQuickCheck() async {
    QuickLogCheck faild = QuickLogCheck(false);
    //初始化校验
    Map res = await oneKeyLoginManager.init(
      appId: "QLMrcjQI",
    );
    int code = res['code'];
    print(res['result']);
    if (!isSucc(code)) {
      return faild;
    }
    //预取号
    Map prePhone = await oneKeyLoginManager.getPhoneInfo();
    code = prePhone['code'];
    if (code != 1022) {
      print(res['result']);
      return QuickLogCheck(false);
    }
    return QuickLogCheck(true);
  }

  authorQuickCheck() async {
    oneKeyLoginManager
        .quickAuthLoginWithConfigure(ShanyanUIConfiguration.getIosUIConfig());
    oneKeyLoginManager.openLoginAuthListener().then((e) {
      print(e);
    });
    //自定义组件回调
    oneKeyLoginManager.setCustomInterface().then((e) {
      print(e);
    });

    Map res = await oneKeyLoginManager.oneKeyLoginListener();
    print(res);

    if (isSucc(res['code'])) {
      Map token = json.decode(res['result']);
      Dio req = NetManager.instance.dio;
      String url = '/api/login?token=${token['token']}';

      Response loginres = await req.get(url);
      int err = loginres.data['err'];
      if (err != 0) {
        oneKeyLoginManager.finishAuthControllerCompletion();
        BotToast.showText(text: '登录超时，请重试或更换登录方式');
        return;
      } else {
        String phone = loginres.data['data']['mobile'];
        String avatar = loginres.data['data']['avatar'];
        String token = loginres.headers.map['authorization'].first;
        await User.instance.save(phone, "", token, avatar);
      }
      Navigator.of(context)
          .pushAndRemoveUntil(CustomRoute.fade(MyHomePage()), (e) => false);
      oneKeyLoginManager.finishAuthControllerCompletion();
    }
  }

  bool isSucc(int code) {
    return (Platform.isAndroid && code == 1022) ||
        (Platform.isIOS && code == 1000);
  }
}

// 验证码登录
class _MessageCheckWidget extends StatefulWidget {
  _MessageCheckWidget({Key key}) : super(key: key);

  @override
  __MessageCheckWidgetState createState() => __MessageCheckWidgetState();
}

class __MessageCheckWidgetState extends State<_MessageCheckWidget> {
  FocusNode nodeCheck = FocusNode();
  GlobalKey<FormState> formkey = GlobalKey();
  String phone;
  String checkCode;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  labelText: "请输入手机号码",
                  labelStyle: TextStyle(fontSize: 14),
                  prefix: SizedBox(
                    width: 10,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen))),
              onChanged: (e) {
                phone = e;
                LoginPageState state = Provider.of<LoginPageState>(context,listen:false);
                state.setPhone(e);
              },
              onFieldSubmitted: (e) {
                nodeCheck.requestFocus();
              },
              validator: (e) {
                if (e.isEmpty) {
                  return "请输入电话号码";
                } else {
                  return null;
                }
              },
              keyboardType: TextInputType.phone,
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              focusNode: nodeCheck,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  labelText: "请输入验证码",
                  labelStyle: TextStyle(fontSize: 14),
                  //prefixIcon: Icon(Icons.),
                  prefix: SizedBox(
                    width: 10,
                  ),
                  suffix: _CheckCodeBtn(),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen))),
              onChanged: (e) {
                checkCode = e;
              },
              validator: (e) {
                if (e.isEmpty) {
                  return "请输入验证码";
                } else {
                  return null;
                }
              },
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: FlatButton(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '登  录',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                color: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  if (formkey.currentState.validate()) {
                    formkey.currentState.save();
                    _startLogin().then((e) {
                      if (e is String) {
                        Navigator.of(context).pushAndRemoveUntil(
                            CustomRoute.fade(MyHomePage()), (e) => false);
                      }

                      if (e is Map) {
                        BotToast.showText(text: e['errmsg']);
                      }
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _startLogin() async {
    Dio req = NetManager.instance.dio;
    String url = '/api/login?mobile=$phone&password=$checkCode';
    Response res = await req.get(url);
    int err = res.data['err'];
    if (err != 0) {
      return res.data;
    } else {
      String avatar = res.data['data']['avatar'];
      String token = res.headers.map['authorization'].first;
      await _saveUser(token, avatar);
      return token;
    }
  }

  Future _saveUser(String token, String avatar) async {
    await User.instance.save(phone, "", token, avatar);
  }
}

//一键登录
class _QuickCheckWidget extends StatefulWidget {
  _QuickCheckWidget({Key key}) : super(key: key);

  @override
  __QuickCheckWidgetState createState() => __QuickCheckWidgetState();
}

class __QuickCheckWidgetState extends State<_QuickCheckWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1)),
          )
        ],
      ),
    );
  }
}

class _CheckCodeBtn extends StatefulWidget {
  @override
  __CheckCodeBtnState createState() => __CheckCodeBtnState();
}

class __CheckCodeBtnState extends State<_CheckCodeBtn> {
  bool isLocking = false;
  final int count = 30;
  int curCount;
  Timer timer;

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: isLocking ? null : _sendMsg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 80,
        child: Center(
          child: Text(
            isLocking ? '${curCount}s' : '获取验证码',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }

  void _sendMsg() async {
    LoginPageState state = Provider.of<LoginPageState>(context, listen: false);
    print(state.phoneNo);
    Response res = await NetManager.instance.dio
        .post('/api/login-sms/send', data: {"mobile": state.phoneNo});
    if (res.data["err"] != 0) {
      BotToast.showText(text: '短信发送失败');
      return;
    }
    //锁死发送按钮
    isLocking = true;
    curCount = count + 1;
    var callback = (Timer tim) {
      if (curCount == 1) {
        tim.cancel();
        tim = null;
        isLocking = false;
      }
      setState(() {
        curCount--;
      });
    };

    timer = Timer.periodic(Duration(seconds: 1), callback);
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    super.dispose();
  }
}

class LoginPageState with ChangeNotifier {
  bool isQuickCheck = false;
  String phoneNo = "";
  String checkCode = "";

  void changeMode(bool mode) {
    isQuickCheck = mode;
    notifyListeners();
  }

  void setPhone(String phone) {
    phoneNo = phone;
  }

  void getCheckCode(String code) {
    checkCode = code;
    notifyListeners();
  }
}

class QuickLogCheck {
  final bool isSupport;
  final String phone;

  QuickLogCheck(this.isSupport, {this.phone});
}
