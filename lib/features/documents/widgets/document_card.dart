import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/document_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';

class DocumentCard extends StatelessWidget {
  final ScanDocument document;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    this.onRename,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: document.thumbnailPath.isNotEmpty && File(document.thumbnailPath).existsSync()
                    ? Image.file(
                        File(document.thumbnailPath),
                        width: 64, height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 64, height: 80,
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        child: const Icon(Icons.description, color: AppConstants.primaryColor),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${document.pageCount} page${document.pageCount != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Helpers.formatDate(document.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'rename': onRename?.call();
                    case 'delete': onDelete?.call();
                    case 'duplicate': onDuplicate?.call();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'rename', child: ListTile(leading: Icon(Icons.edit), title: Text('Rename'))),
                  const PopupMenuItem(value: 'duplicate', child: ListTile(leading: Icon(Icons.copy), title: Text('Duplicate'))),
                  const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
