import 'package:alphatron_app/view/google_sign_in/sign_in_page.dart';
import 'package:alphatron_app/view/google_sign_in/user_info_page.dart';
import 'package:alphatron_app/view/video_streaming/webrtc_video_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Google Sign In Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/root',
      getPages: [
        GetPage(name: '/root', page: () => WebRTCVideoView()),

        GetPage(name: '/google_sign_in_view', page: () => SignInPage()),
        GetPage(name: '/user_info_page', page: () => UserInfoPage()),

        GetPage(name: '/webrtc_video_streaming', page: () => WebRTCVideoView()),
      ],
      home: WebRTCVideoView(),
    );
  }
}