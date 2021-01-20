import 'dart:convert';

import 'package:project_lw/entity/wallpaper.dart';

void main() {
  print(json.encode(Wallpaper.all(
      '1',
      WallpaperType.HTML,
      'TEST1',
      'description',
      'author',
      ['asd', 'asdasd'],
      1,
      'Fuck',
      'http://fff.cmiscm.com/#!/section/cylinder')));
}
