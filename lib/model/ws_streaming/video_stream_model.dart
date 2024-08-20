import 'package:get/get.dart';

class VideoStreamModel {
  final RxString url = ''.obs;
  final RxString status = 'Disconnected'.obs;

  void updateUrl(String newUrl) => url.value = newUrl;

  void updateStatus(String newStatus) => status.value = newStatus;
}
