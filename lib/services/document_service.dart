import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/document_model.dart';

class DocumentService {
  static late File _file;
  static List<ScanDocument> _documents = [];

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/docscan_documents.json');
    if (_file.existsSync()) {
      try {
        final json = await _file.readAsString();
        if (json.trim().isEmpty) return;
        final List<dynamic> list = jsonDecode(json);
        _documents = list.map((e) => ScanDocument.fromMap(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Failed to parse documents file: $e');
      }
    }
  }

  static Future<void> _save() async {
    final json = jsonEncode(_documents.map((d) => d.toMap()).toList());
    await _file.writeAsString(json);
  }

  static List<ScanDocument> getAllDocuments() => List.from(_documents)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  static List<ScanDocument> searchDocuments(String query) {
    final lower = query.toLowerCase();
    return _documents.where((d) =>
      d.title.toLowerCase().contains(lower) ||
      d.ocrText.toLowerCase().contains(lower)
    ).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Future<void> saveDocument(ScanDocument doc) async {
    _documents.add(doc);
    await _save();
  }

  static Future<void> updateDocument(ScanDocument doc) async {
    doc.updatedAt = DateTime.now();
    final idx = _documents.indexWhere((d) => d.id == doc.id);
    if (idx >= 0) {
      _documents[idx] = doc;
      await _save();
    }
  }

  static Future<void> deleteDocument(String id) async {
    _documents.removeWhere((d) => d.id == id);
    await _save();
  }

  static Future<void> renameDocument(String id, String newTitle) async {
    final doc = _documents.firstWhere((d) => d.id == id);
    doc.title = newTitle;
    doc.updatedAt = DateTime.now();
    await _save();
  }

  static ScanDocument? getDocument(String id) {
    final docs = _documents.where((d) => d.id == id);
    return docs.isEmpty ? null : docs.first;
  }
}
