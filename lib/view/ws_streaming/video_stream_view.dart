import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../provider/ws_streaming/video_stream_controller.dart';

class VideoStreamView extends StatelessWidget {
  const VideoStreamView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoStreamController());

    return Scaffold(
      appBar: AppBar(title: const Text('Data Stream')),
      body: Center(
        child: Obx(() {
          if (!controller.isConnected.value) {
            return ElevatedButton(
              onPressed: controller.connectToServer,
              child: const Text('Connect to Server'),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<int>>(
                    stream: controller.dataStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // 받은 데이터를 문자열로 변환
                        String data = String.fromCharCodes(snapshot.data!);
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(data),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: controller.disconnectFromServer,
                  child: const Text('Disconnect'),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
