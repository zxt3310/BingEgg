import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:sirilike_flutter/webpage.dart';
import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';
import '../../model/network.dart';
import 'package:intl/intl.dart';

const String app_id = '17933442';
const String api_key = 'WrG2dAP89ivVyr0LMGOKkliS';
const String secret_key = 'Zakea9N9mRYRTOxxit2DuqpuW1ta3lQl';

class ChatWidget extends StatefulWidget {
  final int curBoxId;

  ChatWidget(this.curBoxId);
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  ChatStateProvider state = ChatStateProvider();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => state,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              brightness: Brightness.dark,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                '存/取',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: ChatBodyWidget(widget.curBoxId)),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ChatBodyWidget extends StatefulWidget {
  final int curBoxId;

  ChatBodyWidget(this.curBoxId);
  @override
  _ChatBodyWidgetState createState() => _ChatBodyWidgetState();
}

class _ChatBodyWidgetState extends State<ChatBodyWidget> {
  ScrollController controller = ScrollController();
  TextEditingController textController = TextEditingController();
  FocusNode focusNode = FocusNode();
  int curBoxId = 3;
  //录音机
  FlutterAudioRecorder recorder;
  //存储路径
  String path;
  //百度令牌
  String token;
  //请求器
  Dio dio;
  //对话ID
  int chatId;
  //上次对话时间
  DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(-30000);
  //按下时间
  DateTime tapDownTime;
  DateFormat formater = DateFormat('HH:mm');
  @override
  void initState() {
    super.initState();
    this.authorToBD();
    this.loacalPath().then((e) {
      this._requestPermission().then((isPermission) {
        if (isPermission) {
          print(path);
        }
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  UniqueKey toastKey;
  ToastStateProvider provider;

  //向百度请求权限
  Future authorToBD() async {
    String authorUrl =
        'https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=' +
            api_key +
            '&client_secret=' +
            secret_key;
    dio = Dio();
    Response res = await dio.get(authorUrl);
    Map reData = res.data;
    token = reData['access_token'];
    print(token);
  }

  //获取本地存储路径
  Future loacalPath() async {
    try {
      var tempDir = await getTemporaryDirectory();
      path = tempDir.path + '/tempVoice.wav';
      File file = File(path);
      if (await file.exists()) {
        file.deleteSync(recursive: true);
      }
    } catch (err) {
      print(err);
      BotToast.showText(text: err.toString());
    }
  }

  //请求麦克风权限
  Future<bool> _requestPermission() async {
    bool hasPermission = await FlutterAudioRecorder.hasPermissions;
    return hasPermission;
  }

  //开始录音
  Future start() async {
    try {
      recorder = FlutterAudioRecorder(path,
          audioFormat: AudioFormat.WAV, sampleRate: 16000);
      await recorder.initialized;
      await recorder.start();
    } catch (e) {
      BotToast.showText(text: e.toString());
    }
  }

  //停止录音
  Future stop() async {
    provider.changeStr('识别中...');
    var resRecorder = await recorder.stop();
    File file = File(resRecorder.path);
    var obj = file.readAsBytesSync();
    print(obj.lengthInBytes);
    String voice = Base64Encoder().convert(obj);

    Response resp = await dio.post('http://vop.baidu.com/server_api', data: {
      'format': 'wav',
      'rate': '16000',
      'channel': '1',
      'token': token,
      'cuid': '11223123123',
      'len': obj.lengthInBytes,
      'speech': voice
    });
    //标记
    file.deleteSync(recursive: true);

    if (resp.data['err_no'] != 0) {
      provider.changeStr('未能识别');
      _hideToast();
      return;
    } else {
      // DateTime now = DateTime.now();
      // Duration during = now.difference(lastTime);
      // lastTime = now;

      // String str = resp.data['result'][0];
      // ChateData data = ChateData(
      //     chatId: chatId,
      //     type: 1,
      //     timestamp:
      //         during.inSeconds >= 30 ? formater.format(now.toLocal()) : "",
      //     content: str);
      // ChatStateProvider state =
      //     Provider.of<ChatStateProvider>(context, listen: false);
      // addChat(state, data);
      // _hideToast();
    }
    String words = resp.data['result'][0];
    _sendToServer(words);
    // String chatStr = chatId == null ? '' : '&chat_id=$chatId';
    // Response resNew = await NetManager.instance.dio.get(
    //     '/api/voice-result/analyze?words=${resp.data['result'][0]}&boxid=${widget.curBoxId}$chatStr');
    // if (resNew.data['err'] != 0 || resNew.data['data'] == null) {
    //   BotToast.showText(text: '请求失败,请重试');
    //   _hideToast();
    //   return;
    // }

    // chatId = resNew.data['data']['chat_id'];
    // String str = resNew.data['data']['words'];
    // ChateData data = ChateData(
    //     chatId: chatId,
    //     type: 0,
    //     timestamp: formater.format(DateTime.now().toLocal()),
    //     content: str);
    // ChatStateProvider state =
    //     Provider.of<ChatStateProvider>(context, listen: false);
    // addChat(state, data);

    // await dio
    //     .download('http://tsn.baidu.com/text2audio', path, queryParameters: {
    //   'tex': resNew.data['data']['words'],
    //   'tok': token,
    //   'cuid': '11223123123',
    //   'ctp': 1,
    //   'lan': 'zh',
    // });
    // File tts = File(path);
    // FlutterSound().startPlayer(path).then((e) {
    //   tts.deleteSync(recursive: true);
    // });
  }

  _sendToServer(String words) async {
    DateTime now = DateTime.now();
    Duration during = now.difference(lastTime);
    lastTime = now;

    ChateData cliData = ChateData(
        chatId: chatId,
        type: 1,
        timestamp: during.inSeconds >= 30 ? formater.format(now.toLocal()) : "",
        content: words);
    ChatStateProvider state =
        Provider.of<ChatStateProvider>(context, listen: false);
    addChat(state, cliData);
    _hideToast();
    String chatStr = chatId == null ? '' : '&chat_id=$chatId';
    Response resNew = await NetManager.instance.dio.get(
        '/api/voice-result/analyze?words=$words&boxid=${widget.curBoxId}$chatStr');
    if (resNew.data['err'] != 0 || resNew.data['data'] == null) {
      BotToast.showText(text: '请求失败,请重试');
      _hideToast();
      return;
    }

    chatId = resNew.data['data']['chat_id'];
    String str = resNew.data['data']['words'];
    ChateData serverData = ChateData(
        chatId: chatId,
        type: 0,
        timestamp: formater.format(DateTime.now().toLocal()),
        content: str);
    // ChatStateProvider state =
    //     Provider.of<ChatStateProvider>(context, listen: false);
    addChat(state, serverData);

    await dio
        .download('http://tsn.baidu.com/text2audio', path, queryParameters: {
      'tex': resNew.data['data']['words'],
      'tok': token,
      'cuid': '11223123123',
      'ctp': 1,
      'lan': 'zh',
    });
    File tts = File(path);
    FlutterSound().startPlayer(path).then((e) {
      tts.deleteSync(recursive: true);
    });
  }

  //移除toast
  _hideToast() {
    //Future.delayed(Duration(seconds: 1), () {
    BotToast.removeAll();
    // });
  }

  bool isVoice = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      color: const Color(0xFFF9F9F9),
      child: Consumer<ChatStateProvider>(builder: (context, state, child) {
        Color tipColor = const Color(0xffc8c7cc);
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(children: [
                  Offstage(
                      offstage: state.chatList.length > 2,
                      child: Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('你可以说:',
                                style:
                                    TextStyle(fontSize: 15, color: tipColor)),
                            SizedBox(height: 20),
                            Text('"放入1个鸡蛋"',
                                style:
                                    TextStyle(fontSize: 12, color: tipColor)),
                            Text('"拿出3个西红柿"',
                                style:
                                    TextStyle(fontSize: 12, color: tipColor)),
                            SizedBox(height: 40)
                          ],
                        ),
                      )),
                  ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: state.chatList.length,
                    controller: controller,
                    itemBuilder: (context, index) {
                      ChateData chat = state.chatList[index];
                      return Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              chat.type == 1
                                  ? Text(
                                      chat.timestamp,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: const Color(0xff9b9b9b)),
                                    )
                                  : SizedBox(),
                              SizedBox(height: 15),
                              chat.type == 0
                                  ? Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 8, 20, 8),
                                        child: Text(chat.content,
                                            style: TextStyle(fontSize: 14)),
                                        constraints: BoxConstraints(
                                            maxWidth: 250, minHeight: 35),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color:
                                                      const Color(0XFFF2F2F2),
                                                  blurRadius: 6)
                                            ],
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.zero,
                                                topRight: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20))),
                                      ))
                                  : Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 8, 20, 8),
                                        child: Text(chat.content,
                                            style: TextStyle(fontSize: 14)),
                                        constraints: BoxConstraints(
                                            maxWidth: 250, minHeight: 35),
                                        decoration: BoxDecoration(
                                            color: const Color(0xffd8f0bf),
                                            boxShadow: [
                                              BoxShadow(
                                                  color:
                                                      const Color(0xffd8f0bf),
                                                  blurRadius: 6)
                                            ],
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.zero,
                                                bottomLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20))),
                                      ))
                            ],
                          ));
                    },
                  )
                ]),
              ),
              Offstage(
                offstage: isVoice,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: Colors.lightGreen,
                  child: Row(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                            constraints: BoxConstraints.tight(Size(35, 35)),
                            icon:
                                Icon(Icons.mic, color: Colors.white, size: 20),
                            onPressed: () {
                              setState(() {
                                isVoice = true;
                              });
                            }),
                      ),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            focusNode: focusNode,
                            controller: textController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2)),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (str) {
                              _sendToServer(str);
                              textController.clear();
                              focusNode.requestFocus();
                              UmengAnalyticsPlugin.event("存取",label: "文字录入");
                            }),
                      ))
                    ],
                  ),
                ),
              ),
              Offstage(
                offstage: !isVoice,
                child: Container(
                    height: 135,
                    padding: EdgeInsets.all(10),
                    color: Colors.lightGreen,
                    child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          Align(
                              alignment: AlignmentDirectional.topStart,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    borderRadius: BorderRadius.circular(20)),
                                child: IconButton(
                                    constraints:
                                        BoxConstraints.tight(Size(35, 35)),
                                    icon: Icon(Icons.keyboard,
                                        color: Colors.white, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        isVoice = false;
                                      });
                                    }),
                              )),
                          Align(
                              alignment: AlignmentDirectional.bottomCenter,
                              child: Text('按住说话',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.white))),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FlatButton(
                                    padding: EdgeInsets.all(9),
                                    shape: CircleBorder(
                                        side: BorderSide(
                                            width: 1, color: Colors.white)),
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          settings:
                                              RouteSettings(name: '帮助页(语音)'),
                                          builder: (ctx) => MainPage(
                                              url:
                                                  'http://106.13.105.43:8889/h5/help#voice')));
                                    },
                                    child: Text('?',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20))),
                                GestureDetector(
                                    onTapDown: (e) {
                                      tapDownTime = DateTime.now();
                                      popupRecordingToast();
                                    },
                                    onTapUp: (e) async {
                                      Duration during = DateTime.now()
                                          .difference(tapDownTime);
                                      if (during.inSeconds < 1) {
                                        File file = File(path);
                                        if (await file.exists()) {
                                          file.deleteSync();
                                        }
                                        _hideToast();
                                        return;
                                      }
                                      Future.delayed(
                                          Duration(milliseconds: 300),
                                          () => stop());
                                      UmengAnalyticsPlugin.event("存取",label: "语音录入");
                                    },
                                    onTapCancel: () async {
                                      Duration during = DateTime.now()
                                          .difference(tapDownTime);
                                      if (during.inSeconds < 1) {
                                        File file = File(path);
                                        if (await file.exists()) {
                                          file.deleteSync();
                                        }
                                        _hideToast();
                                        return;
                                      }
                                      Future.delayed(
                                          Duration(milliseconds: 300),
                                          () => stop());
                                    },
                                    child: Image.asset("srouce/an_yuyin_p.png",
                                        width: 70, height: 70)),
                                FlatButton(
                                    padding: EdgeInsets.all(4),
                                    shape: CircleBorder(
                                        side: BorderSide(
                                            width: 1, color: Colors.white)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 20)),
                              ]),
                        ])),
              )
            ]);
      }),
    );
  }

  addChat(ChatStateProvider state, ChateData data) {
    state.add(data);
    Future.delayed(Duration(milliseconds: 100), () {
      controller.jumpTo(controller.position.maxScrollExtent);
    });
  }

  popupRecordingToast() {
    toastKey = UniqueKey();
    BotToast.showEnhancedWidget(
        key: toastKey,
        allowClick: false,
        toastBuilder: (context) {
          return ChangeNotifierProvider<ToastStateProvider>(
              create: (context) {
                provider = ToastStateProvider(stateStr: '正在录音...');
                return provider;
              },
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                          height: 200,
                          width: 200,
                          color: Colors.grey,
                          child: Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                Icon(Icons.mic_none,
                                    size: 100, color: Colors.white),
                                Consumer<ToastStateProvider>(
                                    builder: (context, state, child) {
                                  return Text(state.stateStr,
                                      style: TextStyle(color: Colors.white));
                                })
                              ])))
                    ],
                  )));
        });
    start();
  }

  @override
  void didChangeDependencies() {
    //加载欢迎语
    ChateData welcome = ChateData(
      content: '欢迎使用小冰记录食材，健康饮食开始起航。',
      type: 0,
    );
    ChatStateProvider state =
        Provider.of<ChatStateProvider>(context, listen: false);
    Future.delayed(Duration(seconds: 1), () {
      addChat(state, welcome);
    });

    super.didChangeDependencies();
  }
}

class ChatStateProvider with ChangeNotifier {
  List<ChateData> chatList = List();
  bool isFirstChat = false;

  add(ChateData data) {
    chatList.add(data);
    notifyListeners();
  }
}

class ChateData {
  ChateData({this.chatId, this.type, this.timestamp, this.content});

  final int chatId;
  final String content;
  final String timestamp;
  final int type;
}

class ToastStateProvider with ChangeNotifier {
  ToastStateProvider({this.stateStr});

  String stateStr;

  changeStr(String str) {
    stateStr = str;
    notifyListeners();
  }
}
