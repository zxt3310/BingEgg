import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

/*
#Dart
# -*- encoding: utf-8 -*-
@File    :   userinfo.dart
@Time    :   2020/03/28 21:21:03
@Author  :   Zxt 
@Version :   1.0
@Contact :   78163796@qq.com
# Start typing your code from here
*/

class UserInfoWidget extends StatefulWidget {
  @override
  _UserInfoWidgetState createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  String path = 'srouce/草莓.png';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('个人信息'), centerTitle: true),
      body: Container(
          child: ListView.separated(
              padding: EdgeInsets.all(20),
              itemBuilder: (ctx, idx) {
                switch (idx) {
                  case 0:
                    return Container(
                      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('头像'),
                          ClipOval(
                              child: GestureDetector(
                            child: Image.asset(path, width: 60, height: 60),
                            onTap: getImage,
                          ))
                        ],
                      ),
                    );
                    break;
                  default:
                    return Container();
                }
              },
              separatorBuilder: (ctx, idx) {
                return Container(height: 1, color: Colors.grey);
              },
              itemCount: 2)),
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    var croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (croppedFile != null) {
      // Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (ctx) => ImagePage(croppedFile.path)));
      setState(() {
        path = croppedFile.path;
      });
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
