import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isProcessing = false;

  Future<void> _startScan() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '${dir.path}/DocScanner/scan_$timestamp.jpg';

      final success = await EdgeDetection.detectEdge(
        savePath,
        canUseGallery: true,
        androidScanTitle: 'Scan Document',
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'B&W',
        androidCropReset: 'Reset',
      );

      if (!mounted) return;

      if (success) {
        final imageFile = File(savePath);
        if (imageFile.existsSync()) {
          Navigator.pop(context, imageFile);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      Navigator.pop(context, File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Scan Document', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            tooltip: 'Pick from Gallery',
            onPressed: _pickFromGallery,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.document_scanner, size: 96, color: Colors.white24),
            const SizedBox(height: 24),
            const Text(
              'Position your document in the frame',
              style: TextStyle(color: Colors.white60, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'and tap the button below to scan',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: _isProcessing ? null : _startScan,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: _isProcessing
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : const Icon(Icons.camera_alt, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library, color: Colors.white54),
              label: const Text('Pick from Gallery', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
