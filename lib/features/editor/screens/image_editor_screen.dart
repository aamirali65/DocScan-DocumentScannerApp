import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import '../../../services/image_enhancement_service.dart';
import '../../../services/pdf_export_service.dart';
import '../../../models/document_model.dart';
import 'package:path_provider/path_provider.dart';
import '../../../screens/save_success_screen.dart';

class ImageEditorScreen extends StatefulWidget {
  final File image;
  final ScanDocument? document;
  final int? pageIndex;
  const ImageEditorScreen({super.key, required this.image, this.document, this.pageIndex});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  Uint8List? _editedBytes;
  bool _isProcessing = false;
  bool _isEnhancing = false;
  EnhancementFilter _currentFilter = EnhancementFilter.original;

  @override
  void initState() {
    super.initState();
    _openEditor();
  }

  Future<void> _openEditor() async {
    final bytes = await widget.image.readAsBytes();
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImageEditor(image: bytes)),
    );
    if (result != null && result is Uint8List) {
      if (mounted) setState(() => _editedBytes = result);
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  void _applyFilter(EnhancementFilter filter) {
    if (_editedBytes == null) return;
    final filtered = ImageEnhancementService.applyFilter(_editedBytes!, filter);
    setState(() { _editedBytes = filtered; _currentFilter = filter; });
  }

  Future<void> _autoEnhance() async {
    if (_editedBytes == null) return;
    setState(() => _isEnhancing = true);
    await Future.delayed(const Duration(milliseconds: 50));
    final enhanced = ImageEnhancementService.autoEnhance(_editedBytes!);
    if (mounted) setState(() { _editedBytes = enhanced; _currentFilter = EnhancementFilter.enhanced; _isEnhancing = false; });
  }

  void _showSaveOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Save As', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _saveOption(ctx, Icons.picture_as_pdf, 'Save as PDF', Colors.red, () {
                Navigator.pop(ctx);
                _exportPdf();
              }),
              _saveOption(ctx, Icons.image, 'Save as JPG', Colors.blue, () {
                Navigator.pop(ctx);
                _saveImage('jpg');
              }),
              _saveOption(ctx, Icons.image_outlined, 'Save as PNG', Colors.green, () {
                Navigator.pop(ctx);
                _saveImage('png');
              }),
              const SizedBox(height: 8),
              const Text('Enhancements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: EnhancementFilter.values.map((f) {
                  final labels = { EnhancementFilter.original: 'Original', EnhancementFilter.grayscale: 'Grayscale', EnhancementFilter.blackWhite: 'B&W', EnhancementFilter.enhanced: 'Enhanced' };
                  return ChoiceChip(
                    label: Text(labels[f]!, style: const TextStyle(fontSize: 13)),
                    selected: _currentFilter == f,
                    onSelected: (_) { Navigator.pop(ctx); _applyFilter(f); },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Auto Enhance'),
                  onPressed: () { Navigator.pop(ctx); _autoEnhance(); },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveOption(BuildContext ctx, IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      onTap: onTap,
    );
  }

  Future<void> _saveImage(String format) async {
    if (_editedBytes == null) return;
    setState(() => _isProcessing = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/DocScanner/edited_${DateTime.now().millisecondsSinceEpoch}.$format');
      await file.create(recursive: true);
      await file.writeAsBytes(_editedBytes!);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => SaveSuccessScreen(filePath: file.path, format: format),
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportPdf() async {
    if (_editedBytes == null) return;
    setState(() => _isProcessing = true);
    try {
      final file = await PdfExportService.exportToPdf(
        pageImages: [_editedBytes!],
        format: PdfFormat.fitToContent,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => SaveSuccessScreen(filePath: file.path, format: 'pdf'),
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Document', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: _showSaveOptions),
          IconButton(icon: const Icon(Icons.save, color: Colors.white), onPressed: _showSaveOptions),
        ],
      ),
      body: Center(
        child: _isProcessing || _isEnhancing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 12),
                  Text(_isEnhancing ? 'Enhancing image...' : 'Processing...', style: const TextStyle(color: Colors.white)),
                ],
              )
            : _editedBytes != null
                ? InteractiveViewer(
                    child: Image.memory(_editedBytes!, fit: BoxFit.contain),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}


