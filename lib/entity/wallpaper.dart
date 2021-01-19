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
  final String name;
  final String description;
  final String author;
  final String thumbnail;
  final int versionCode;
  final String versionName;

  Wallpaper(this.wallpaperType, this.name, this.description, this.author, this.thumbnail, this.versionCode, this.versionName);
}