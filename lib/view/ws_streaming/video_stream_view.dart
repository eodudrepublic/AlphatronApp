import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../../provider/ws_streaming/video_stream_controller.dart';

class VideoStreamView extends GetView<VideoStreamController> {
  // VideoStreamController 인스턴스를 뷰에 주입
  final VideoStreamController controller = Get.put(VideoStreamController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Stream')), // 상단 앱바 타이틀 설정
      body: Center(
        child: Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center, // 세로로 중앙 정렬
              children: [
                // 연결 상태를 텍스트로 표시
                Text('Status: ${controller.model.status.value}'),

                // URL이 비어있지 않으면 URL 표시
                if (controller.model.url.isNotEmpty)
                  Text('URL: ${controller.model.url.value}'),
                SizedBox(height: 20), // 간격 추가

                // 상태가 'Connected'이면 비디오 스트림을 표시
                if (controller.model.status.value == 'Connected')
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 16 / 9, // 화면 비율 설정
                      child: controller.vlcController != null
                          ? VlcPlayer(
                              controller: controller.vlcController!,
                              aspectRatio: 16 / 9,
                              placeholder:
                                  Center(child: CircularProgressIndicator()),
                            )
                          : Container(
                              color: Colors.black, // 비디오 스트림 배경색 설정
                              child: Center(
                                child: Text('Initializing video player...',
                                    style: TextStyle(
                                        color: Colors.white)), // 초기화 중 메시지
                              ),
                            ),
                    ),
                  )
                else
                  // 연결 상태가 'Connected'가 아니면 비디오가 사용 불가하다는 메시지 표시
                  Text('Video not available'),
                SizedBox(height: 20), // 간격 추가

                // 연결/연결 해제 버튼
                ElevatedButton(
                  onPressed: () {
                    if (controller.model.status.value != 'Connected') {
                      // 연결되지 않았을 경우 연결 시도
                      controller.createAndConnectToStream(port: 8080);
                    } else {
                      // 이미 연결된 경우 연결 해제
                      controller.disconnect();
                    }
                  },
                  // 버튼 텍스트: 연결 상태에 따라 'Connect' 또는 'Disconnect'
                  child: Text(controller.model.status.value != 'Connected'
                      ? 'Connect'
                      : 'Disconnect'),
                ),
              ],
            )),
      ),
    );
  }
}
