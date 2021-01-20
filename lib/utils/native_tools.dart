import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/main.dart';

class NativeTool {
  static void setWallpaper(final Wallpaper wallpaper) {
    methodChannel.invokeMethod('SET_WALLPAPER', {
      'wallpaper': wallpaper.toMap(),
    });
  }

  static void clearWallpaper() {
    methodChannel.invokeMethod('CLEAR_WALLPAPER');
  }

  static void gotoLiveWallpaperSettings() {
    methodChannel.invokeMethod('GOTO_WALLPAPER_CHOOSER');
  }
}
