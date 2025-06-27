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
    print("seeeeeeerv$send - $status");
    send?.send("$id,$status,$progress");
  }
  static Future<String?> downloadFile(String url, String savedDir) async {
    print("try to download");
    return "";
  }
}