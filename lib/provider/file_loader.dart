import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';


class FileDownloader {
  static void downloadCallback(
      String id,
      int status,
      int progress,
      ) {
    final SendPort? send = IsolateNameServer.lookupPortByName(
      'downloader_send_port',
    );
    print("seeeeeeerv$send");
    send?.send("$id,$status,$progress");
  }
  static Future<void> downloadFile(String url, String savedDir) async {

    // Создание задачи загрузки файла
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: savedDir,
      showNotification: true, // Показывать уведомление во время загрузки
      openFileFromNotification: false, // Открывать файл после загрузки
    );
    print("taskCreaaaaaaates");

  }
}