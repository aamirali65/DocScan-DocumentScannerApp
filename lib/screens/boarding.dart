import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'editor.dart';
import 'text_result.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _showImagePicker(BuildContext context, String mode) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text("Pick from Gallery"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    _handleSelectedImage(context, mode, File(picked.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text("Capture from Camera"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await picker.pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    _handleSelectedImage(context, mode, File(picked.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSelectedImage(BuildContext context, String mode, File image) {
    Widget nextPage;

    switch (mode) {
      case "editor":
        nextPage = DocEditorScreen(image: image);
        break;
      case "copier":
        nextPage = TextRecognizerScreen(image: image);
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => nextPage));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.document_scanner, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "AI Doc Scanner",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Scan, recognize text, and edit documents with ease.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 50),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Select which option you want for your document",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_document,
                            label: "Doc Editor",
                            onTap: () => _showImagePicker(context, "editor"),
                          ),
                          _buildActionButton(
                            icon: Icons.text_snippet_rounded,
                            label: "Text Copier",
                            onTap: () => _showImagePicker(context, "copier"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
