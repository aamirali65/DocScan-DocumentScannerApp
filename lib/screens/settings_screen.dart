import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../features/ads/widgets/banner_ad_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Document Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.high_quality),
                  title: const Text('Image Quality'),
                  subtitle: const Text('High'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Default PDF Format'),
                  subtitle: const Text('Fit to Content'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const BannerAdWidget(),
          const SizedBox(height: 24),
          Text('About', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Developer'),
                  subtitle: Text('DocScan Team'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
