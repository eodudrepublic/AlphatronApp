import 'dart:io';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class VideoStreamingScreen extends StatefulWidget {
  @override
  _VideoStreamingScreenState createState() => _VideoStreamingScreenState();
}

class _VideoStreamingScreenState extends State<VideoStreamingScreen> {
  WebSocketChannel? channel;
  VideoPlayerController? _videoController;
  List<int> _videoBuffer = [];
  List<List<int>> _videoQueue = []; // 비디오 대기열
  bool _isPlaying = false; // 재생 상태 플래그

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.0.16:7777/test'));
    channel?.stream.listen((message) {
      // 메시지가 Uint8List 타입인지 확인
      if (message is Uint8List) {
        print('Received data: ${message.length} bytes'); // 로그 추가

        // MP4 데이터를 받을 때마다 버퍼에 추가
        _videoBuffer.addAll(message);

        // 데이터가 일정 크기를 넘으면 대기열에 추가하고 스트리밍 시작
        if (_videoBuffer.length > 32 * 1024) { // 32KB 기준으로 스트리밍 시작
          final bytes = _videoBuffer.toList();
          _videoBuffer.clear();
          _videoQueue.add(bytes); // 대기열에 추가

          if (!_isPlaying) { // 현재 재생 중이 아니면 스트리밍 시작
            _startStreaming();
          }
        }
      } else {
        print('Received non-binary message');
      }
    }, onError: (error) {
      print('WebSocket error: $error'); // 에러 로그 추가
    }, onDone: () {
      print('WebSocket connection closed'); // 연결 종료 로그 추가
    });
  }

  void _startStreaming() async {
    if (_videoQueue.isEmpty || _isPlaying) {
      return; // 대기열이 비어있거나 재생 중인 경우 종료
    }

    _isPlaying = true;
    final bytes = _videoQueue.removeAt(0); // 대기열의 첫 번째 비디오 데이터를 가져옴

    final directory = await getTemporaryDirectory();
    final videoFile = File('${directory.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4');

    // 비디오 파일 저장
    await videoFile.writeAsBytes(bytes);
    print('Video file saved at: ${videoFile.path}'); // 파일 저장 로그 추가

    // 비디오 파일 크기 확인
    final fileSize = await videoFile.length();
    print('Saved video file size: $fileSize bytes');

    if (fileSize < 1024) {
      print('Video file size is too small. Data might be incomplete.');
      _isPlaying = false; // 재생 상태를 false로 변경
      _startStreaming(); // 다음 비디오 재생 시도
      return; // 파일 크기가 너무 작으면 재생하지 않음
    }

    // 비디오 플레이어 초기화
    if (_videoController != null) {
      await _videoController!.dispose();
    }

    _videoController = VideoPlayerController.file(videoFile);

    try {
      await _videoController!.initialize();
      if (_videoController!.value.isInitialized) {
        print('Video controller initialized successfully'); // 초기화 성공 로그 추가
        setState(() {});
        _videoController!.play();

        // 비디오 재생 완료 리스너 등록
        _videoController!.addListener(_videoPlayerListener);
      } else {
        print('Video controller not initialized properly'); // 초기화 실패 로그 추가
        _isPlaying = false; // 재생 상태를 false로 변경
        _startStreaming(); // 다음 비디오 재생 시도
      }
    } catch (e) {
      print('Error initializing video controller: $e'); // 초기화 오류 로그 추가
      _isPlaying = false; // 재생 상태를 false로 변경
      _startStreaming(); // 다음 비디오 재생 시도
    }
  }

  void _videoPlayerListener() {
    if (_videoController!.value.position >= _videoController!.value.duration) {
      _videoController!.removeListener(_videoPlayerListener);
      _isPlaying = false;
      _startStreaming(); // 대기열의 다음 비디오 재생
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Streaming')),
      body: Center(
        child: _videoController != null && _videoController!.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        )
            : CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    channel?.sink.close();
    _videoController?.removeListener(_videoPlayerListener); // 리스너 제거
    _videoController?.dispose();
    super.dispose();
  }
}
