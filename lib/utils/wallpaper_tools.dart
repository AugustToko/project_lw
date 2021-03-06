import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_lw/entity/center/data_center.dart';
import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/entity/wallpaper_info.dart';
import 'package:project_lw/main_cmd.dart';
import 'package:project_lw/misc/const.dart';
import 'package:project_lw/utils/wallpaper_file_utils.dart';
import 'package:share_plus/share_plus.dart';

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

  /// 导入壁纸包
  /// [wallpaperPack] 壁纸包文件
  Future<void> importWallpaper(
      final BuildContext context, final File wallpaperPack) async {
    if (wallpaperPack == null || !wallpaperPack.existsSync()) return;

    final tempDir = Directory(
      wallpaperPlaceDir.path +
          Platform.pathSeparator +
          'temp-${DateTime.now().millisecondsSinceEpoch}',
    );

    tempDir.createSync();

    Future<void> clean() async {
      await tempDir.delete(recursive: true);
    }

    await WallpaperFileUtil.unpackWallpaper(wallpaperPack, tempDir);

    final config = File(tempDir.path +
        Platform.pathSeparator +
        WallpaperFileUtil.WALLPAPER_INFO_FILE_NAME);
    if (!config.existsSync()) {
      await clean();
      return;
    }

    final wallpaper = Wallpaper.fromJson(
        json.decode(config.readAsStringSync()) as Map<String, dynamic>);

    if (wallpaper == null &&
        !WallpaperFileUtil.checkWallpaperConfigFile(config)) {
      await clean();
      return;
    }

    final newDir = Directory(
        wallpaperPlaceDir.path + Platform.pathSeparator + wallpaper.id);
    if (newDir.existsSync()) {
      await clean();
      return;
    }

    newDir.createSync();

    await for (final element
        in Stream.fromIterable(tempDir.listSync(recursive: true))) {
      await element.rename(newDir.path +
          Platform.pathSeparator +
          FileUtils.basename(element.path));
    }

    print('------new-------');

    print(newDir.listSync(recursive: true).map((e) => e.path));

    await DataCenter.get(context).addWallpaper(wallpaper);
  }

  /// 分享壁纸包
  /// [wallpaper] 指定的壁纸包
  Future<void> shareWallpaper(Wallpaper wallpaper) async {
    final dir = Directory(wallpaper.getDirPath());

    final pak = await WallpaperFileUtil.packWallpaper(dir);

    print('----------------------------------');
    print(pak.path);
    print(pak.existsSync());

    final newPath = (await getTemporaryDirectory()).path +
        Platform.pathSeparator +
        FileUtils.basename(pak.path);

    pak.renameSync(newPath);

    print('----------------------------------');
    print(newPath);
    print(File(newPath));

    if (pak != null && pak.existsSync()) {
      Share.shareFiles([newPath],
          text: '${wallpaper.name}\n${wallpaper.description}');
    }
  }

  void removeWallpaper(BuildContext context, Wallpaper wallpaper) {
    if (wallpaper == null) return;
    final dir = Directory(wallpaper.getDirPath());
    dir.deleteSync(recursive: true);
    DataCenter.get(context).removeWallpaper(wallpaper);
  }

  Future<void> importVideo(BuildContext context, List<String> files) async {
    if (files == null || files.isEmpty) return;

    final target = <String>[];

    files.forEach((element) {
      if (element.endsWith(WallpaperFileUtil.SUPPORTED_VIDEO_FORMAT))
        target.add(element);
    });

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

    await for (final videoPath in Stream.fromIterable(target)) {
      final item = File(videoPath);
      final fileName = FileUtils.basename(videoPath);

      final id = uuid.v1();

      final tempName = item.parent.path +
          Platform.pathSeparator +
          '${DateTime.now().millisecondsSinceEpoch}.png';

      final result = await _flutterFFmpeg.executeWithArguments([
        // '-ss',
        // '00:01:00',
        // '-i',
        // path,
        // '-vframes',
        // '1',
        // '-q:v',
        // '2',
        '-i',
        '$videoPath',
        '-ss',
        '4.500',
        '-vframes',
        '1',
        '-q:v',
        '2',
        tempName,
      ]);

      if (result != 0 || !File(tempName).existsSync()) continue;

      final wallpaperConfig = Wallpaper(
          id: id,
          name: fileName,
          author: 'Unknown',
          description: 'None',
          mainFilepath: fileName,
          thumbnails: ['thumbnail1.png'],
          tags: ['NONE'],
          versionCode: 1,
          versionName: '1.0',
          wallpaperType: WallpaperType.VIDEO);

      final targetDir = Directory(
          WallpaperTools.instance.wallpaperPlaceDir.path +
              Platform.pathSeparator +
              wallpaperConfig.id);

      targetDir.createSync();

      final configFile = File(targetDir.path +
          Platform.pathSeparator +
          WallpaperFileUtil.WALLPAPER_INFO_FILE_NAME);

      configFile.writeAsStringSync(json.encode(wallpaperConfig));

      final thumbnailFile = File(tempName);

      await thumbnailFile
          .copy(targetDir.path + Platform.pathSeparator + 'thumbnail1.png');

      try {
        await thumbnailFile.delete();
      } catch (e, s) {
        print(e);
        print(s);
      }

      // thumbnailFile.renameSync(targetDir.path +
      //     Platform.pathSeparator +
      //     FileUtils.basename(thumbnailFile.path));

      final videoFile = File(videoPath);

      await videoFile.copy(targetDir.path +
          Platform.pathSeparator +
          FileUtils.basename(videoFile.path));

      await DataCenter.get(context).addWallpaper(wallpaperConfig);
    }
  }

  Future<void> importImage(BuildContext context, List<String> files) async {
    if (files == null || files.isEmpty) return;

    final target = <String>[];

    files.forEach((element) {
      if (element.endsWith('.png') || element.endsWith('.jpg'))
        target.add(element);
    });

    await for (final itemPath in Stream.fromIterable(target)) {
      print('importImageFromDir: $itemPath');
      final item = File(itemPath);
      final fileName = FileUtils.basename(itemPath);

      final id = uuid.v1();

      final wallpaperConfig = Wallpaper(
        id: id,
        name: fileName,
        author: 'Unknown',
        description: 'None',
        mainFilepath: fileName,
        thumbnails: [fileName],
        versionCode: 1,
        versionName: '1.0',
        wallpaperType: WallpaperType.IMAGE,
      );

      final targetDir = Directory(
        WallpaperTools.instance.wallpaperPlaceDir.path +
            Platform.pathSeparator +
            wallpaperConfig.id,
      );

      targetDir.createSync();

      item.copySync(wallpaperPlaceDir.path +
          Platform.pathSeparator +
          '$id' +
          Platform.pathSeparator +
          fileName);

      final configFile = File(targetDir.path +
          Platform.pathSeparator +
          WallpaperFileUtil.WALLPAPER_INFO_FILE_NAME);

      configFile.writeAsStringSync(json.encode(wallpaperConfig));

      await DataCenter.get(context).addWallpaper(wallpaperConfig);
    }
  }

  Future<void> importUrl(BuildContext context, String url) async {
    if (url == null || url.trim().isEmpty) return;
    print('importUrl--------------$url');

    final id = uuid.v1();

    final wallpaperConfig = Wallpaper(
      id: id,
      name: url,
      author: 'Unknown',
      description: 'None',
      mainFilepath: url,
      thumbnails: [],
      versionCode: 1,
      versionName: '1.0',
      wallpaperType: WallpaperType.HTML,
      tags: []
    );

    final targetDir = Directory(
      WallpaperTools.instance.wallpaperPlaceDir.path +
          Platform.pathSeparator +
          wallpaperConfig.id,
    );

    targetDir.createSync();

    final configFile = File(targetDir.path +
        Platform.pathSeparator +
        WallpaperFileUtil.WALLPAPER_INFO_FILE_NAME);

    configFile.writeAsStringSync(json.encode(wallpaperConfig));

    await DataCenter.get(context).addWallpaper(wallpaperConfig);
    print(DataCenter.get(context).wallpapers);
  }

// /// 导入指定目录下的所有视频图片（层级1）
// Future<void> importImageFromDir(BuildContext context,
//     Directory directory) async {
//   if (directory == null || !directory.existsSync()) return;
//
//   final files = directory.listSync();
//   final target = <String>[];
//
//   files.forEach((element) {
//     if (element.path.endsWith('png') || element.path.endsWith('jpg'))
//       target.add(element.path);
//   });
//
//   await for (final itemPath in Stream.fromIterable(target)) {
//     print('importImageFromDir: $itemPath');
//     final item = File(itemPath);
//
//     item.copySync(directory.path +
//         Platform.pathSeparator +
//         FileUtils.basename(itemPath));
//
//     final fileName = FileUtils.basename(itemPath);
//
//     final wallpaperConfig = Wallpaper(
//       id: uuid.v1(),
//       name: fileName,
//       author: 'Unknown',
//       description: 'None',
//       mainFilepath: fileName,
//       thumbnails: [fileName],
//       versionCode: 1,
//       versionName: '1.0',
//       wallpaperType: WallpaperType.IMAGE,
//     );
//
//     final targetDir = Directory(
//       WallpaperTools.instance.wallpaperPlaceDir.path +
//           Platform.pathSeparator +
//           wallpaperConfig.id,
//     );
//
//     targetDir.createSync();
//
//     final configFile = File(targetDir.path +
//         Platform.pathSeparator +
//         WallpaperFileUtil.WALLPAPER_INFO_FILE_NAME);
//
//     configFile.writeAsStringSync(json.encode(wallpaperConfig));
//
//     await DataCenter.get(context).addWallpaper(wallpaperConfig);
//   }
// }
}

extension WallpaperExt on Wallpaper {
  String getMainThumbnailPath() {
    if (thumbnails.isEmpty) return null;
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
    List<String> getAllFilePath(Directory directory) {
      if (directory == null) return [];
      final data = <String>[];
      directory.listSync().forEach((element) {
        final temp = Directory(element.path);
        if (temp.existsSync()) {
          return getAllFilePath(temp);
        } else {
          data.add(element.path);
        }
      });
      return data;
    }

    final dirPath = this.getDirPath();
    final allPath = Directory(dirPath)
        .listSync(recursive: true)
        .map((e) => e.path)
        .toList();

    int len = 0;

    final all = getAllFilePath(Directory(dirPath));

    all.forEach((element) {
      len += File(element).lengthSync();
    });

    return WallpaperExtInfo(dirPath, allPath, len, false);
  }
}
