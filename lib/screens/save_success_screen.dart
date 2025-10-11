import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class SaveSuccessScreen extends StatelessWidget {
  final String filePath;
  final String format;

  const SaveSuccessScreen({
    Key? key,
    required this.filePath,
    required this.format,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isImage = format == 'jpg' || format == 'png';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 70),
                const SizedBox(height: 10),
                const Text(
                  "File Saved Successfully!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(filePath),
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Column(
                    children: const [
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 80),
                      SizedBox(height: 8),
                      Text("PDF File", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => OpenFilex.open(filePath),
                      icon: const Icon(Icons.open_in_new,color: Colors.white,),
                      label: const Text("Open",style: TextStyle(color: Colors.white),),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Share.shareXFiles([XFile(filePath)], text: "Shared from DocScanner"),
                      icon: const Icon(Icons.share,color: Colors.white,),
                      label: const Text("Share",style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  icon: const Icon(Icons.home, color: Colors.blue),
                  label: const Text("Back to Home", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
