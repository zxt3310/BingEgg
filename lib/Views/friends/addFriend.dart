import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:sirilike_flutter/model/network.dart';

class FriendAddWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '添加好友',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        brightness: Brightness.dark,
      ),
      backgroundColor: Colors.lightGreen,
      body: _FriendAddBody(),
      bottomNavigationBar: Container(
        height: ScreenUtil.bottomBarHeight,
        color: Colors.white,
      ),
    );
  }
}

class _FriendAddBody extends StatefulWidget {
  @override
  __FriendAddBodyState createState() => __FriendAddBodyState();
}

class __FriendAddBodyState extends State<_FriendAddBody> {
  String shareCode;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(31))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('分享码'),
          SizedBox(
            height: 5,
          ),
          Container(
            height: 50,
            child: Stack(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      prefix: SizedBox(width: 15),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: Colors.lightGreen, width: 4)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: Colors.lightGreen, width: 4))),
                  onChanged: (e) {
                    shareCode = e;
                  },
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: MaterialButton(
                      onPressed: () {
                        _addFriend(shareCode);
                      },
                      height: 46,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.lightGreen,
                      child: Text(
                        '添  加',
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }

  _addFriend(String code) async {
    Response res = await NetManager.instance.dio
        .post('/api/friend/add', data: {"code": code});
    if (res.data['err'] != 0) {
      BotToast.showText(text: '好友未找到');
      return;
    }
    Navigator.of(context).pop(true);
  }
}
