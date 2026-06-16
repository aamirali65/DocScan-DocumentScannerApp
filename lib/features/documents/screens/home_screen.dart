import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/document_service.dart';
import '../../../models/document_model.dart';
import '../../editor/screens/image_editor_screen.dart';
import '../../ocr/screens/ocr_result_screen.dart';
import '../../scan/screens/scan_screen.dart';
import '../../ads/widgets/banner_ad_widget.dart';
import '../widgets/document_card.dart';
import '../../../services/pdf_export_service.dart';
import 'package:open_filex/open_filex.dart';

class OldHomeScreen extends StatefulWidget {
  const OldHomeScreen({super.key});

  @override
  State<OldHomeScreen> createState() => _OldHomeScreenState();
}

class _OldHomeScreenState extends State<OldHomeScreen> {
  List<ScanDocument> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  void _loadDocs() {
    setState(() => _documents = DocumentService.getAllDocuments());
  }

  Future<void> _showImagePicker(String mode) async {
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
                    _handleSelectedImage(mode, File(picked.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.document_scanner, color: Colors.blue),
                title: const Text("Scan with Camera"),
                onTap: () {
                  Navigator.pop(ctx);
                  _openEdgeScan(mode);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEdgeScan(String mode) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (result != null && result is File && mounted) {
      _handleSelectedImage(mode, result);
    }
  }

  void _handleSelectedImage(String mode, File image) {
    switch (mode) {
      case "editor":
        Navigator.push(context, MaterialPageRoute(builder: (_) => ImageEditorScreen(image: image)));
        break;
      case "copier":
        Navigator.push(context, MaterialPageRoute(builder: (_) => OcrResultScreen(image: image)));
        break;
    }
  }

  void _openDocument(ScanDocument doc) {
    if (doc.pagePaths.isEmpty) return;
    final firstPage = File(doc.pagePaths.first);
    if (!firstPage.existsSync()) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(doc.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Image'),
              onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => ImageEditorScreen(image: firstPage, document: doc))); },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Run OCR'),
              onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => OcrResultScreen(image: firstPage))); },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export to PDF'),
              onTap: () { Navigator.pop(ctx); _exportToPdf(doc); },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Open File'),
              onTap: () { Navigator.pop(ctx); OpenFilex.open(firstPage.path); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToPdf(ScanDocument doc) async {
    final bytesList = <Uint8List>[];
    for (final path in doc.pagePaths) {
      final file = File(path);
      if (file.existsSync()) bytesList.add(await file.readAsBytes());
    }
    if (bytesList.isEmpty) return;
    try {
      final file = await PdfExportService.exportToPdf(pageImages: bytesList, format: PdfFormat.fitToContent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved'), action: SnackBarAction(label: 'Open', onPressed: () => OpenFilex.open(file.path))),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.document_scanner, size: 80, color: Colors.blue),
          const SizedBox(height: 12),
          const Text(
            "AI Doc Scanner",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          const Text(
            "Scan, recognize text, and edit documents with ease.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    "Select which option you want for your document",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _actionButton(Icons.edit_document, "Doc Editor", () => _showImagePicker("editor")),
                      _actionButton(Icons.text_snippet_rounded, "Text Copier", () => _showImagePicker("copier")),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _documents.isEmpty
            ? Center(child: SingleChildScrollView(child: mainContent))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Center(child: mainContent),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text("Recent Documents", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _loadDocs(),
                            child: const Text("Refresh"),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _documents.length > 5 ? 5 : _documents.length,
                      itemBuilder: (_, i) => DocumentCard(
                        document: _documents[i],
                        onTap: () => _openDocument(_documents[i]),
                        onDelete: () async {
                          await DocumentService.deleteDocument(_documents[i].id);
                          _loadDocs();
                        },
                        onRename: () {
                          final ctrl = TextEditingController(text: _documents[i].title);
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Rename'),
                              content: TextField(controller: ctrl, autofocus: true),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                TextButton(onPressed: () async {
                                  await DocumentService.renameDocument(_documents[i].id, ctrl.text);
                                  _loadDocs();
                                  if (ctx.mounted) Navigator.pop(ctx);
                                }, child: const Text('Rename')),
                              ],
                            ),
                          );
                        },
                        onDuplicate: () async {
                          final d = _documents[i];
                          final newDoc = ScanDocument(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: '${d.title} (Copy)',
                            pageCount: d.pageCount,
                            thumbnailPath: d.thumbnailPath,
                            pagePaths: List.from(d.pagePaths),
                            ocrTextsPerPage: List.from(d.ocrTextsPerPage),
                            ocrText: d.ocrText,
                          );
                          await DocumentService.saveDocument(newDoc);
                          _loadDocs();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const BannerAdWidget(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.blue, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
