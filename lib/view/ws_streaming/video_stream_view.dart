import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../../provider/ws_streaming/video_stream_controller.dart';

// VideoStreamView 클래스는 비디오 스트리밍을 위한 UI를 정의합니다.
// 서버와의 연결, 비디오 플레이어, 연결 해제 버튼 등을 포함한 Flutter 위젯을 구성합니다.
class VideoStreamView extends StatelessWidget {
  const VideoStreamView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get.put()을 사용하여 VideoStreamController를 인스턴스화하고, 이 컨트롤러는 UI와의 상태 관리를 담당합니다.
    final controller = Get.put(VideoStreamController());

    return Scaffold(
      appBar: AppBar(title: const Text('Video Stream')),
      // 상단 앱 바에 'Video Stream'이라는 제목을 표시합니다.
      body: Center(
        // Obx는 GetX의 리액티브 위젯으로, Rx 변수의 변화에 따라 UI를 자동으로 업데이트합니다.
        child: Obx(() {
          // 서버와 연결되지 않은 경우, 'Connect to Server' 버튼을 표시합니다.
          if (!controller.isConnected.value) {
            return ElevatedButton(
              onPressed: controller.connectToServer, // 버튼을 클릭하면 서버에 연결을 시도합니다.
              child: const Text('Connect to Server'),
            );
          } else {
            // 서버와 연결된 경우, 비디오 플레이어와 'Disconnect' 버튼을 표시합니다.
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  // VlcPlayer 위젯을 사용하여 비디오를 재생합니다.
                  child: VlcPlayer(
                    controller: controller.vlcController,
                    // VLC 플레이어 컨트롤러를 설정합니다.
                    aspectRatio: 16 / 9,
                    // 비디오의 가로 세로 비율을 16:9로 설정합니다.
                    placeholder: const Center(
                        child:
                            CircularProgressIndicator()), // 비디오 로딩 중에 로딩 인디케이터를 표시합니다.
                  ),
                ),
                ElevatedButton(
                  onPressed: controller.disconnectFromServer,
                  // 버튼을 클릭하면 서버와의 연결을 해제합니다.
                  child: const Text(
                      'Disconnect'), // 'Disconnect'라는 텍스트를 버튼에 표시합니다.
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
