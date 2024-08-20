import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../provider/ws_streaming/video_stream_controller.dart';

class VideoStreamView extends GetView<VideoStreamController> {
  final VideoStreamController controller = Get.put(VideoStreamController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Stream')),
      body: Center(
        child: Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Status: ${controller.model.status.value}'),
                SizedBox(height: 20),
                if (controller.model.status.value == 'Connected')
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      // 여기에 실제 비디오 플레이어 위젯을 추가해야 합니다.
                      // H264 스트림을 직접 재생할 수 있는 플레이어가 필요합니다.
                      child: Center(
                          child: Text('Video Stream',
                              style: TextStyle(color: Colors.white))),
                    ),
                  )
                else
                  Text('Video not available'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (controller.model.status.value != 'Connected') {
                      controller.connectToStream(
                        host: 'your-backend-host.com',
                        port: 8080,
                        path: '/video-stream',
                        queryParams: {'userId': 'user123', 'channel': 'main'},
                        secure: true, // HTTPS 사용 시
                      );
                    } else {
                      controller.disconnect();
                    }
                  },
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
