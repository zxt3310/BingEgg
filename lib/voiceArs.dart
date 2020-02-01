import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'model/network.dart';
//import 'package:sirilike_flutter/Views/myFridge/myFridge.dart' show CurrentIndexProvider;

const String app_id = '17933442';
const String api_key = 'WrG2dAP89ivVyr0LMGOKkliS';
const String secret_key = 'Zakea9N9mRYRTOxxit2DuqpuW1ta3lQl';

class AsrTTSModel extends StatefulWidget {
  AsrTTSModel({Key key, this.provider}) : super(key: key);
  final CurrentFridgeListProvider provider;
  @override
  _AsrTTSModelState createState() => _AsrTTSModelState();
}

class _AsrTTSModelState extends State<AsrTTSModel> {
  bool isRecording = false;
  String result = '';
  String log = '';
  FlutterAudioRecorder recorder;
  String path;
  String token;
  Dio dio;
  //秒
  int during = 0;
  Timer timer;
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
    log = '开始录音...';
    var sec = Duration(seconds: 1);
    timer = Timer.periodic(sec, (tim) async {
      if (during == 60) {
        tim.cancel();
        recorder.stop();
      } else {
        var cur = await recorder.current(channel: 1);
        during = cur.duration.inSeconds;
        this.setState(() {});
      }
    });
    isRecording = true;
    recorder = FlutterAudioRecorder(path,
        audioFormat: AudioFormat.WAV, sampleRate: 16000);
    await recorder.initialized;
    await recorder.start();
  }

  Future stop() async {
    timer.cancel();
    log = log + '\n结束录音';

    this.setState(() {});

    isRecording = false;
    var resRecorder = await recorder.stop();
    File file = File(resRecorder.path);
    var obj = file.readAsBytesSync();
    print(obj.lengthInBytes);
    String voice = Base64Encoder().convert(obj);
    log = log + '\n正在识别...';
    this.setState(() {});
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
      log = log + '\n无法识别\n$resp';
      result = '无法识别';
      this.setState((){});
      return;
    } else {
      log = log + '\n识别成功\n$resp';
      result = '我：${resp.data['result'][0]}';
      this.setState(() {});
    }
    
    String chatStr = chatId==null?'':'&chat_id=$chatId';

    Response resNew = await NetManager.instance.dio
        .get('/api/voice-result/analyze?words=${resp.data['result'][0]}&boxid=${widget.provider.curBoxid}$chatStr');
    if(resNew.data['err'] != 0){
      log = log + '\n${resNew.data['errmsg']}';
      return;
    }
    result = result + '\n你：${resNew.data['data']['words']}';

    log = log + '\n上传...\n${resNew.data}';
    this.setState(() {});

    if (resNew.data['data'] == null) {
      return;
    }

    chatId = resNew.data['data']['chat_id'];

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

  @override
  void dispose() {
    // File file = File(path);
    // file.deleteSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return Scaffold(
        appBar: AppBar(
            title: Text('添加'),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop();
                })),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                  height: 80,
                  child: Center(
                      child: FlatButton.icon(
                          shape: Border.all(width: 1),
                          onPressed: () {
                            isRecording ? stop() : start();
                            this.setState(() {});
                          },
                          label: Text('${isRecording ? '停止识别' : '开始识别'}'),
                          icon: Icon(
                              isRecording ? Icons.pause : Icons.arrow_right,
                              size: 30,
                              color: Colors.black)))),
              Container(
                child: Text('时长$during'),
              ),
              Container(
                  height: 100,
                  width: 300,
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: Text(result),
                  )),
              SizedBox(height: 30),
              Container(
                  height: 350,
                  width: 300,
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: Text(log),
                  ))
            ],
          ),
        ));
  }
}
