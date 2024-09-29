import 'package:alphatron_app/view/google_sign_in/sign_in_page.dart';
import 'package:alphatron_app/view/google_sign_in/user_info_page.dart';
import 'package:alphatron_app/view/rtc_streaming/webrtc_video_view.dart';
import 'package:alphatron_app/view/ws_streaming/mp4_stream_view.dart';
import 'package:alphatron_app/view/ws_streaming/video_stream_view.dart';
import 'package:alphatron_app/view/ws_streaming/video_stream_view2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AlphaTron App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/root',
      getPages: [
        GetPage(name: '/root', page: () => VideoStream()),
        GetPage(name: '/google_sign_in_view', page: () => SignInPage()),
        GetPage(name: '/user_info_page', page: () => UserInfoPage()),
        GetPage(
            name: '/websocket_video_streaming', page: () => WebRTCVideoView()),
        GetPage(name: '/webrtc_video_streaming', page: () => WebRTCVideoView()),
      ],
      home: VideoStream(),
    );
  }
}
