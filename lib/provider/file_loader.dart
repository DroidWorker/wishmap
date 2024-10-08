import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';


class FileDownloader {
  @pragma('vm:entry-point')
  static void downloadCallback(
      String id,
      int status,
      int progress
      ) async {
    final SendPort? send = IsolateNameServer.lookupPortByName(
      'downloader_send_port',
    );
    print("seeeeeeerv$send");
    send?.send("$id,$status,$progress");
  }
  static Future<String?> downloadFile(String url, String savedDir) async {

    // Создание задачи загрузки файла
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: savedDir,
      showNotification: true, // Показывать уведомление во время загрузки
      openFileFromNotification: false, // Открывать файл после загрузки
    );
    print("taskCreaaaaaaates");
    return taskId;
  }
}