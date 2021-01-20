import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@Deprecated('抽出')
class LWThemeUtil {
  static const double pageTitleTopPadding = 50;
  static const EdgeInsets pageTitlePadding =
      const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 30);
  static const double navBarHeight = 65;

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

  static TextStyle pageTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.headline4.copyWith(
          color: Theme.of(context).brightness == Brightness.light
              ? Color.fromARGB(255, 49, 55, 63)
              : Colors.white,
          fontWeight: FontWeight.w500);
}
