import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../model/ws_streaming/video_stream_model.dart';

class VideoStreamController extends GetxController {
  final VideoStreamModel model = VideoStreamModel();
  WebSocketChannel? _channel;
  List<int> _buffer = [];

  void connectToStream(String url) {
    model.updateUrl(url);
    model.updateStatus('Connecting');

    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel!.stream.listen(
      (dynamic data) {
        if (data is! List<int>) {
          print('Received non-binary data: $data');
          return;
        }
        _buffer.addAll(data);
        _processBuffer();
      },
      onDone: () {
        model.updateStatus('Disconnected');
      },
      onError: (error) {
        print('WebSocket Error: $error');
        model.updateStatus('Error');
      },
    );

    model.updateStatus('Connected');
  }

  void _processBuffer() {
    // 여기서 H264 프레임을 처리합니다.
    // 실제 구현은 H264 디코딩 라이브러리에 따라 다를 수 있습니다.
    // 이 예제에서는 단순화를 위해 생략합니다.

    // 프레임 처리 후 버퍼 비우기
    _buffer.clear();

    update(); // GetX의 상태 업데이트 메서드
  }

  void disconnect() {
    _channel?.sink.close();
    model.updateStatus('Disconnected');
  }

  @override
  void onClose() {
    _channel?.sink.close();
    super.onClose();
  }
}
