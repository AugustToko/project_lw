import 'dart:io';

import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_lw/entity/center/data_center.dart';
import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/entity/wallpaper_info.dart';
import 'package:project_lw/main_cmd.dart';
import 'package:project_lw/misc/const.dart';
import 'package:project_lw/utils/wallpaper_file_utils.dart';

class WallpaperTools {
  static WallpaperTools instance = WallpaperTools._();

  WallpaperTools._();

  /// 指壁纸存储位置
  Directory wallpaperPlaceDir;

  Future<void> init() async {
    wallpaperPlaceDir = await getApplicationSupportDirectory();
  }

  /// 初始化预设壁纸
  Future<void> initPresetWallpaper(BuildContext context) async {
    final dir = WallpaperTools.instance.wallpaperPlaceDir;

    await for (final path in Stream.fromIterable(PRESET_WALLPAPER_PATH)) {
      final wallpaperId = uuid.v1();
      final dest = Directory(dir.path + Platform.pathSeparator + wallpaperId);
      dest.createSync();

      final data = await rootBundle.load(path);

      final tempPakFile = File(dir.path +
          Platform.pathSeparator +
          wallpaperId +
          '.' +
          WallpaperFileUtil.SUPPORTED_WALLPAPER_FORMAT);

      await tempPakFile.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

      await WallpaperFileUtil.unpackWallpaper(tempPakFile, dest);

      tempPakFile.deleteSync();

      final wallpaper = WallpaperFileUtil.parseWallpaperPack(dest);

      await DataCenter.get(context)
          .addWallpaper(wallpaper.copyWith(id: wallpaperId));
    }
  }
}

extension WallpaperExt on Wallpaper {
  String getMainThumbnailPath() {
    return WallpaperTools.instance.wallpaperPlaceDir.path +
        Platform.pathSeparator +
        id +
        Platform.pathSeparator +
        thumbnails.first;
  }

  List<String> getAllThumbnailPath() {
    return thumbnails
        .map((e) =>
            WallpaperTools.instance.wallpaperPlaceDir.path +
            Platform.pathSeparator +
            id +
            Platform.pathSeparator +
            e)
        .toList();
  }

  String getDirPath() =>
      WallpaperTools.instance.wallpaperPlaceDir.path +
      Platform.pathSeparator +
      id;

  Future<WallpaperExtInfo> extInfo() async {
    final dirPath = this.getDirPath();
    final allPath = Directory(dirPath).listSync().map((e) => e.path).toList();
    final size = (await Directory(dirPath).stat()).size;

    return WallpaperExtInfo(dirPath, allPath, size, true);
  }
}
