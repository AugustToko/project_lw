class WallpaperExtInfo {
  String filePath;
  List<String> allPath;
  int size;

  /// 是否已验证
  /// 是否经过社区验证
  bool verification;

  WallpaperExtInfo(this.filePath, this.allPath, this.size, this.verification);
}
