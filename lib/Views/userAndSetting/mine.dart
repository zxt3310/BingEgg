import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sirilike_flutter/Views/GlobalUser/GlobalLogin.dart';
import 'package:sirilike_flutter/Views/myFridge/myFridge.dart';
import 'package:sirilike_flutter/main.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'package:sirilike_flutter/webpage.dart';
import '../../model/user.dart';
import 'boxlist.dart';
//import 'package:sirilike_flutter/Views/deviceConnect/deviceConnect.dart';
import 'package:sirilike_flutter/model/customRoute.dart';
export 'package:sirilike_flutter/main.dart' show AppSharedState;
import 'package:sirilike_flutter/Views/friends/friendBoxList.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

List optionList = ['我的冰箱', '个人信息', '选项卡'];

class UserCenterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserInfoState>(
        create: (ctx) => UserInfoState(),
        child: Scaffold(
            backgroundColor: Colors.lightGreen,
            body: SafeArea(
              bottom: false,
              child: Container(
                height: double.maxFinite,
                color: const Color(0xfff9f9f9),
                child: CustomScrollView(shrinkWrap: true, slivers: [
                  SliverToBoxAdapter(
                      child: Container(
                    child: Column(
                      children: <Widget>[
                        UserHeaderWidget(),
                      ],
                    ),
                  )),
                  SliverToBoxAdapter(
                      child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: <Widget>[
                              OptionsSelectWidget(
                                  title: '我的冰箱',
                                  icon: Icons.phone,
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (ctx) => BoxListWidget(
                                                providerContext: context)))
                                        .then((e) {
                                      if (e is int) {
                                        AppSharedState appState =
                                            Provider.of<AppSharedState>(context,
                                                listen: false);
                                        appState.curBoxIndex = e;
                                        appState
                                            .freshBox(appState.curList[e].id);
                                        appState.tabSwitch(1);
                                      }
                                    });
                                  }),
                              OptionsSelectWidget(
                                  title: '好友冰箱',
                                  icon: Icons.alarm,
                                  showSeprate: false,
                                  onTap: () {
                                    // Navigator.of(context).push(MaterialPageRoute(
                                    //     builder: (ctx) => WIFIConnectWidget()));
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) =>
                                                FriendBoxListWidget()));
                                  }),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: <Widget>[
                              OptionsSelectWidget(
                                  title: '新手引导',
                                  icon: Icons.my_location,
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (ctx) => MainPage(
                                            url:
                                                "http://106.13.105.43:8889/h5/help")));
                                  }),
                              OptionsSelectWidget(
                                  title: '联系我们',
                                  icon: Icons.alarm,
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (ctx) => MainPage(
                                            url:
                                                "http://106.13.105.43:8889/h5/about")));
                                  }),
                              OptionsSelectWidget(
                                  title: '隐私政策',
                                  icon: Icons.phone,
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (ctx) => MainPage(
                                            url:
                                                "http://106.13.105.43:8889/h5/privacy")));
                                  },
                                  showSeprate: false)
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          child: Center(
                            child: FlatButton(
                                onPressed: () {
                                  User.instance.clear();
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return CupertinoAlertDialog(
                                          title: Text('确定登出？'),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                                child: Text('确定'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                          CustomRoute.fade(
                                                              GlobalLoginPage()),
                                                          (e) => false);
                                                }),
                                            CupertinoDialogAction(
                                                child: Text('取消'),
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                })
                                          ],
                                        );
                                      });
                                },
                                child: Text('退出登录',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xfff5635e)))),
                          ),
                        )
                      ],
                    ),
                  )),
                ]),
              ),
            )));
  }
}

class UserHeaderWidget extends StatefulWidget {
  @override
  _UserHeaderWidgetState createState() => _UserHeaderWidgetState();
}

class _UserHeaderWidgetState extends State<UserHeaderWidget> {
  User user = User.instance;
  @override
  void initState() {
    super.initState();
    requestData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoState>(builder: (ctx, userInfo, child) {
      return Container(
        color: Colors.lightGreen,
        padding: EdgeInsets.all(15),
        child: Column(children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                child: Padding(
                    padding: EdgeInsets.all(15),
                    child: ClipOval(
                        child: FadeInImage.assetNetwork(
                            placeholder: 'srouce/loading.gif',
                            image: userInfo.avatar ??
                                'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1584699083702&di=7cf57bf8d0bb6f7662ebf1721b1cd9a7&imgtype=0&src=http%3A%2F%2Fwx1.sinaimg.cn%2Forj360%2Fdc1ebfbdly1gc0oora8g9j21hc0u0dkg.jpg',
                            height: 50,
                            width: 50,
                            fit: BoxFit.fitHeight))),
                onTap: () => _headImageEdit(),
              ),
              Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${userInfo.nickname ?? '小冰的箱'}',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text('手机登录',
                      style: TextStyle(
                          fontSize: 10, color: const Color(0xff437722)))
                ],
              )),
            ],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(31),
                color: const Color(0xff659E40)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image.asset(
                      'srouce/icotype/ico_type_${userInfo.myBox.type + 1}_n.png',
                      width: 16,
                      height: 16,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(userInfo.myBox.name,
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                Text(userInfo.myBox.health,
                    style: TextStyle(color: Colors.white))
              ],
            ),
          )
        ]),
      );
    });
  }

  _headImageEdit() {
    showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          return CupertinoActionSheet(
            title: Text('请选择来源'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(ctx).pop(0), child: Text('拍摄')),
              CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(ctx).pop(1), child: Text('相册')),
              CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('取消'),
                  isDestructiveAction: true),
            ],
          );
        }).then((e) {
      switch (e) {
        case 0:
          getImage(ImageSource.camera);
          break;
        case 1:
          getImage(ImageSource.gallery);
          break;
        default:
      }
    });
  }

  Future getImage(ImageSource source) async {
    //清除缓存
    // ImageCache imageCache = PaintingBinding.instance.imageCache;
    // imageCache.clear();

    var image = await ImagePicker.pickImage(
        source: source, maxHeight: 500, maxWidth: 500);
    if (image == null) {
      return;
    }
    var croppedFile = await ImageCropper.cropImage(
        //compressQuality: 10,
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        // aspectRatioPresets: [
        //   CropAspectRatioPreset.square,
        //   CropAspectRatioPreset.ratio3x2,
        //   CropAspectRatioPreset.original,
        //   CropAspectRatioPreset.ratio4x3,
        //   CropAspectRatioPreset.ratio16x9
        // ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          resetAspectRatioEnabled: true
          
        ));
    if (croppedFile != null) {
      FormData imgData = FormData.fromMap(
          {'avatar': await MultipartFile.fromFile(croppedFile.path)});
      print(croppedFile.lengthSync());
      Response res =
          await NetManager.instance.dio.post('/api/user/edit', data: imgData);
      if (res.data['err'] == 0) {
        BotToast.showText(text: '修改成功');
        requestData();
      } else {
        BotToast.showText(text: '上传失败');
      }
    }
  }

  requestData() async {
    Response res = await NetManager.instance.dio.get('/api/user/info');
    if (res.data['err'] != 0) {
      BotToast.showText(text: '用户信息获取失败');
      return;
    } else {
      String name = res.data['data']['nickname'];
      String path = res.data['data']['avatar'];
      UserInfoState infoState =
          Provider.of<UserInfoState>(context, listen: false);
      infoState.nickname = name;
      infoState.myBox = MyBox.fromJson(res.data['data']['my_box']);
      infoState.changeAvatar(path);
    }
  }
}

class ImagePage extends StatefulWidget {
  final String file;
  ImagePage(this.file);
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('相片')),
      body: Container(child: Center(child: Image.asset(widget.file))),
    );
  }
}

class OptionsSelectWidget extends StatelessWidget {
  @required
  final String title;
  @required
  final Function onTap;
  final IconData icon;
  final bool showSeprate;
  OptionsSelectWidget(
      {this.title, this.onTap, this.icon, this.showSeprate = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(children: [
            Row(
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffF9F9F9),
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.all(10),
                    child: Icon(icon, color: Colors.lightGreen, size: 20)),
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)))),
                Icon(Icons.keyboard_arrow_right,
                    size: 23, color: const Color(0xffc8c7cc))
              ],
            ),
            SizedBox(height: 10),
            showSeprate
                ? Divider(
                    height: 1, thickness: 1, color: const Color(0xffEFEFF4))
                : SizedBox()
          ]),
        ));
  }
}

class UserInfoState with ChangeNotifier {
  String nickname = User.instance.username;
  String avatar = User.instance.avatar;
  MyBox myBox = MyBox();

  changeNick(String name) {
    nickname = name;
    notifyListeners();
  }

  changeAvatar(String path) {
    avatar = path;
    notifyListeners();
  }
}

class MyBox {
  final String name;
  final int type;
  final String health;

  MyBox({this.name = "", this.type = 0, this.health = ""});

  MyBox.fromJson(Map json)
      : name = json['name'],
        type = json['type'] is String ? int.parse(json['type']) : json['type'],
        health = json['health'];
}
