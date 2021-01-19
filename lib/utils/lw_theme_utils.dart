import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@Deprecated('抽出')
class LWThemeUtil {
  static SystemUiOverlayStyle getSystemStyle(BuildContext context) {
    return SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Theme.of(context).backgroundColor,
      systemNavigationBarIconBrightness:
      Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      statusBarColor: Colors.transparent,
/*        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark*/
    );
  }
}