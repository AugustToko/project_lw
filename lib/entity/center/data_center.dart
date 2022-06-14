import 'package:flutter/material.dart';
import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/utils/data_base_helper.dart';
import 'package:provider/provider.dart';

class DataCenter extends ChangeNotifier {
  static DataCenter get(BuildContext context) {
    return Provider.of<DataCenter>(context, listen: false);
  }

  Future<void> init() async {
    await DataBaseHelper.instance.init();

    final tempData = await DataBaseHelper.instance.db.query(Wallpaper.TABLE);
    tempData.forEach((element) {
      print('-------INIT-------\n$element');
      _wallpapers.add(Wallpaper.fromMap(element));
    });
  }

  var _wallpapers = <Wallpaper>[];

  List<Wallpaper> get wallpapers => _wallpapers;

  set wallpapers(List<Wallpaper> value) {
    _wallpapers = value;
    notifyListeners();
  }

  Future<void> addWallpaper(final Wallpaper? wallpaper) async {
    if (wallpaper == null || wallpaper.id == null || wallpaper.id.trim().isEmpty) return;

    _wallpapers = []
      ..addAll(_wallpapers)
      ..add(wallpaper);

    notifyListeners();

    await DataBaseHelper.instance.db.insert(Wallpaper.TABLE, wallpaper.toMap());
  }

  Future<void> removeWallpaper(Wallpaper wallpaper) async {
    if (wallpaper == null || wallpaper.id == null || wallpaper.id.trim().isEmpty) return;

    _wallpapers = []
      ..addAll(_wallpapers)
      ..removeWhere((element) => element.id == wallpaper.id);

    notifyListeners();

    await DataBaseHelper.instance.db.delete(Wallpaper.TABLE, where: 'id = ?', whereArgs: [wallpaper.id]);
  }
}
