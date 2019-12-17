import 'package:flutter/material.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';

class ImageListView extends StatefulWidget {
  @override
  _ImageListViewState createState() => _ImageListViewState();
}

class _ImageListViewState extends State<ImageListView> {
  List pics = [
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542212557760&di=2c0ccc64ab23eb9baa5f6582e0e4f52d&imgtype=0&src=http%3A%2F%2Fpic.feizl.com%2Fupload%2Fallimg%2F170725%2F43998m3qcnyxwxck.jpg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542212557760&di=37d5107e6f7277bc4bfd323845a2ef32&imgtype=0&src=http%3A%2F%2Fn1.itc.cn%2Fimg8%2Fwb%2Fsmccloud%2Ffetch%2F2015%2F06%2F05%2F79697840747611479.JPEG",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576574023246&di=0bc063d100cefbf4f92913c54c81bd71&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fc9fcc3cec3fdfc03db00af11de3f8794a4c2261a.jpg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542212636935&di=110a278fe4fb22f07d183a049f36cba3&imgtype=jpg&src=http%3A%2F%2Fimg2.imgtn.bdimg.com%2Fit%2Fu%3D3695896267%2C3833204074%26fm%3D214%26gp%3D0.jpg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542212557759&di=3730dccf46e4b4f35bcb882148b973ee&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fpic%2F3%2F71%2F4c5b0d26ad.jpg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542212557759&di=4f53fa8e1699def18e976deaee5558bf&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201707%2F07%2F20170707151851_r34Se.jpeg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542212557758&di=ea77e663ac012b8ce7eb921454528cb8&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201707%2F07%2F20170707151853_Xr2UP.jpeg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576512875419&di=6292250d1f8ab6b27a27b4f2e9726a74&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F4610b912c8fcc3cef70d70409845d688d53f20f7.jpg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576513124749&di=66800a87478e38e0304ed6fe51b0f6e3&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F11385343fbf2b211aff3aedfc08065380dd78e45.jpg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542212686376&di=6c670e61692a4b8a8c97fc8d751df6e9&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-8%2F2018082209071335857.jpg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576512875699&di=ba79d3d17624b55d34f95bc992a660f6&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F91529822720e0cf36ef506410046f21fbe09aa0e.jpg",
    "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576512875417&di=acb176e85d9f00dd261975511826fbc9&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F0eb30f2442a7d9337119f7dba74bd11372f001e0.jpg",
    "http://image.biaobaiju.com/uploads/20180801/22/1533134859-aRqMLUOtIf.jpg",
    "http://e.hiphotos.baidu.com/zhidao/pic/item/ae51f3deb48f8c5420d92dbf38292df5e0fe7f1c.jpg",
    "http://pic2.52pk.com/files/170428/7229806_112001_4181.jpg",
    "http://00.minipic.eastday.com/20170930/20170930182401_d41d8cd98f00b204e9800998ecf8427e_4.jpeg",
    "http://e.hiphotos.baidu.com/zhidao/pic/item/fcfaaf51f3deb48f20fd7651f41f3a292cf578ad.jpg",
    "http://abc.2008php.com/2014_Website_appreciate/2014-07-06/20140706015939.jpg",
    "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=509143600,2831498304&fm=26&gp=0.jpg",
    "http://c16.eoemarket.net/app0/657/657559/screen/3282631.png",
    "http://file.mumayi.com/forum/201401/16/202014h22z6jt6vpajypd0.jpg",
    "http://b-ssl.duitang.com/uploads/item/201702/09/20170209172200_MBmJz.jpeg"
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
        itemBuilder: (context, idx) {
          return GestureDetector(
            child: Image.network(pics[idx], fit: BoxFit.cover),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return ImgShowView(pics, idx);
              }));
            },
          );
        },
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: pics.length,
      ),
    );
  }
}

class ImgShowView extends StatefulWidget {
  final List pics;
  final int curIdx;
  ImgShowView(this.pics, this.curIdx);
  @override
  _ImgShowViewState createState() => _ImgShowViewState();
}

class _ImgShowViewState extends State<ImgShowView> {
  double scale = 1.0;
  double latestScaleUpdateDetails = 1.0;
  Offset offset = Offset.zero;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PageView.builder(
        controller: PageController(initialPage: widget.curIdx),
        itemCount: widget.pics.length,
        itemBuilder: (context, idx) {
          return GestureDetector(
            child: GestureZoomBox(
              maxScale: 3.0,
              doubleTapScale: 2.0,
              duration: Duration(microseconds: 200),
              onPressed: () => Navigator.of(context).pop(),
              child: Image.network(widget.pics[idx], fit: BoxFit.scaleDown),
            ),
            onTap: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }
}
