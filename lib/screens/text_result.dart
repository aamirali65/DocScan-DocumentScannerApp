import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';

class TextRecognizerScreen extends StatefulWidget {
  final File image;
  const TextRecognizerScreen({super.key, required this.image});

  @override
  State<TextRecognizerScreen> createState() => _TextRecognizerScreenState();
}

class _TextRecognizerScreenState extends State<TextRecognizerScreen> {
  String recognizedText = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFile(widget.image);
      final result = await textRecognizer.processImage(inputImage);

      setState(() {
        recognizedText = result.text;
        isLoading = false;
      });

      textRecognizer.close();
    } catch (e) {
      setState(() {
        recognizedText = "Error reading text: $e";
        isLoading = false;
      });
    }
  }

  void _copyText() {
    if (recognizedText.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: recognizedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Text copied to clipboard"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Text Recognition",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy,color: Colors.white,),
            tooltip: "Copy text",
            onPressed: _copyText,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Image Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                widget.image,
                width: double.infinity,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.35,
              ),
            ),

            const SizedBox(height: 12),

            // Recognized Text Container
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      recognizedText.isEmpty
                          ? "No text detected."
                          : recognizedText,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Copy Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy,color: Colors.white,),
                label: const Text("Copy Recognized Text",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
