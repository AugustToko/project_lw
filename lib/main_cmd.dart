import 'dart:convert';
import 'dart:io';

import 'package:file_utils/file_utils.dart';
import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/utils/wallpaper_file_utils.dart';

void main() {
  print(FileUtils.basename(
      File('E:\\project_lw\\assets\\demo1\\wallpaper.lwpak').path));
  // WallpaperFileUtil.unpackWallpaper(
  //   File('E:\\project_lw\\assets\\demo1\\wallpaper.lwpak'),
  //   Directory('C:\\Users\\Administrator\\Desktop\\test'),
  // );
}

void testJson() {
  print(json.encode(Wallpaper.all(
      '1',
      WallpaperType.HTML,
      'TEST1',
      'description',
      'author',
      ['asd', 'asdasd'],
      1,
      'Fuck',
      'http://fff.cmiscm.com/#!/section/cylinder')));
}
