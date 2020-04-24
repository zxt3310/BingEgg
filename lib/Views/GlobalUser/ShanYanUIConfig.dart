import 'dart:io';

import 'dart:ui';
import 'package:shanyan/shanyan.dart';

class ShanyanIOSUIConfiguration {
  static Map getIosUIConfig() {
    if (Platform.isIOS) {
      //iOS 全屏模式
      double screenWidthPortrait =
          window.physicalSize.width / window.devicePixelRatio; //竖屏宽

      var screenScale = screenWidthPortrait / 375.0; //相对iphone6屏幕
      if (screenScale > 1) {
        screenScale = 1; //大屏的无需放大
      }

      //竖屏
      double clLayoutLogoTop_Portrait = screenScale * 60;
      double clLayoutLogoWidth_Portrait = 60 * screenScale;
      double clLayoutLogoHeight_Portrait = 60 * screenScale;
      double clLayoutLogoCenterX_Portrait = 0;

      double clLayoutPhoneCenterY_Portrait = -40 * screenScale;
      double clLayoutPhoneLeft_Portrait = 50 * screenScale;
      double clLayoutPhoneRight_Portrait = -50 * screenScale;
      double clLayoutPhoneHeight_Portrait = 80 * screenScale;

      double clLayoutLoginBtnCenterY_Portrait = clLayoutPhoneCenterY_Portrait +
          clLayoutPhoneHeight_Portrait * 0.5 * screenScale +
          20 * screenScale +
          15 * screenScale;
      double clLayoutLoginBtnHeight_Portrait = 45 * screenScale;
      double clLayoutLoginBtnLeft_Portrait = 70 * screenScale;
      double clLayoutLoginBtnRight_Portrait = -70 * screenScale;

      double clLayoutAppPrivacyLeft_Portrait = 40 * screenScale;
      double clLayoutAppPrivacyRight_Portrait = -40 * screenScale;
      double clLayoutAppPrivacyBottom_Portrait = 0 * screenScale;
      double clLayoutAppPrivacyHeight_Portrait = 45 * screenScale;

      double clLayoutSloganLeft_Portrait = 0;
      double clLayoutSloganRight_Portrait = 0;
      double clLayoutSloganHeight_Portrait = 15 * screenScale;
      double clLayoutSloganBottom_Portrait =
          clLayoutAppPrivacyBottom_Portrait - clLayoutAppPrivacyHeight_Portrait;

      return {
        "clBackgroundImg": "assets/Img/eb9a0dae18491990a43fe02832d3cafa.jpg",

        "shouldAutorotate": true,
        /**支持方向
         * 如支持横竖屏，需同时设置 clOrientationLayOutPortrait 和 clOrientationLayOutLandscape
         * 0:UIInterfaceOrientationMaskPortrait
         * 1:UIInterfaceOrientationMaskLandscapeLeft
         * 2:UIInterfaceOrientationMaskLandscapeRight
         * 3:UIInterfaceOrientationMaskPortraitUpsideDown
         * 4:UIInterfaceOrientationMaskLandscape
         * 5:UIInterfaceOrientationMaskAll
         * 6:UIInterfaceOrientationMaskAllButUpsideDown
         * */
        "supportedInterfaceOrientations": 5,

        /**偏好方向
         * -1:UIInterfaceOrientationUnknown
         * 0:UIInterfaceOrientationPortrait
         * 1:UIInterfaceOrientationPortraitUpsideDown
         * 2:UIInterfaceOrientationLandscapeLeft
         * 3:UIInterfaceOrientationLandscapeRight
         * */
        //偏好方向默认Portrait preferredInterfaceOrientationForPresentation: Number(5),

        "clNavigationBackgroundClear": true, //导航栏透明
        "clNavigationBackBtnImage": "assets/Img/close-white.png", //返回按钮图片
        "clNavBackBtnAlimentRight": false, //返回按钮居右,设置自定义导航栏返回按钮时，以自定义为准

        "clLogoImage": "srouce/logo.png", //logo图片

        "clLoginBtnText": "本机号一键登录", //一键登录按钮文字
        "clLoginBtnTextColor": [1, 1, 1, 1.0], //rgba
        "clLoginBtnBgColor": [0.44, 0.69, 0.28, 1.0], //rgba
        "clLoginBtnTextFont": 15 * screenScale,
        "clLoginBtnCornerRadius": 20,
        "clLoginBtnBorderWidth": 7.5,
        //"clLoginBtnBorderColor": [0.1, 0.8, 0.1, 1.0], //rgba

        "clPhoneNumberFont": 20.0 * screenScale,

        //隐私条款相关
        "clAppPrivacyPunctuationMarks": true, //运营商隐私条款书名号
        // "clAppPrivacyColor": [
        //   [0.6, 0.6, 0.6, 1.0],
        //   [0, 0, 1, 1.0]],
        // ], //2 item,commomTextColor and appPrivacyTextColor
        "clAppPrivacyTextFont": 11 * screenScale,
        // "clAppPrivacyTextAlignment": 0, //0: center 1: left 2: right
        // "clAppPrivacyThird": ["测试连接C", "https://www.sina.com"], // 2 item, name and url
        "clAppPrivacyAbbreviatedName": "云冰箱管家",
        "clAppPrivacyNormalDesTextFirst": "同意",
        "clAppPrivacyNormalDesTextSecond": "和",
        "clAppPrivacyFirst": [
          "《云冰箱管家用户协议》",
          "https://www.baidu.com"
        ], // 2 item, name and url

        "clAppPrivacyNormalDesTextThird": "、",

        "clAppPrivacySecond": [
          "《云冰箱管家隐私政策》",
          "http://106.13.105.43:8889/h5/privacy"
        ], // 2 item, name and url

        "clAppPrivacyNormalDesTextFourth": "并授权云冰箱管家使用认证服务",
        // "clAppPrivacyNormalDesTextLast": " ",

        //协议勾选框
        "clCheckBoxValue": true, //默认勾选
        "clCheckBoxVerticalAlignmentToAppPrivacyCenterY": true,
        "clCheckBoxSize": [
          30 * screenScale,
          30 * screenScale
        ], //2 item, width and height
        "clCheckBoxImageEdgeInsets": [
          2 * screenScale,
          10 * screenScale,
          13 * screenScale,
          5 * screenScale
        ], //4 item, top left bottom right
        "clCheckBoxUncheckedImage": "assets/Img/checkBoxNor.png",
        "clCheckBoxCheckedImage": "assets/Img/checkBoxSEL.png",

        "clLoadingSize": [50, 50], //2 item, width and height
        "clLoadingTintColor": [0.2, 0.8, 0.2, 1],
        "clLoadingBackgroundColor": [1, 1, 1, 1],
        "clLoadingCornerRadius": 5,

        //竖屏布局对象
        "clOrientationLayOutPortrait": {
          //控件
          "clLayoutLogoWidth": clLayoutLogoWidth_Portrait,
          "clLayoutLogoHeight": clLayoutLogoHeight_Portrait,
          "clLayoutLogoCenterX": clLayoutLogoCenterX_Portrait,
          "clLayoutLogoTop": clLayoutLogoTop_Portrait,

          "clLayoutPhoneCenterY": clLayoutPhoneCenterY_Portrait,
          "clLayoutPhoneHeight": clLayoutPhoneHeight_Portrait,
          "clLayoutPhoneLeft": clLayoutPhoneLeft_Portrait,
          "clLayoutPhoneRight": clLayoutPhoneRight_Portrait,

          "clLayoutLoginBtnCenterY": clLayoutLoginBtnCenterY_Portrait,
          "clLayoutLoginBtnHeight": clLayoutLoginBtnHeight_Portrait,
          "clLayoutLoginBtnLeft": clLayoutLoginBtnLeft_Portrait,
          "clLayoutLoginBtnRight": clLayoutLoginBtnRight_Portrait,

          "clLayoutAppPrivacyLeft": clLayoutAppPrivacyLeft_Portrait,
          "clLayoutAppPrivacyRight": clLayoutAppPrivacyRight_Portrait,
          "clLayoutAppPrivacyBottom": clLayoutAppPrivacyBottom_Portrait,
          "clLayoutAppPrivacyHeight": clLayoutAppPrivacyHeight_Portrait,

          "clLayoutSloganLeft": clLayoutSloganLeft_Portrait,
          "clLayoutSloganRight": clLayoutSloganRight_Portrait,
          "clLayoutSloganHeight": clLayoutSloganHeight_Portrait,
          "clLayoutSloganBottom": clLayoutSloganBottom_Portrait,
        },
        //自定义控件
        "widgets": {
          // "widget1": {
          //   "widgetId": "customView_one", //字符标记
          //   "type": "Button", // 类型：Button：按钮，ImageView:图片 TextView:文本
          //   "textContent": "自定义控件1（点击销毁授权页）", //文字
          //   "textFont": 13, //字体
          //   "textColor": [0, 1, 0, 1], //文字颜色[r,g,b,a]
          //   "backgroundColor": [0, 0, 1, 1], //控件背景色[r,g,b,a]
          //   "image": "assets/Img/logo_shanyan_text.png",

          //   "cornerRadius": 10, //圆角，设置圆角时请设置masksToBounds:true
          //   "masksToBounds": true, //圆角相关

          //   "isFinish": true, //点击销毁授权页,

          //   // clLayoutLeft:12,
          //   // clLayoutTop:60,
          //   // clLayoutRight:-12,
          //   "clLayoutBottom": -150,
          //   "clLayoutWidth": 180,
          //   "clLayoutHeight": 50,
          //   "clLayoutCenterX": 0,
          //   // clLayoutCenterY:0,
          // },
          // "widget2": {
          //   "widgetId": "customView_two", //字符标记
          //   "type": "TextView", // 类型：Button：按钮，ImageView:图片 TextView:文本
          //   "textContent":
          //       "123123", //文字
          //   "textFont": 10, //字体
          //   "textColor": [1, 0.5, 0.6, 1], //文字颜色[r,g,b,a]
          //   // "backgroundColor": [0, 0, 0, 1], //控件背景色[r,g,b,a]
          //   "numberOfLines": 0, //行数：默认单行， 0:无限，自动换行，其他：指定行数
          //   "textAlignment": 0, //0: center 1: left 2: right //仅TextView有效

          //   "clLayoutLeft": 80,
          //   // "clLayoutTop":300,
          //   "clLayoutRight": -80,
          //   "clLayoutWidth":150,
          //   "clLayoutHeight": 60,
          //   "clLayoutCenterX":0,
          //   "clLayoutCenterY":clLayoutPhoneCenterY_Portrait,
          // },
        }
      };
    }
    return null;
// //设置自定义控件点击回调,返回信息带有widgetId
//       oneKeyLoginManager.setCustomInterface().then((map) {
//         setState(() {
//           // _content = "自定义控件点击:" + map.toString();
//         });
//       }
  }
}

// "clLoginBtnText": "本机号一键登录", //一键登录按钮文字
//         "clLoginBtnTextColor": [1, 1, 1, 1.0], //rgba
//         "clLoginBtnBgColor": [0.2, 0.8, 0.2, 1.0], //rgba
//         "clLoginBtnTextFont": 15 * screenScale,
//         "clLoginBtnCornerRadius": 20,
//         "clLoginBtnBorderWidth": 0.5,
//         "clLoginBtnBorderColor": [0.1, 0.8, 0.1, 1.0], //rgba

class ShanyanAndroidUIConfiguration {
  static ShanYanUIConfig getAndroidUIConfig() {
    // ShanYanUIConfig shanYanUIConfig = ShanYanUIConfig();
    // shanYanUIConfig.setLogBtnText = "本机号一键登录";
    // shanYanUIConfig.setLogBtnHeight = 60;
    // shanYanUIConfig.setLogBtnTextSize = 15;
    // shanYanUIConfig.setLogBtnTextColor = "#ffffff";
    
    // shanYanUIConfig.setAppPrivacyOne = ["云冰箱管家用户协议", "https://baidu.com/"];
    // shanYanUIConfig.setAppPrivacyTwo = ["云冰箱管家隐私协议", "http://106.13.105.43:8889/h5/privacy"];
    // //shanYanUIConfig.setAppPrivacyThree = ["协议3", "https://baidu.com/"];
    // shanYanUIConfig.setPrivacyText = ["登录即同意", "、", "、", "和", "授权"];
    // shanYanUIConfig.setDialogTheme = ["120", "150", "0", "0", "false"];

    // return shanYanUIConfig;

    ShanYanUIConfig shanYanUIConfig = ShanYanUIConfig();
      shanYanUIConfig.setLogBtnText = "免密登录";
      //shanYanUIConfig.setAuthBGImgPath = "sy_login_test_bg";
      //shanYanUIConfig.setAppPrivacyColor = [0xffffffff,0xff0085d0];
      //shanYanUIConfig.setFullScreen = true;
      shanYanUIConfig.setAppPrivacyOne = [
        "闪验用户协议",
        "https://api.253.com/api_doc/yin-si-zheng-ce/wei-hu-wang-luo-an-quan-sheng-ming.html"
      ];
      shanYanUIConfig.setAppPrivacyTwo = [
        "闪验隐私政策",
        "https://api.253.com/api_doc/yin-si-zheng-ce/ge-ren-xin-xi-bao-hu-sheng-ming.html"
      ];
      shanYanUIConfig.setAppPrivacyThree = [
        "用户服务条款",
        "https://api.253.com/api_doc/yin-si-zheng-ce/ge-ren-xin-xi-bao-hu-sheng-ming.html"
      ];
      shanYanUIConfig.setAppPrivacyColor=["#808080","#00cc00"];
      shanYanUIConfig.setPrivacyText = ["登录即同意", "、", "、", "和", "并授权使用本机号码"];
      //shanYanUIConfig.setLoadingView = "custom_loading_dialog";
      List<ShanYanCustomWidgetLayout> shanYanCustomWidgetLayout = [];
      String layout_name = "relative_item_view";
      ShanYanCustomWidgetLayout relativeLayoutWidget = ShanYanCustomWidgetLayout(
          layout_name, ShanYanCustomWidgetLayoutType.RelativeLayout);
      relativeLayoutWidget.top = 300;
      relativeLayoutWidget.widgetLayoutId = ["weixin", "qq", "weibo"];
     

      shanYanCustomWidgetLayout.add(relativeLayoutWidget);

      List<ShanYanCustomWidget> shanyanCustomWidget = [];
      final String btn_widgetId = "other_custom_button"; // 标识控件 id
      ShanYanCustomWidget buttonWidget =
      ShanYanCustomWidget(btn_widgetId, ShanYanCustomWidgetType.TextView);
      buttonWidget.textContent = "其他方式登录 >";
      buttonWidget.bottom = 200;
      buttonWidget.width = 150;
      buttonWidget.height = 40;
      buttonWidget.backgroundColor ="#330000";
      buttonWidget.isFinish = false;
      //buttonWidget.btnNormalImageName = "";
      //buttonWidget.btnPressedImageName = "";
      buttonWidget.textAlignment = ShanYanCustomWidgetGravityType.center;
      // 添加点击事件监听
     
      shanyanCustomWidget.add(buttonWidget);
      // oneKeyLoginManager.setAuthThemeConfig(
      //     uiConfig: shanYanUIConfig,
      //     widgets: shanyanCustomWidget,
      //     widgetLayout: shanYanCustomWidgetLayout);
      return shanYanUIConfig;
  }
}
