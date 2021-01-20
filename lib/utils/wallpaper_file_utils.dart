import 'dart:io';
import 'package:archive/archive.dart';
import 'package:es_compression/brotli.dart';
import 'package:file_utils/file_utils.dart';

class WallpaperFileUtil {
  static const WALLPAPER_INFO_FILE_NAME = 'wallpaper.json';
  static const VIEW_INFO_FILE_NAME = 'view_config.json';

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

    // final tarArchiveFile = File('${unpackDir.path}${Platform.pathSeparator}content.tar');
    // if (tarArchiveFile.existsSync()) tarArchiveFile.deleteSync();
    // tarArchiveFile.createSync();
    // tarArchiveFile.writeAsBytes(result);
  }

  /// 打包 wallpaper pack
  /// [wallpaperSource] 资源路径
  /// [destFilePath] 打包文件路径
  static void packWallpaper(
      final Directory wallpaperSource, final String destFilePath) {
    if (wallpaperSource == null || destFilePath == null)
      throw ArgumentError.notNull('wallpaperFile');
    if (!wallpaperSource.existsSync())
      throw ArgumentError('!wallpaperSource.existsSync()');

    final tarEncoder = TarEncoder();

    final archive = Archive();

    // archive.addFile(ArchiveFile)
    //
    // wallpaperSource.listSync().forEach((element) {
    //   archive.addFile(ArchiveFile(FileUtils.basename(element.path), element.statSync().size, content));
    // });

  }
}
