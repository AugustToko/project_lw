enum WallpaperType {
  /// HTML5 - CSS -JS 或 WEB URL
  HTML,

  /// 视频
  VIDEO,

  /// 通常为 AE lottie 动画
  VIEW
}

class Wallpaper {
  final WallpaperType wallpaperType;
  final String id;
  final String name;
  final String description;
  final String author;
  final String thumbnail;
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

  factory Wallpaper.fromMap(dynamic map) {
    if (null == map) return null;
    var temp;
    return Wallpaper(
      wallpaperType: null == (temp = map['wallpaperType'])
          ? null
          : (temp is num
              ? WallpaperType.values[temp.toInt()]
              : WallpaperType.values[int.tryParse(temp)]),
      id: map['id']?.toString(),
      name: map['name']?.toString(),
      description: map['description']?.toString(),
      author: map['author']?.toString(),
      thumbnail: map['thumbnail']?.toString(),
      versionCode: null == (temp = map['versionCode'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp)),
      versionName: map['versionName']?.toString(),
      path: map['path']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wallpaperType': wallpaperType?.index,
      'id': id,
      'name': name,
      'description': description,
      'author': author,
      'thumbnail': thumbnail,
      'versionCode': versionCode,
      'versionName': versionName,
      'path': path,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory Wallpaper.fromJson(dynamic map) {
    return Wallpaper.fromMap(map);
  }

}
