import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../model/ws_streaming/video_stream_model.dart';
import 'dart:io';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoStreamController extends GetxController {
  // 비디오 스트림 모델 인스턴스를 생성
  final VideoStreamModel model = VideoStreamModel();

  // 웹소켓 채널을 위한 변수
  WebSocketChannel? _channel;

  // 수신된 데이터를 저장할 버퍼 리스트
  List<int> _buffer = [];

  // VLC Player 컨트롤러 추가
  VlcPlayerController? _vlcController;

  // 임시 파일 경로
  String? _tempFilePath;

  // VLC Player 컨트롤러 getter
  VlcPlayerController? get vlcController => _vlcController;

  // 로컬 IP 주소를 가져오는 메서드
  Future<String?> getLocalIpAddress() async {
    try {
      // 네트워크 인터페이스 목록을 가져와 루프백 주소를 제외하고 IPv4 주소를 반환
      final interfaces = await NetworkInterface.list(
        includeLoopback: false, // 루프백 주소 제외
        type: InternetAddressType.IPv4, // IPv4 주소만 포함
      );
      // 사용 가능한 네트워크 인터페이스가 있다면 첫 번째 주소 반환
      if (interfaces.isNotEmpty) {
        return interfaces.first.addresses.first.address;
      }
    } catch (e) {
      print('Error getting local IP address: $e'); // 예외 발생 시 에러 메시지 출력
    }
    return null; // 예외 발생 시 null 반환
  }

  // 스트림을 생성하고 웹소켓 서버에 연결하는 메서드
  Future<void> createAndConnectToStream({int port = 8080}) async {
    // 로컬 IP 주소를 가져옴
    final ipAddress = await getLocalIpAddress();
    if (ipAddress == null) {
      model.updateStatus(
          'Error: Unable to get local IP address'); // IP 주소를 가져오지 못한 경우
      return;
    }

    // 웹소켓 URI 생성
    final uri = Uri(
      scheme: 'ws', // 웹소켓 프로토콜 사용
      host: ipAddress, // 로컬 IP 주소
      port: port, // 포트 번호
      path: '/test', // 경로
    );

    final url = uri.toString();
    model.updateUrl(url); // 모델에 URL 업데이트
    model.updateStatus('Connecting'); // 상태를 'Connecting'으로 업데이트

    try {
      // 웹소켓 서버에 연결
      _channel = WebSocketChannel.connect(uri);

      // 수신된 데이터를 처리하기 위한 리스너 설정
      _channel!.stream.listen(
        (dynamic data) {
          if (data is! List<int>) {
            print('Received non-binary data: $data'); // 바이너리 데이터가 아닌 경우 처리
            return;
          }
          // 수신된 데이터를 버퍼에 추가
          _buffer.addAll(data);
          // 버퍼 처리 메서드 호출
          _processBuffer();
        },
        onDone: () {
          model.updateStatus('Disconnected'); // 연결이 종료된 경우 상태 업데이트
        },
        onError: (error) {
          print('WebSocket Error: $error'); // 에러 발생 시 로그 출력
          model.updateStatus('Error'); // 상태를 'Error'로 업데이트
        },
      );

      model.updateStatus('Connected'); // 성공적으로 연결된 경우 상태를 'Connected'로 업데이트

      // VLC Player 초기화
      await _initializeVlcPlayer();
    } catch (e) {
      model.updateStatus(
          'Error: ${e.toString()}'); // 예외 발생 시 에러 메시지 출력 및 상태 업데이트
    }
  }

  // VLC Player 초기화 메서드
  Future<void> _initializeVlcPlayer() async {
    // 임시 파일 생성
    final tempDir = await Directory.systemTemp.createTemp('h264_stream');
    _tempFilePath = '${tempDir.path}/stream.h264';

    // VLC Player 컨트롤러 초기화
    _vlcController = VlcPlayerController.file(
      File(_tempFilePath!),
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  // 버퍼에서 데이터를 처리하는 메서드
  void _processBuffer() async {
    if (_buffer.isEmpty || _tempFilePath == null) return;

    try {
      // 버퍼의 데이터를 임시 파일에 쓰기
      final file = File(_tempFilePath!);
      await file.writeAsBytes(_buffer, mode: FileMode.append);

      // 버퍼 비우기
      _buffer.clear();

      // VLC Player에 새 미디어 로드
      if (_vlcController != null) {
        await _vlcController!.setMediaFromFile(file);
        if (_vlcController!.value.isPlaying == false) {
          await _vlcController!.play();
        }
      }
    } catch (e) {
      print('Error processing buffer: $e');
    }

    update(); // UI 업데이트 (GetX의 상태 관리 기능)
  }

  // 웹소켓 연결을 종료하는 메서드
  void disconnect() {
    _channel?.sink.close(); // 웹소켓 채널 닫기
    model.updateStatus('Disconnected'); // 상태를 'Disconnected'로 업데이트
    _vlcController?.dispose();
    _vlcController = null;
    // 임시 파일 삭제
    if (_tempFilePath != null) {
      File(_tempFilePath!).deleteSync();
      _tempFilePath = null;
    }
  }

  // 컨트롤러가 삭제될 때 호출되는 메서드 (리소스 정리)
  @override
  void onClose() {
    disconnect(); // 웹소켓 채널 닫기
    super.onClose();
  }
}
