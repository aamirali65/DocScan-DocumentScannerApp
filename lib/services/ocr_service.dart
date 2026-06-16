import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OcrService {
  static Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    return _processImage(inputImage);
  }

  static Future<String> recognizeTextFromBytes(Uint8List bytes) async {
    final file = File('${Directory.systemTemp.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    final result = await recognizeText(file);
    await file.delete();
    return result;
  }

  static Future<String> recognizeTextWithPreprocessing(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return recognizeText(imageFile);

    image = img.grayscale(image);
    image = img.adjustColor(image, contrast: 1.3, brightness: 1.03);

    final processed = Uint8List.fromList(img.encodePng(image));
    final file = File('${Directory.systemTemp.path}/ocr_preprocessed_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(processed);
    final result = await recognizeText(file);
    await file.delete();
    return result;
  }

  static Future<String> _processImage(InputImage inputImage) async {
    final textRecognizer = TextRecognizer();
    try {
      final result = await textRecognizer.processImage(inputImage);
      return result.text;
    } finally {
      textRecognizer.close();
    }
  }
}
