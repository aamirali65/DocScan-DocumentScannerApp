import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/document_model.dart';
import '../../../services/document_service.dart';
import '../../../services/pdf_export_service.dart';
import '../widgets/document_card.dart';
import '../../editor/screens/image_editor_screen.dart';
import '../../ocr/screens/ocr_result_screen.dart';
import 'package:open_filex/open_filex.dart';

final documentsProvider = StateNotifierProvider<DocumentsNotifier, List<ScanDocument>>((ref) => DocumentsNotifier());

class DocumentsNotifier extends StateNotifier<List<ScanDocument>> {
  DocumentsNotifier() : super([]);

  Future<void> load() async {
    state = DocumentService.getAllDocuments();
  }

  void setResults(List<ScanDocument> results) {
    state = results;
  }

  Future<void> delete(String id) async {
    await DocumentService.deleteDocument(id);
    await load();
  }

  Future<void> rename(String id, String newTitle) async {
    await DocumentService.renameDocument(id, newTitle);
    await load();
  }

  Future<void> duplicate(ScanDocument doc) async {
    final newDoc = ScanDocument(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: '${doc.title} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      pageCount: doc.pageCount,
      thumbnailPath: doc.thumbnailPath,
      pagePaths: List.from(doc.pagePaths),
      ocrTextsPerPage: List.from(doc.ocrTextsPerPage),
      ocrText: doc.ocrText,
    );
    await DocumentService.saveDocument(newDoc);
    await load();
  }
}

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(documentsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRenameDialog(ScanDocument doc) {
    final controller = TextEditingController(text: doc.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () {
            Navigator.pop(ctx);
            ref.read(documentsProvider.notifier).rename(doc.id, controller.text);
          }, child: const Text('Rename')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() { _isSearching = false; _searchController.clear(); });
                      ref.read(documentsProvider.notifier).load();
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (q) {
                  final results = DocumentService.searchDocuments(q);
                  ref.read(documentsProvider.notifier).setResults(results);
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Text('My Documents', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () => setState(() => _isSearching = !_isSearching),
                ),
              ],
            ),
          ),
          Expanded(
            child: documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text('No documents yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: documents.length,
                    itemBuilder: (_, i) {
                      final doc = documents[i];
                      return DocumentCard(
                        document: doc,
                        onTap: () => _openDocument(doc),
                        onRename: () => _showRenameDialog(doc),
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Document'),
                              content: Text('Delete "${doc.title}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                TextButton(onPressed: () { Navigator.pop(ctx); ref.read(documentsProvider.notifier).delete(doc.id); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                        },
                        onDuplicate: () => ref.read(documentsProvider.notifier).duplicate(doc),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
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
      if (file.existsSync()) {
        bytesList.add(await file.readAsBytes());
      }
    }
    if (bytesList.isEmpty) return;
    try {
      final file = await PdfExportService.exportToPdf(
        pageImages: bytesList,
        format: PdfFormat.fitToContent,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved: ${file.path}'), action: SnackBarAction(label: 'Open', onPressed: () => OpenFilex.open(file.path))),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF Error: $e')));
    }
  }
}
