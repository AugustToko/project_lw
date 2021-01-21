import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_lw/entity/center/data_center.dart';
import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/main_cmd.dart';
import 'package:project_lw/misc/const.dart';
import 'package:project_lw/utils/wallpaper_file_utils.dart';

class WallpaperTools {
  static WallpaperTools instance = WallpaperTools._();

  WallpaperTools._();

  Directory wallpaperPlaceDir;

  Future<void> init() async {
    wallpaperPlaceDir = await getApplicationSupportDirectory();
  }

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
}
