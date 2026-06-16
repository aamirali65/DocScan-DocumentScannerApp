import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../utils/helpers.dart';

class FileService {
  static Future<String> saveCompressedImage(Uint8List bytes, String docId, int pageIndex) async {
    img.Image? image = img.decodeImage(bytes);
    if (image != null) {
      image = img.copyResize(image, width: image.width ~/ 2);
      final compressed = img.encodePng(image);
      return Helpers.saveImage(Uint8List.fromList(compressed), docId, pageIndex);
    }
    return Helpers.saveImage(bytes, docId, pageIndex);
  }

  static Future<File> saveImageToTemp(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> deleteDocumentDir(String docId) async {
    final scans = await Helpers.getScansDir();
    final dir = Directory('${scans.path}/$docId');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  static Future<int> getDirectorySize(Directory dir) async {
    int size = 0;
    await for (var entity in dir.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }
}
