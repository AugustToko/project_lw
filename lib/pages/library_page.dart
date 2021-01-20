import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_lw/misc/const.dart';
import 'package:project_lw/utils/lw_theme_utils.dart';
import 'package:project_lw/utils/native_tools.dart';
import 'package:project_lw/utils/shared_prefs.dart';
import 'package:project_lw/utils/spf_keys.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: LWThemeUtil.pageTitlePadding,
              child: Text(
                '内容库',
                style: LWThemeUtil.pageTitleStyle(context),
              ),
            ),
          ),
          SliverStaggeredGrid.countBuilder(
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            itemCount: defaultHtmlList.length,
            itemBuilder: (context, index) {
              final wallpaper = defaultHtmlList[index];
              return InkWell(
                onTap: () async {
                  await SharedPreferenceUtil.setString(
                      SpfKeys.LAST_WALLPAPER, json.encode(wallpaper));
                  NativeTool.setWallpaper(wallpaper);
                },
                child: Container(
                    color: Colors.green,
                    child: Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text('asd'),
                          ),
                          Text('${wallpaper.path}')
                        ],
                      ),
                    )),
              );
            },
            staggeredTileBuilder: (index) => StaggeredTile.count(1, 1),
          ),
        ],
      ),
    );
  }
}
