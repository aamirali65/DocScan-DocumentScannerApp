import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

enum PdfFormat { fitToContent, a4, custom }

class PdfExportService {
  static Future<File> exportToPdf({
    required List<Uint8List> pageImages,
    PdfFormat format = PdfFormat.fitToContent,
    double customMargin = 0.0,
    String? outputPath,
  }) async {
    final pdf = pw.Document();

    for (final imageBytes in pageImages) {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) continue;

      final imageWidth = decoded.width.toDouble();
      final imageHeight = decoded.height.toDouble();
      final pdfImage = pw.MemoryImage(imageBytes);

      double pageWidth, pageHeight;
      pw.EdgeInsets margin;

      switch (format) {
        case PdfFormat.fitToContent:
          pageWidth = imageWidth;
          pageHeight = imageHeight;
          margin = pw.EdgeInsets.zero;
          break;
        case PdfFormat.a4:
          final a4 = PdfPageFormat.a4;
          pageWidth = a4.width;
          pageHeight = a4.height;
          margin = pw.EdgeInsets.all(20);
          break;
        case PdfFormat.custom:
          pageWidth = imageWidth;
          pageHeight = imageHeight;
          margin = pw.EdgeInsets.all(customMargin);
          break;
      }

      pdf.addPage(
        pw.Page(
          margin: margin,
          pageFormat: PdfPageFormat(pageWidth, pageHeight, marginAll: 0),
          build: (_) => pw.Center(
            child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    final dir = outputPath != null
        ? File(outputPath).parent
        : await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/docscan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
