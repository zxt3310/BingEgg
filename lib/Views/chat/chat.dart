import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:bot_toast/src/toast.dart';

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
    state.dispose();
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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                child: chat.type == 0
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
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
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
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.supervised_user_circle)
                        ],
                      ),
              );
            },
          )),
          Column(children: [
            FlatButton(
              onLongPress: () {
                BotToast.showAttachedWidget(target: Offset(200, 500), attachedBuilder: (context){
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey,
                    child: Center(child: Text('test toast')),
                  );
                });
              },
              onPressed: () {
                addChat(state);
                Future.delayed(Duration(milliseconds: 100), () {
                  controller.jumpTo(controller.position.maxScrollExtent);
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(width: 1)),
              child: Icon(Icons.mic, size: 40, color: Colors.black),
            ),
            Text('按住说话')
          ])
        ]);
      }),
    );
  }

  addChat(ChatStateProvider state) {
    ChateData once = ChateData(
        type: i % 2,
        content: WordPair.random().asString,
        timestamp: DateTime.now().toIso8601String());
    state.add(once);
    i++;
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
