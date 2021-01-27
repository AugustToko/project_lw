import 'dart:convert';
import 'dart:io';

import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/utils/wallpaper_file_utils.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

Future<void> main() async {
  await WallpaperFileUtil.packWallpaper(
    Directory(
        'C:\\Users\\chenlongcould\\AndroidStudioProjects\\project_lw\\presets\\demo6'),
  );
}
