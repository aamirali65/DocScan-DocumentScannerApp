import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Helpers {
  static Future<Directory> getAppDocumentsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final docsDir = Directory('${dir.path}/DocScanner');
    if (!docsDir.existsSync()) {
      docsDir.createSync(recursive: true);
    }
    return docsDir;
  }

  static Future<Directory> getScansDir() async {
    final base = await getAppDocumentsDir();
    final scansDir = Directory('${base.path}/scans');
    if (!scansDir.existsSync()) {
      scansDir.createSync(recursive: true);
    }
    return scansDir;
  }

  static Future<Directory> getPageDir(String docId) async {
    final scans = await getScansDir();
    final pageDir = Directory('${scans.path}/$docId');
    if (!pageDir.existsSync()) {
      pageDir.createSync(recursive: true);
    }
    return pageDir;
  }

  static Future<String> saveImage(Uint8List bytes, String docId, int pageIndex) async {
    final dir = await getPageDir(docId);
    final file = File('${dir.path}/page_$pageIndex.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
