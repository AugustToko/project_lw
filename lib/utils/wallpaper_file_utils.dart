import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:es_compression/brotli.dart';
import 'package:file_utils/file_utils.dart';
import 'package:project_lw/entity/wallpaper.dart';

class WallpaperFileUtil {
  static const WALLPAPER_INFO_FILE_NAME = 'wallpaper.json';
  static const VIEW_INFO_FILE_NAME = 'view_config.json';
  static const PACK_NAME = 'wallpaper.$SUPPORTED_WALLPAPER_FORMAT';

  static const SUPPORTED_WALLPAPER_FORMAT = 'lwpak';
  static const SUPPORTED_IMAGE_FORMAT = 'webp';
  static const SUPPORTED_VIDEO_FORMAT = 'mp4';
  static const SUPPORTED_HTML_FORMAT = 'html';

  /// 解包 wallpaper pack
  /// [wallpaperFile] 传入的 wallpaper 包
  /// [unpackDir] 解包路径
  static Future<void> unpackWallpaper(
      final File wallpaperFile, final Directory unpackDir) async {
    if (wallpaperFile == null || unpackDir == null)
      throw ArgumentError.notNull('wallpaperFile');
    if (!wallpaperFile.existsSync() || !unpackDir.existsSync())
      throw ArgumentError(
          '!wallpaperFile.existsSync() || !unpackPath.existsSync()');

    final bytes = await wallpaperFile.readAsBytes();

    final result = brotli.decode(bytes);

    final tarDecoder = TarDecoder();
    final archive = tarDecoder.decodeBytes(result);

    await for (final file in Stream.fromIterable(archive.files)) {
      final targetPath = unpackDir.path + Platform.pathSeparator + file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        final f = File(targetPath);
        await f.create(recursive: true);
        await f.writeAsBytes(data);
      } else {
        final dir = Directory(targetPath);
        await dir.create(recursive: true);
      }
    }
  }

  static Wallpaper parseWallpaperPack(final Directory directory) {
    if (!directory.existsSync()) return null;

    final jsonFile = File(
        directory.path + Platform.pathSeparator + WALLPAPER_INFO_FILE_NAME);

    if (!jsonFile.existsSync()) return null;

    final Wallpaper wallpaper =
        Wallpaper.fromJson(json.decode(jsonFile.readAsStringSync()));

    return wallpaper;
  }

  /// 打包 wallpaper pack
  /// [wallpaperSource] 资源路径
  static Future<void> packWallpaper(final Directory wallpaperSource) async {
    if (wallpaperSource == null) throw ArgumentError.notNull('wallpaperFile');
    if (!wallpaperSource.existsSync())
      throw ArgumentError('!wallpaperSource.existsSync()');

    final fileList = wallpaperSource.listSync();

    final tempDir =
        Directory(wallpaperSource.path + Platform.pathSeparator + '.temp');
    tempDir.createSync();

    await for (final element in Stream.fromIterable(fileList)) {
      await element.rename(tempDir.path +
          Platform.pathSeparator +
          FileUtils.basename(element.path));
    }

    final tarEncoder = TarFileEncoder();
    tarEncoder
        .create(wallpaperSource.path + Platform.pathSeparator + 'content.tar');
    tarEncoder.addDirectory(tempDir);

    final fileListNew = tempDir.listSync();

    await for (final element in Stream.fromIterable(fileListNew)) {
      await element.rename(wallpaperSource.path +
          Platform.pathSeparator +
          FileUtils.basename(element.path));
    }

    tempDir.deleteSync();

    final tarFile = File(tarEncoder.tar_path);
    tarEncoder.close();

    final result = brotli.encode(tarFile.readAsBytesSync());

    final pak = File(wallpaperSource.path + Platform.pathSeparator + PACK_NAME);
    if (pak.existsSync()) pak.deleteSync();

    pak.writeAsBytesSync(result);

    tarFile.deleteSync();
  }

  // TODO checkWallpaperConfigFile
  static bool checkWallpaperConfigFile(File file) {
    return true;
  }
}
