import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_lw/entity/center/data_center.dart';
import 'package:project_lw/pages/splash_page.dart';
import 'package:project_lw/utils/wallpaper_tools.dart';
import 'package:provider/provider.dart';

final methodChannel = MethodChannel('lingyun_lw_channel_1');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  if (kReleaseMode) GestureBinding.instance.resamplingEnabled = true;

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DataCenter>(create: (_) => DataCenter())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  final lightTheme = ThemeData.light().copyWith(
      accentColor: Colors.lightBlueAccent,
      backgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSwatch(),
      scaffoldBackgroundColor: Color.fromARGB(255, 248, 249, 251),
      cardTheme: ThemeData.light().cardTheme.copyWith(color: Colors.white),
      popupMenuTheme: PopupMenuThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      // textTheme: ThemeData.light().textTheme.copyWith(
      //     headline3: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       letterSpacing: .3,
      //     ),
      //     headline4: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       letterSpacing: .3,
      //     ),
      //     headline5: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       fontSize: 26,
      //       letterSpacing: .3,
      //     ),
      //     headline6: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       letterSpacing: .3,
      //     ),
      //     caption: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       fontSize: 13,
      //       letterSpacing: .3,
      //     ),
      //     button: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       letterSpacing: .3,
      //     ),
      //     bodyText1: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       letterSpacing: .3,
      //     ),
      //     bodyText2: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       letterSpacing: .3,
      //     ),
      //     subtitle1: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       letterSpacing: .3,
      //     ),
      //     subtitle2: GoogleFonts.quicksand(
      //       color: Color.fromARGB(255, 70, 76, 83),
      //       letterSpacing: .3,
      //     )),
      // primaryTextTheme: ThemeData.light().primaryTextTheme.copyWith(
      //       headline6: GoogleFonts.quicksand(
      //         letterSpacing: .3,
      //       ),
      //     ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));

  final darkTheme = ThemeData.dark().copyWith(
      accentColor: Colors.lightBlueAccent,
      backgroundColor: Color.fromARGB(255, 14, 18, 27),
      scaffoldBackgroundColor: Color.fromARGB(255, 14, 18, 27),
      colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark),
      cardTheme: ThemeData.dark()
          .cardTheme
          .copyWith(color: Color.fromARGB(255, 24, 28, 37)),
      popupMenuTheme: PopupMenuThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      // textTheme: ThemeData.dark().textTheme.copyWith(
      //     headline3: GoogleFonts.quicksand(
      //       color: Colors.white,
      //       letterSpacing: .3,
      //     ),
      //     headline4: GoogleFonts.quicksand(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //       letterSpacing: .3,
      //     ),
      //     headline5: GoogleFonts.quicksand(
      //       fontWeight: FontWeight.w400,
      //       color: Colors.white,
      //       fontSize: 26,
      //       letterSpacing: .3,
      //     ),
      //     headline6: GoogleFonts.quicksand(
      //       fontWeight: FontWeight.w400,
      //       color: Colors.white,
      //       letterSpacing: .3,
      //     ),
      //     caption: GoogleFonts.quicksand(
      //       fontWeight: FontWeight.w400,
      //       color: ThemeData.dark().textTheme.caption.color,
      //       fontSize: 13,
      //       letterSpacing: .3,
      //     ),
      //     button: GoogleFonts.quicksand(
      //       color: ThemeData.dark().textTheme.button.color,
      //       fontWeight: FontWeight.w500,
      //       letterSpacing: .3,
      //     ),
      //     bodyText1: GoogleFonts.quicksand(
      //       fontWeight: FontWeight.w500,
      //       color: ThemeData.dark().textTheme.bodyText1.color,
      //       letterSpacing: .3,
      //     ),
      //     bodyText2: GoogleFonts.quicksand(
      //       fontWeight: FontWeight.w400,
      //       color: ThemeData.dark().textTheme.bodyText2.color,
      //       letterSpacing: .3,
      //     ),
      //     subtitle1: GoogleFonts.quicksand(
      //       fontWeight: FontWeight.bold,
      //       color: ThemeData.dark().textTheme.subtitle1.color,
      //       letterSpacing: .3,
      //     ),
      //     subtitle2: GoogleFonts.quicksand(
      //       fontWeight: FontWeight.w600,
      //       color: ThemeData.dark().textTheme.subtitle2.color,
      //       letterSpacing: .3,
      //     )),
      // primaryTextTheme: ThemeData.dark().primaryTextTheme.copyWith(
      //       headline6: GoogleFonts.quicksand(
      //         fontWeight: FontWeight.w500,
      //         letterSpacing: .3,
      //       ),
      //     ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: SplashPage.buildMe(),
    );
  }
}
