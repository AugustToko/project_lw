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
  static const TEMP_TAR_NAME = 'content.tar';
  static const TEMP_FOLDER_NAME = '.temp';

  static const SUPPORTED_WALLPAPER_FORMAT = 'lwpak';
  static const SUPPORTED_IMAGE_FORMAT = 'webp';
  static const SUPPORTED_VIDEO_FORMAT = 'mp4';
  static const SUPPORTED_HTML_FORMAT = 'html';

  /// 解包 wallpaper pack
  /// [wallpaperFile] 传入的 wallpaper 包
  /// [unpackDir] 解包路径
  static Future<void> unpackWallpaper(final File wallpaperFile, final Directory unpackDir) async {
    if (wallpaperFile == null || unpackDir == null) throw ArgumentError.notNull('wallpaperFile');

    if (!wallpaperFile.path.endsWith(SUPPORTED_WALLPAPER_FORMAT)) throw ArgumentError('!wallpaperFile.path.endsWith(SUPPORTED_WALLPAPER_FORMAT)');

    if (!wallpaperFile.existsSync() || !unpackDir.existsSync()) throw ArgumentError('!wallpaperFile.existsSync() || !unpackPath.existsSync()');

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

  static Wallpaper? parseWallpaperPack(final Directory directory) {
    if (!directory.existsSync()) return null;

    final jsonFile = File(directory.path + Platform.pathSeparator + WALLPAPER_INFO_FILE_NAME);

    if (!jsonFile.existsSync()) return null;

    final Wallpaper wallpaper = Wallpaper.fromJson(json.decode(jsonFile.readAsStringSync()) as Map<String, dynamic>);

    return wallpaper;
  }

  /// 打包 wallpaper pack
  /// [wallpaperSource] 资源路径
  static Future<File> packWallpaper(final Directory wallpaperSource) async {
    if (!wallpaperSource.existsSync()) throw ArgumentError('!wallpaperSource.existsSync()');

    final fileList = wallpaperSource.listSync(recursive: true);

    final tempDir = Directory(wallpaperSource.path + Platform.pathSeparator + TEMP_FOLDER_NAME);
    await tempDir.create();

    await for (final element in Stream.fromIterable(fileList)) {
      await element.rename(tempDir.path + Platform.pathSeparator + FileUtils.basename(element.path));
    }

    final tarEncoder = TarFileEncoder();
    tarEncoder.create(wallpaperSource.path + Platform.pathSeparator + TEMP_TAR_NAME);
    tarEncoder.addDirectory(tempDir);

    final fileListNew = tempDir.listSync(recursive: true);

    await for (final element in Stream.fromIterable(fileListNew)) {
      await element.rename(wallpaperSource.path + Platform.pathSeparator + FileUtils.basename(element.path));
    }

    await tempDir.delete();

    final tarFile = File(tarEncoder.tarPath);
    tarEncoder.close();

    final result = brotli.encode(await tarFile.readAsBytes());

    final pak = File(wallpaperSource.path + Platform.pathSeparator + PACK_NAME);
    if (pak.existsSync()) pak.deleteSync();

    pak.writeAsBytesSync(result);

    tarFile.deleteSync();

    return pak;
  }

  static bool checkWallpaperConfigFile(File? file) {
    if (file == null) return false;
    if (!file.existsSync()) return false;
    if (!file.path.contains(WALLPAPER_INFO_FILE_NAME)) return false;

    Wallpaper wallpaper;
    try {
      wallpaper = Wallpaper.fromJson(json.decode(file.readAsStringSync()) as Map<String, dynamic>);
    } catch (e, s) {
      print(e);
      print(s);
      return false;
    }

    for (final value in wallpaper.toMap().values) {
      if (value == null) return false;
    }

    if (wallpaper.id.trim().isEmpty) return false;
    if (wallpaper.mainFilepath.trim().isEmpty) return false;

    return true;
  }
}
