import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'save_success_screen.dart';

class DocEditorScreen extends StatefulWidget {
  final File image;
  const DocEditorScreen({super.key, required this.image});

  @override
  State<DocEditorScreen> createState() => _DocEditorScreenState();
}

class _DocEditorScreenState extends State<DocEditorScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _openImageEditor();
  }

  Future<void> _openImageEditor() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final Uint8List imageBytes = await widget.image.readAsBytes();

    final edited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(image: imageBytes),
      ),
    );

    if (edited != null && edited is Uint8List) {
      _showSaveOptions(edited);
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _showSaveOptions(Uint8List editedBytes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            runSpacing: 10,
            children: [
              const Center(
                child: Text(
                  "Save As",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text("Save as PDF"),
                onTap: () {
                  Navigator.pop(context);
                  _saveFile(editedBytes, format: 'pdf');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text("Save as JPG"),
                onTap: () {
                  Navigator.pop(context);
                  _saveFile(editedBytes, format: 'jpg');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: Colors.green),
                title: const Text("Save as PNG"),
                onTap: () {
                  Navigator.pop(context);
                  _saveFile(editedBytes, format: 'png');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveFile(Uint8List editedBytes, {required String format}) async {
    if (!mounted) return;
    setState(() => _isProcessing = true);

    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    try {
      String filePath = "";

      if (format == 'pdf') {
        filePath = await compute(_savePDFInBackground, {'bytes': editedBytes});
      } else {
        filePath = await compute(_saveImageInBackground, {
          'bytes': editedBytes,
          'format': format,
        });
      }

      if (!mounted) return;
      setState(() => _isProcessing = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SaveSuccessScreen(
            filePath: filePath,
            format: format,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while saving: $e')),
      );
    }
  }

  /// Handles storage permission for Android 10+ correctly
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) return true;
      if (await Permission.storage.isGranted) return true;

      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;

      status = await Permission.storage.request();
      if (status.isGranted) return true;
    }
    return false;
  }

  /// Background isolate for saving image
  static Future<String> _saveImageInBackground(Map<String, dynamic> args) async {
    final bytes = args['bytes'] as Uint8List;
    final format = args['format'] as String;

    final directory = Directory('/storage/emulated/0/DocScanner');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/edited_$timestamp.$format';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Background isolate for saving PDF
  static Future<String> _savePDFInBackground(Map<String, dynamic> args) async {
    final bytes = args['bytes'] as Uint8List;
    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(bytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Center(
          child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
        ),
      ),
    );

    final directory = Directory('/storage/emulated/0/DocScanner');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/edited_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isProcessing
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 12),
            Text('Saving your file...', style: TextStyle(fontSize: 16)),
          ],
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}
