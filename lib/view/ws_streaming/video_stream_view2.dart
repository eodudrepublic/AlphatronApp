import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../model/websocket/websocket.dart';

class VideoStream extends StatefulWidget {
  const VideoStream({Key? key}) : super(key: key);

  @override
  State<VideoStream> createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  final WebSocket _socket = WebSocket("ws://192.168.0.23:7777/test");
  bool _isConnected = false;
  Uint8List? _currentFrame; // 현재 프레임을 저장할 변수

  void connect(BuildContext context) async {
    _socket.connect();
    _socket.stream.listen((data) {
      // 이전 프레임 처리 후 일정 시간 대기
      Future.delayed(Duration(milliseconds: 33), () {
        setState(() {
          List<Uint8List> frames = _extractFrames(data as Uint8List);
          if (frames.isNotEmpty) {
            _currentFrame = frames.last;
          }
        });
      });
    });
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    _socket.disconnect();
    setState(() {
      _isConnected = false;
      _currentFrame = null;
    });
  }

  List<Uint8List> _extractFrames(Uint8List data) {
    List<Uint8List> frames = [];
    int offset = 0;

    while (offset < data.length) {
      if (offset + 4 > data.length) break;

      int frameSize = ByteData.sublistView(data, offset, offset + 4).getInt32(0, Endian.big);
      offset += 4;

      if (offset + frameSize > data.length) break;

      frames.add(data.sublist(offset, offset + frameSize));
      offset += frameSize;
    }

    return frames;
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
                    onPressed: () {
                      connect(context);
                    },
                    child: const Text("Connect"),
                  ),
                  ElevatedButton(
                    onPressed: disconnect,
                    child: const Text("Disconnect"),
                  ),
                ],
              ),
              const SizedBox(
                height: 50.0,
              ),
              _isConnected
                  ? (_currentFrame != null
                  ? Image.memory(
                _currentFrame!,
                gaplessPlayback: true,
                excludeFromSemantics: true,
              )
                  : const CircularProgressIndicator())
                  : const Text("Initiate Connection"),
            ],
          ),
        ),
      ),
    );
  }
}
