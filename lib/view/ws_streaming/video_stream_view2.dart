import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class VideoStreamView2 extends StatefulWidget {
  const VideoStreamView2({Key? key}) : super(key: key);

  @override
  State<VideoStreamView2> createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStreamView2> {
  final IOWebSocketChannel _channel = IOWebSocketChannel.connect("ws://localhost:7777/test");
  bool _isConnected = false;
  Uint8List? _currentFrame;

  void connect(BuildContext context) {
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    _channel.sink.close();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Video"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => connect(context),
                    child: const Text("Connect"),
                  ),
                  ElevatedButton(
                    onPressed: disconnect,
                    child: const Text("Disconnect"),
                  ),
                ],
              ),
              const SizedBox(height: 50.0),
              _isConnected
                  ? StreamBuilder(
                stream: _channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const Center(
                      child: Text("Connection Closed!"),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  // MJPEG 스트림에서 프레임을 추출하여 렌더링
                  _currentFrame = extractJpegFrame(snapshot.data as Uint8List);

                  if (_currentFrame != null) {
                    return Image.memory(
                      _currentFrame!,
                      gaplessPlayback: true,
                      excludeFromSemantics: true,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              )
                  : const Text("Initiate Connection")
            ],
          ),
        ),
      ),
    );
  }

  /// MJPEG 스트림에서 개별 JPEG 이미지를 추출하는 함수
  Uint8List? extractJpegFrame(Uint8List data) {
    // JPEG 이미지의 시작과 끝을 나타내는 바이트 시퀀스
    final int soi = 0xFFD8; // Start of Image
    final int eoi = 0xFFD9; // End of Image

    int startIndex = -1;
    int endIndex = -1;

    // MJPEG 스트림에서 JPEG 이미지의 시작과 끝을 찾기
    for (int i = 0; i < data.length - 1; i++) {
      if (data[i] == 0xFF && data[i + 1] == 0xD8) {
        startIndex = i;
      }
      if (data[i] == 0xFF && data[i + 1] == 0xD9) {
        endIndex = i + 1;
        break;
      }
    }

    // JPEG 이미지가 유효한 경우 해당 부분을 추출
    if (startIndex != -1 && endIndex != -1) {
      return data.sublist(startIndex, endIndex + 1);
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
