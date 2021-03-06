import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shanyan/shanyan.dart';
import 'package:sirilike_flutter/Views/GlobalUser/ShanYanUIConfig.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'package:sirilike_flutter/main.dart';
import 'package:sirilike_flutter/model/customRoute.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'package:sirilike_flutter/model/quick_check.dart';
import 'package:sirilike_flutter/model/user.dart';
import 'package:fluwx_no_pay/fluwx_no_pay.dart';
import 'package:sirilike_flutter/webpage.dart';
import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';

class GlobalLoginPage extends StatelessWidget {
  const GlobalLoginPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginPageState>(
      create: (context) => LoginPageState(),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          // appBar: AppBar(
          //   title: Text('登录', style: TextStyle(color: Colors.white)),
          //   brightness: Brightness.dark,
          //   centerTitle: true,
          //   iconTheme: IconThemeData(color: Colors.white),
          //   elevation: 0,
          // ),
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xffF9F9F9),
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                    flex: 3,
                    child: Container(
                      color: Colors.lightGreen,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset('srouce/logo.png',
                                width: 70, height: 70, fit: BoxFit.fill),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('云冰箱管家',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                              SizedBox(
                                height: 28,
                              ),
                              Text('你的冰箱食材金牌管家',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ],
                          )
                        ],
                      ),
                    )),
                Flexible(flex: 6, child: _LoginUI()),
                Flexible(flex: 2, child: _ThirdPlatformLoginWidget()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 40,
                  child: Center(
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: '登录即同意',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                            children: [
                              TextSpan(
                                  text: '《云冰箱管家用户协议》',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          settings: RouteSettings(name: '用户协议'),
                                          builder: (ctx) => MainPage(
                                              url:
                                                  'http://106.13.105.43:8889/h5/agreement')));
                                    }),
                              TextSpan(
                                text: '和',
                              ),
                              TextSpan(
                                  text: '《隐私政策》',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          settings: RouteSettings(name: '隐私政策'),
                                          builder: (ctx) => MainPage(
                                              url:
                                                  'http://106.13.105.43:8889/h5/privacy')));
                                    }),
                            ])),
                  ),
                )
              ],
            ),
          ),
        ),
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Selector<LoginPageState, bool>(
          selector: (context, state) => state.isQuickCheck,
          builder: (context, isQuick, child) {
            return FutureBuilder<bool>(
                future: QuickCheckManager.instance.preCheck,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    //BotToast.closeAllLoading();
                    return Container(
                      padding: const EdgeInsets.all(30),
                      //color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          isQuick && snapshot.data
                              ? _QuickCheckWidget()
                              : _MessageCheckWidget(),
                          snapshot.data
                              ? FlatButton(
                                  splashColor: Colors.white,
                                  highlightColor: Colors.white,
                                  onPressed: () {
                                    LoginPageState state =
                                        Provider.of<LoginPageState>(context,
                                            listen: false);
                                    state.changeMode(!isQuick);
                                  },
                                  child: Text(
                                    isQuick ? "短信验证登录" : "本机号码登录",
                                    style: TextStyle(
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.grey),
                                  ))
                              : SizedBox()
                        ],
                      ),
                    );
                  } else {
                    //BotToast.showLoading();
                    return Container(
                      child: Center(
                        child: Image.asset('srouce/loading.gif'),
                      ),
                    );
                  }
                });
          }),
    );
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
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  hintText: "填写手机号",
                  labelStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.phone_android),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.all(20),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none),
              onChanged: (e) {
                phone = e;
                LoginPageState state =
                    Provider.of<LoginPageState>(context, listen: false);
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
            Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                TextFormField(
                  focusNode: nodeCheck,
                  decoration: InputDecoration(
                      hintText: "填写验证码",
                      labelStyle: TextStyle(fontSize: 14),
                      prefixIcon: Icon(Icons.lock_open),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.all(20),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none),
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
                Positioned(right: 30, top: 8, child: _CheckCodeBtn())
              ],
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
                        // Navigator.of(context).pushAndRemoveUntil(
                        //     CustomRoute.fade(MyHomePage()), (e) => false);

                        Navigator.of(context).pushReplacement(CustomRoute.fade(
                            MyHomePage(), RouteSettings(name: '主页')));
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
    String url = '/api/login?mobile=$phone&code=$checkCode';
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
  var androidCallBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: FlatButton(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                color: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                onPressed: authorQuickCheck,
                child: Text(
                  '本机号码一键登录',
                  style: TextStyle(color: Colors.white),
                )),
          )
        ],
      ),
    );
  }

  authorQuickCheck() async {
    OneKeyLoginManager oneKeyLoginManager =
        QuickCheckManager.instance.oneKeyLoginManager;
    Map authorRes;
    //ios
    if (Platform.isIOS) {
      //配置授权样式
      oneKeyLoginManager.quickAuthLoginWithConfigure(
          ShanyanIOSUIConfiguration.getIosUIConfig());
      //拉起授权页
      oneKeyLoginManager.openLoginAuthListener().then((e) {
        UmengAnalyticsPlugin.event("登录",label: "拉起授权");
        print(e);
      });
      //自定义组件回调
      oneKeyLoginManager.setCustomInterface().then((e) {
        print(e);
      });

      authorRes = await oneKeyLoginManager.oneKeyLoginListener();
      print(authorRes);

      _startLoginWithWxcode(authorRes);
    }
    //Android
    else {
      //配置授权样式
      oneKeyLoginManager.setAuthThemeConfig(
          uiConfig: ShanyanAndroidUIConfiguration.getAndroidUIConfig());

      androidCallBack = (AuthPageOnClickEvent e) {
        Map authorRes = e.toMap();
        _startLoginWithWxcode(authorRes);
      };

      //授权页登录按钮监听
      oneKeyLoginManager.setAuthPageOnClickListener(androidCallBack);
      //拉起授权页
      oneKeyLoginManager.openLoginAuth(isFinish: true).then((e) {
        //BotToast.showText(text: e.toString());
        UmengAnalyticsPlugin.event("登录",label: "拉起授权");
      });
    }
  }

  _startLoginWithWxcode(Map authorRes) async {
    UmengAnalyticsPlugin.event("登录",label: "一键登录");
    OneKeyLoginManager oneKeyLoginManager =
        QuickCheckManager.instance.oneKeyLoginManager;
    if (authorRes['code'] == 1000) {
      Map token;
      try {
        token = json.decode(authorRes['result']);
        // BotToast.showText(text: token['token']);
      } catch (e) {
        BotToast.showText(text: e.toString());
      }

      Dio req = NetManager.instance.dio;
      String url =
          '/api/login?platform=${Platform.isIOS ? 'ios' : 'androidÏ'}&token=${token['token']}';

      Response loginres = await req.get(url);

      int err = loginres.data['err'];
      if (err != 0) {
        oneKeyLoginManager.finishAuthControllerCompletion();
        BotToast.showText(text: '登录超时，请重试或更换登录方式');
        return;
      } else {
        try {
          String phone = loginres.data['data']['mobile'] ?? "";
          String avatar = loginres.data['data']['avatar'] ?? "";
          String token = loginres.headers.map['authorization'].first;
          await User.instance.save(phone, "", token, avatar);
        } catch (e) {
          BotToast.showText(text: e.toString(), duration: Duration(seconds: 6));
        }
      }

      if (androidCallBack != null) {
        bool isRemove =
            oneKeyLoginManager.removeAuthPageOnClickListener(androidCallBack);
        if (isRemove) {
          //BotToast.showText(text: '安卓监听事件已移除');
        }
      }

      Navigator.of(context).pushAndRemoveUntil(
          CustomRoute.fade(MyHomePage(), RouteSettings(name: '主页')),
          (e) => false);
      oneKeyLoginManager.finishAuthControllerCompletion();
    } else {
      BotToast.showText(text: '授权失败' + authorRes.toString());
    }
  }

  bool isSucc(int code) {
    return (Platform.isAndroid && code == 1022) ||
        (Platform.isIOS && code == 1000);
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
    return FlatButton(
      onPressed: isLocking ? null : _sendMsg,
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: isLocking ? Colors.grey[300] : Colors.lightGreen,
            borderRadius: BorderRadius.circular(20)),
        width: 100,
        child: Center(
          child: Text(
            isLocking ? '${curCount}s' : '获取验证码',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _sendMsg() async {
    print('发送短信');
    BotToast.showLoading(
        duration: Duration(milliseconds: 1500), allowClick: false);
    LoginPageState state = Provider.of<LoginPageState>(context, listen: false);
    print(state.phoneNo);
    Response res = await NetManager.instance.dio
        .post('/api/login-sms/send', data: {"mobile": state.phoneNo});
    if (res.data["err"] != 0) {
      BotToast.showText(text: '短信发送失败');
      UmengAnalyticsPlugin.event("登录",label: "短信发送失败");
      return;
    }
    BotToast.showText(text: '发送成功');
    UmengAnalyticsPlugin.event("登录",label: "短信发送成功");
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

class _ThirdPlatformLoginWidget extends StatefulWidget {
  @override
  __ThirdPlatformLoginWidgetState createState() =>
      __ThirdPlatformLoginWidgetState();
}

class __ThirdPlatformLoginWidgetState extends State<_ThirdPlatformLoginWidget> {
  StreamSubscription wxListen;

  @override
  void dispose() {
    if (wxListen != null) {
      wxListen.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _checkWxInstalled(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Text(
                    '或使用微信登录',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FlatButton(
                      padding: EdgeInsets.zero,
                      child: Image.asset('srouce/wechat.png',
                          width: 60, height: 60),
                      onPressed: () {
                        authorWithWeixin();
                      })
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Future<bool> _checkWxInstalled() async {
    return isWeChatInstalled;
  }

  authorWithWeixin() async {
    print('微信登录  微信登录');
    UmengAnalyticsPlugin.event("登录",label: "微信登录");
    bool isSucc = await sendWeChatAuth(
        scope: "snsapi_userinfo", state: "sirilikeFlutter_login_state");
    if (isSucc == null || !isSucc) {
      BotToast.showText(text: "无法打开微信");
      return;
    }

    wxListen = weChatResponseEventHandler.listen((e) {
      if (e is WeChatAuthResponse) {
        if (e.errCode == -4) {
          BotToast.showText(text: "取消授权");
          return;
        }
        if (e.errCode != 0) {
          BotToast.showText(text: e.errStr);
          return;
        }
        BotToast.showLoading();
        Future.delayed(Duration(seconds: 2)).then((res) {
          _startLogin(e.code);
        });
      }
    });
  }

  _startLogin(String code) async {
    UmengAnalyticsPlugin.event("登录",label: "验证码登录");
    Dio req = NetManager.instance.dio;
    String url = '/api/login?wxcode=$code';
    Response res = await req.get(url);
    int err = res.data['err'];
    if (err != 0) {
      BotToast.closeAllLoading();
      return res.data;
    } else {
      String avatar = res.data['data']['avatar'];
      String name = res.data['data']['nickname'];
      String token = res.headers.map['authorization'].first;
      await _saveUser(token, name, avatar);
      BotToast.closeAllLoading();
      // Navigator.of(context)
      //     .pushAndRemoveUntil(CustomRoute.fade(MyHomePage()), (e) => false);
      Navigator.of(context).pushReplacement(
          CustomRoute.fade(MyHomePage(), RouteSettings(name: '主页')));
    }
  }

  Future _saveUser(String token, String phone, String avatar) async {
    await User.instance.save(phone, "", token, avatar);
  }
}

class LoginPageState with ChangeNotifier {
  bool isQuickCheck = true;
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

  @override
  void dispose() {
    print('登录页状态对象释放');

    super.dispose();
  }
}

class QuickLogCheck {
  final bool isSupport;
  final String phone;

  QuickLogCheck(this.isSupport, {this.phone});
}
