class ScanDocument {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  int pageCount;
  String thumbnailPath;
  String ocrText;
  List<String> pagePaths;
  List<String> ocrTextsPerPage;

  ScanDocument({
    required this.id,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.pageCount = 0,
    this.thumbnailPath = '',
    this.ocrText = '',
    List<String>? pagePaths,
    List<String>? ocrTextsPerPage,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        pagePaths = pagePaths ?? [],
        ocrTextsPerPage = ocrTextsPerPage ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'pageCount': pageCount,
        'thumbnailPath': thumbnailPath,
        'ocrText': ocrText,
        'pagePaths': pagePaths,
        'ocrTextsPerPage': ocrTextsPerPage,
      };

  factory ScanDocument.fromMap(Map<String, dynamic> map) => ScanDocument(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
        updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
        pageCount: map['pageCount'] as int? ?? 0,
        thumbnailPath: map['thumbnailPath'] as String? ?? '',
        ocrText: map['ocrText'] as String? ?? '',
        pagePaths: map['pagePaths'] != null ? List<String>.from(map['pagePaths'] as List) : [],
        ocrTextsPerPage: map['ocrTextsPerPage'] != null ? List<String>.from(map['ocrTextsPerPage'] as List) : [],
      );
}
