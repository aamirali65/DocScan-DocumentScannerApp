import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'features/documents/screens/home_screen.dart';

class DocScanApp extends StatelessWidget {
  const DocScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppConstants.primaryColor,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
        ),
      ),
      home: const OldHomeScreen(),
    );
  }
}
