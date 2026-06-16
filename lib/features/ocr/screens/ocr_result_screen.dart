import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/ocr_service.dart';
import '../../../utils/constants.dart';

class OcrResultScreen extends StatefulWidget {
  final File image;
  const OcrResultScreen({super.key, required this.image});

  @override
  State<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends State<OcrResultScreen> {
  String recognizedText = '';
  bool isLoading = true;
  bool usePreprocessing = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    setState(() => isLoading = true);
    try {
      String result;
      if (usePreprocessing) {
        result = await OcrService.recognizeTextWithPreprocessing(widget.image);
      } else {
        result = await OcrService.recognizeText(widget.image);
      }
      if (mounted) setState(() { recognizedText = result; isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { recognizedText = 'Error: $e'; isLoading = false; });
    }
  }

  void _copyText() {
    if (recognizedText.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: recognizedText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition'),
        actions: [
          IconButton(
            icon: Icon(usePreprocessing ? Icons.tune : Icons.tune_sharp),
            tooltip: 'Toggle preprocessing',
            onPressed: () { setState(() => usePreprocessing = !usePreprocessing); _processImage(); },
          ),
          IconButton(icon: const Icon(Icons.copy), onPressed: _copyText),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(widget.image, width: double.infinity, height: 200, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            recognizedText.isEmpty ? 'No text detected.' : recognizedText,
                            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Text'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                      ),
                      onPressed: recognizedText.trim().isEmpty ? null : _copyText,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
