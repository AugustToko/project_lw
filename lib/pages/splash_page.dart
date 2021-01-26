import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_lw/entity/center/data_center.dart';
import 'package:project_lw/pages/main_page.dart';
import 'package:project_lw/utils/shared_prefs.dart';
import 'package:project_lw/utils/spf_keys.dart';
import 'package:project_lw/utils/wallpaper_tools.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashPage extends StatefulWidget {
  static void push(final BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return SplashPage._();
      },
    ));
  }

  static SplashPage buildMe() {
    return SplashPage._();
  }

  SplashPage._();

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _valueNotifier = ValueNotifier('正在进入...');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {

      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.camera,
        Permission.microphone,
        Permission.storage,
      ].request();

      _valueNotifier.value = '正在初始化数据库';
      await DataCenter.get(context).init();

      _valueNotifier.value = '正在获取配置文件';
      final isFirst =
          (await SharedPreferenceUtil.getBool(SpfKeys.FIRST)) ?? true;

      await WallpaperTools.instance.init();

      if (isFirst) {
        _valueNotifier.value = '正在初始化第一次进入的资源';
        await SharedPreferenceUtil.setBool(SpfKeys.FIRST, false);

        await WallpaperTools.instance.initPresetWallpaper(context);
      }

      _valueNotifier.value = '初始化资源完成';

      MainPage.push(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ValueListenableBuilder<String>(
          valueListenable: _valueNotifier,
          builder: (context, value, child) {
            return Text(value ?? '正在加载...');
          },
        ),
      ),
    );
  }
}
