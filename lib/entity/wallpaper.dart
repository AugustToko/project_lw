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

class Wallpaper {
  static const TABLE = 'wallpaper';

  static const CREATE_TABLE = "CREATE TABLE $TABLE("
      "id TEXT PRIMARY KEY, "
      "wallpaperType INTEGER, "
      "name TEXT, "
      "description TEXT, "
      "author TEXT, "
      "thumbnails TEXT, "
      "versionCode INTEGER,"
      "versionName TEXT,"
      "path TEXT"
      ")";

  final String id;
  final WallpaperType wallpaperType;
  final String name;
  final String description;
  final String author;
  final List<String> thumbnails;
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
      this.versionCode,
      this.versionName,
      this.mainFilepath);

  const Wallpaper({
    this.id,
    this.wallpaperType,
    this.name,
    this.description,
    this.author,
    this.thumbnails,
    this.versionCode,
    this.versionName,
    this.mainFilepath,
  });

  factory Wallpaper.fromMap(Map<String, dynamic> map) {
    final t = map['thumbnails'];
    return new Wallpaper(
      id: map['id'] as String,
      wallpaperType: WallpaperType.values[map['wallpaperType']],
      name: map['name'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      thumbnails: t is String
          ? (json.decode(map['thumbnails']) as List<dynamic>).cast<String>()
          : (t as List<dynamic>).cast<String>(),
      versionCode: map['versionCode'] as int,
      versionName: map['versionName'] as String,
      mainFilepath: map['path'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': this.id,
      'wallpaperType': this.wallpaperType.index,
      'name': this.name,
      'description': this.description,
      'author': this.author,
      'thumbnails': json.encode(this.thumbnails),
      'versionCode': this.versionCode,
      'versionName': this.versionName,
      'path': this.mainFilepath,
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
  ///   "versionCode": 1,
  ///   "versionName": "Fuck",
  ///   "path": "http://fff.cmiscm.com/#!/section/cylinder"
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory Wallpaper.fromJson(dynamic map) {
    return Wallpaper.fromMap(map);
  }

  Wallpaper copyWith({
    final String id,
    final WallpaperType wallpaperType,
    final String name,
    final String description,
    final String author,
    final List<String> thumbnails,
    final int versionCode,
    final String versionName,
    final String path,
  }) {
    return Wallpaper(
      id: id ?? this.id,
      wallpaperType: wallpaperType ?? this.wallpaperType,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      thumbnails: thumbnails ?? this.thumbnails,
      versionCode: versionCode ?? this.versionCode,
      versionName: versionName ?? this.versionName,
      mainFilepath: path ?? this.mainFilepath,
    );
  }

  @override
  String toString() {
    return 'Wallpaper{id: $id, wallpaperType: $wallpaperType, name: $name, description: $description, author: $author, thumbnails: $thumbnails, versionCode: $versionCode, versionName: $versionName, path: $mainFilepath}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallpaper && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
