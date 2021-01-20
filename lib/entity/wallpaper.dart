enum WallpaperType {
  /// HTML5 - CSS -JS 或 WEB URL
  HTML,

  /// 视频
  VIDEO,

  /// 通常为 AE lottie 动画
  VIEW
}

class Wallpaper {
  static const TABLE = 'wallpaper';

  static const CREATE_TABLE = "CREATE TABLE $TABLE("
      "id TEXT PRIMARY KEY, "
      "wallpaperType INTEGER, "
      "name TEXT, "
      "description TEXT, "
      "author TEXT, "
      "thumbnail TEXT, "
      "versionCode INTEGER,"
      "versionName TEXT,"
      "path TEXT"
      ")";

  final String id;
  final WallpaperType wallpaperType;
  final String name;
  final String description;
  final String author;
  final List<String> thumbnail;
  final int versionCode;
  final String versionName;

  /// [WallpaperType.HTML] url
  /// [WallpaperType.VIDEO] file path
  /// [WallpaperType.VIEW] file (config.json) path
  final String path;

  const Wallpaper.all(
      this.id,
      this.wallpaperType,
      this.name,
      this.description,
      this.author,
      this.thumbnail,
      this.versionCode,
      this.versionName,
      this.path);

  const Wallpaper(
      {this.id,
      this.wallpaperType,
      this.name,
      this.description,
      this.author,
      this.thumbnail,
      this.versionCode,
      this.versionName,
      this.path});

  factory Wallpaper.fromMap(Map<String, dynamic> map) {
    return new Wallpaper(
      id: map['id'] as String,
      wallpaperType: map['wallpaperType'] as WallpaperType,
      name: map['name'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      thumbnail: map['thumbnail'] as List<String>,
      versionCode: map['versionCode'] as int,
      versionName: map['versionName'] as String,
      path: map['path'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': this.id,
      'wallpaperType': this.wallpaperType.index,
      'name': this.name,
      'description': this.description,
      'author': this.author,
      'thumbnail': this.thumbnail,
      'versionCode': this.versionCode,
      'versionName': this.versionName,
      'path': this.path,
    };
  }

  /// ```json
  /// {
  ///   "id": "1",
  ///   "wallpaperType": 0,
  ///   "name": "TEST1",
  ///   "description": "description",
  ///   "author": "author",
  ///   "thumbnail": [
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

  @override
  String toString() {
    return 'Wallpaper{id: $id, wallpaperType: $wallpaperType, name: $name, description: $description, author: $author, thumbnail: $thumbnail, versionCode: $versionCode, versionName: $versionName, path: $path}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallpaper && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
