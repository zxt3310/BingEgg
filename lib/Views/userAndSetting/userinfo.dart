import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserInfoWidget extends StatefulWidget {
  @override
  _UserInfoWidgetState createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
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
                                child: Container(
                                    height: 40, width: 40, color: Colors.grey),
                                onTap: getImage,
                          ))
                        ],
                      ),
                    );
                    break;
                  default:
                }
              },
              separatorBuilder: (ctx, idx) {
                return Container(height: 1, color: Colors.grey);
              },
              itemCount: 2)),
    );
  }

  Future getImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    
  }
}
