import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../utils/constants.dart';

class SaveSuccessScreen extends StatelessWidget {
  final String filePath;
  final String format;

  const SaveSuccessScreen({
    super.key,
    required this.filePath,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = format == 'jpg' || format == 'png';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Success')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 72),
                  const SizedBox(height: 16),
                  Text('File Saved!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(format.toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  if (isImage && File(filePath).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(filePath), width: 200, height: 200, fit: BoxFit.cover),
                    ),
                  if (format == 'pdf')
                    const Column(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 80),
                        SizedBox(height: 8),
                        Text('PDF Document', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                        ),
                        onPressed: () => OpenFilex.open(filePath),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                        ),
                        onPressed: () async {
                          await SharePlus.instance.share(
                            ShareParams(files: [XFile(filePath)], text: 'Shared from DocScan'),
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
