import 'package:flutter/material.dart';
import 'services/document_service.dart';
import 'services/ad_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DocumentService.init();
  } catch (e) {
    debugPrint('DocumentService init error: $e');
  }
  try {
    await AdService.init();
  } catch (e) {
    debugPrint('AdService init error (non-fatal): $e');
  }
  runApp(const DocScanApp());
}
