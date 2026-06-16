import 'dart:typed_data';
import 'package:image/image.dart' as img;

enum EnhancementFilter { original, grayscale, blackWhite, enhanced }

class ImageEnhancementService {
  static Uint8List applyFilter(Uint8List imageBytes, EnhancementFilter filter) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    switch (filter) {
      case EnhancementFilter.grayscale:
        image = img.grayscale(image);
        break;
      case EnhancementFilter.blackWhite:
        image = img.grayscale(image);
        image = _applyThreshold(image);
        break;
      case EnhancementFilter.enhanced:
        image = img.adjustColor(image, contrast: 1.4, brightness: 1.05);
        break;
      case EnhancementFilter.original:
        break;
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  static Uint8List autoEnhance(Uint8List imageBytes) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    image = img.grayscale(image);
    image = img.adjustColor(image, contrast: 1.3, brightness: 1.03);
    return Uint8List.fromList(img.encodePng(image));
  }

  static img.Image _applyThreshold(img.Image image) {
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final l = p.r;
        if (l > 128) {
          image.setPixelRgba(x, y, 255, 255, 255, 255);
        } else {
          image.setPixelRgba(x, y, 0, 0, 0, 255);
        }
      }
    }
    return image;
  }
}
