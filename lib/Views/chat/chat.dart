import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';
import 'package:bot_toast/bot_toast.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../../model/network.dart';

const String app_id = '17933442';
const String api_key = 'WrG2dAP89ivVyr0LMGOKkliS';
const String secret_key = 'Zakea9N9mRYRTOxxit2DuqpuW1ta3lQl';

class ChatWidget extends StatefulWidget {
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  ChatStateProvider state = ChatStateProvider();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => state,
      child: Scaffold(appBar: AppBar(), body: ChatBodyWidget()),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ChatBodyWidget extends StatefulWidget {
  @override
  _ChatBodyWidgetState createState() => _ChatBodyWidgetState();
}

class _ChatBodyWidgetState extends State<ChatBodyWidget> {
  ScrollController controller = ScrollController();
  int i = 0;
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
        file.deleteSync();
      }
    } catch (err) {
      print(err);
    }
  }

  //请求麦克风权限
  Future<bool> _requestPermission() async {
    bool hasPermission = await FlutterAudioRecorder.hasPermissions;
    return hasPermission;
  }

  //开始录音
  Future start() async {
    recorder = FlutterAudioRecorder(path,
        audioFormat: AudioFormat.WAV, sampleRate: 16000);
    await recorder.initialized;
    await recorder.start();
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
    file.deleteSync();

    if (resp.data['err_no'] != 0) {
      provider.changeStr('未能识别');
      _hideToast();
      return;
    } else {
      String str = resp.data['result'][0];
      ChateData data = ChateData(
          chatId: chatId,
          type: 0,
          timestamp: DateTime.now().toLocal().toString(),
          content: str);
      ChatStateProvider state = Provider.of<ChatStateProvider>(context);
      addChat(state, data);
      _hideToast();
    }

    String chatStr = chatId == null ? '' : '&chat_id=$chatId';
    Response resNew = await NetManager.instance.dio.get(
        '/api/voice-result/analyze?words=${resp.data['result'][0]}&boxid=$curBoxId$chatStr');
    if (resNew.data['err'] != 0 || resNew.data['data'] == null) {
      BotToast.showText(text: '请求失败,请重试');
      return;
    }

    chatId = resNew.data['data']['chat_id'];

    String str = resNew.data['data']['words'];
    ChateData data = ChateData(
        chatId: chatId,
        type: 1,
        timestamp: DateTime.now().toLocal().toString(),
        content: str);
    ChatStateProvider state = Provider.of<ChatStateProvider>(context);
    addChat(state, data);

    await dio
        .download('http://tsn.baidu.com/text2audio', path, queryParameters: {
      'tex': resNew.data['data']['words'],
      'tok': token,
      'cuid': '11223123123',
      'ctp': 1,
      'lan': 'zh',
    });
    File tts = File(path);
    await FlutterSound().startPlayer(path).then((e) {
      tts.deleteSync();
    });
  }

  //移除toast
  _hideToast() {
    Future.delayed(Duration(seconds: 1), () {
      BotToast.remove(toastKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Consumer<ChatStateProvider>(builder: (context, state, child) {
        return Column(children: [
          Expanded(
              child: ListView.builder(
            itemCount: state.chatList.length,
            controller: controller,
            itemBuilder: (context, index) {
              ChateData chat = state.chatList[index];
              return Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    children: [
                      Text(chat.timestamp),
                      SizedBox(height: 10),
                      chat.type == 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.computer),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(chat.content),
                                  constraints: BoxConstraints(maxWidth: 200),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey)),
                                )
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(chat.content),
                                  constraints: BoxConstraints(maxWidth: 200),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey)),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.supervised_user_circle)
                              ],
                            )
                    ],
                  ));
            },
          )),
          Column(children: [
            GestureDetector(
              onLongPressStart: (e) {
                toastKey = UniqueKey();
                BotToast.showEnhancedWidget(
                    key: toastKey,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                            Icon(Icons.mic_none,
                                                size: 100, color: Colors.white),
                                            Consumer<ToastStateProvider>(
                                                builder:
                                                    (context, state, child) {
                                              return Text(state.stateStr,
                                                  style: TextStyle(
                                                      color: Colors.white));
                                            })
                                          ])))
                                ],
                              )));
                    });
                start();
              },
              onLongPressEnd: (e) {
                stop();
              },
              // onTap: () {
              //   addChat(state);
              //   Future.delayed(Duration(milliseconds: 100), () {
              //     controller.jumpTo(controller.position.maxScrollExtent);
              //   });
              // },
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Icon(Icons.mic, size: 40, color: Colors.black),
                decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            Text('按住说话')
          ])
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
}

class ChatStateProvider with ChangeNotifier {
  List<ChateData> chatList = List();

  add(ChateData data) {
    chatList.add(data);
    notifyListeners();
  }
}

class ChateData {
  final int chatId;
  final int type;
  final String timestamp;
  final String content;

  ChateData({this.chatId, this.type, this.timestamp, this.content});
}

class ToastStateProvider with ChangeNotifier {
  String stateStr;
  ToastStateProvider({this.stateStr});

  changeStr(String str) {
    stateStr = str;
    notifyListeners();
  }
}
