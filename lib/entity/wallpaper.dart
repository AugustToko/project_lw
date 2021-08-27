import 'dart:convert';

enum WallpaperType {
  /// HTML5 - CSS -JS 或 WEB URL
  HTML,

  /// 视频
  VIDEO,

  /// 通常为 AE lottie 动画
  VIEW,

  /// 图片
  IMAGE,
}

extension WallpaperTypeExt on WallpaperType {
  String name() {
    switch (this) {
      case WallpaperType.HTML:
        return 'HTML';
      case WallpaperType.VIDEO:
        return '视频';
      case WallpaperType.VIEW:
        return 'VIEW';
      case WallpaperType.IMAGE:
        return '图像';
    }
  }
}

class Wallpaper {
  static const TABLE = 'wallpaper';

  static const CREATE_TABLE = "CREATE TABLE $TABLE("
      "id TEXT PRIMARY KEY, "
      "wallpaperType INTEGER, "
      "name TEXT, "
      "description TEXT, "
      "author TEXT, "
      "thumbnails TEXT, "
      "tags TEXT, "
      "versionCode INTEGER,"
      "versionName TEXT,"
      "path TEXT"
      ")";

  final String id;
  final WallpaperType wallpaperType;
  final String name;
  final String description;
  final String author;
  final List<String>? thumbnails;
  final List<String>? tags;
  final int versionCode;
  final String versionName;

  /// [WallpaperType.HTML] url
  /// [WallpaperType.VIDEO] file path
  /// [WallpaperType.VIEW] file (config.json) path
  final String mainFilepath;

  const Wallpaper.all(
      this.id,
      this.wallpaperType,
      this.name,
      this.description,
      this.author,
      this.thumbnails,
      this.tags,
      this.versionCode,
      this.versionName,
      this.mainFilepath);

  const Wallpaper({
    required this.id,
    required this.wallpaperType,
    required this.name,
    required this.description,
    this.tags,
    required this.author,
    this.thumbnails,
    required this.versionCode,
    required this.versionName,
    required this.mainFilepath,
  });

  factory Wallpaper.fromMap(Map<String, dynamic> map) {
    final t = map['thumbnails'];
    final t2 = map['tags'];

    return Wallpaper(
      id: map['id'] as String,
      wallpaperType: WallpaperType.values[map['wallpaperType'] as int],
      name: map['name'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      thumbnails: t is String
          ? (json.decode(map['thumbnails'] as String) as List<dynamic>)
              .cast<String>()
          : (t as List<dynamic>).cast<String>(),
      tags: map['tags'] != null
          ? (json.decode(map['tags']) as List<dynamic>).cast<String>()
          : [],
      versionCode: map['versionCode'] as int,
      versionName: map['versionName'] as String,
      mainFilepath: map['path'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'wallpaperType': wallpaperType.index,
      'name': name,
      'description': description,
      'author': author,
      'thumbnails': json.encode(thumbnails),
      'tags': json.encode(tags),
      'versionCode': versionCode,
      'versionName': versionName,
      'path': mainFilepath,
    };
  }

  /// ```json
  /// {
  ///   "id": "1",
  ///   "wallpaperType": 0,
  ///   "name": "TEST1",
  ///   "description": "description",
  ///   "author": "author",
  ///   "thumbnails": [
  ///     "asd",
  ///     "asdasd"
  ///   ],
  ///   "tags": [
  ///     "asd",
  ///     "asdasd"
  ///   ],
  ///   "versionCode": 1,
  ///   "versionName": "Fuck",
  ///   "path": "http://fff.cmiscm.com/#!/section/cylinder"
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory Wallpaper.fromJson(Map<String, dynamic> map) {
    return Wallpaper.fromMap(map);
  }

  Wallpaper copyWith({
    final String? id,
    final WallpaperType? wallpaperType,
    final String? name,
    final String? description,
    final String? author,
    final List<String>? thumbnails,
    final List<String>? tags,
    final int? versionCode,
    final String? versionName,
    final String? path,
  }) {
    return Wallpaper(
      id: id ?? this.id,
      wallpaperType: wallpaperType ?? this.wallpaperType,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      thumbnails: thumbnails ?? this.thumbnails,
      tags: tags ?? this.tags,
      versionCode: versionCode ?? this.versionCode,
      versionName: versionName ?? this.versionName,
      mainFilepath: path ?? this.mainFilepath,
    );
  }

  @override
  String toString() {
    return 'Wallpaper{id: $id, wallpaperType: $wallpaperType, name: $name, description: $description, author: $author, thumbnails: $thumbnails, tags: $tags, versionCode: $versionCode, versionName: $versionName, mainFilepath: $mainFilepath}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallpaper && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
