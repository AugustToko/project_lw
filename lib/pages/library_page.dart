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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: LWThemeUtil.pageTitleTopPadding, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '内容库',
                      style: LWThemeUtil.pageTitleStyle(context),
                    ),
                    Text('120张')
                  ],
                ),
              ),
            ),
            SliverStaggeredGrid.countBuilder(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              itemCount: DEFAULT_WALLPAPER_LIST.length,
              itemBuilder: (context, index) {
                final wallpaper = DEFAULT_WALLPAPER_LIST[index];
                return Stack(
                  children: [
                    Container(
                        clipBehavior: Clip.antiAlias,
                        height: (index + 1) * 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Text('asd'),
                              ),
                              Text('${wallpaper.path}')
                            ],
                          ),
                        )),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await SharedPreferenceUtil.setString(
                                SpfKeys.LAST_WALLPAPER, json.encode(wallpaper));
                            NativeTool.setWallpaper(wallpaper);
                          },
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )
                  ],
                );
              },
              staggeredTileBuilder: (index) => StaggeredTile.fit(1),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: LWThemeUtil.navBarHeight),
            )
          ],
        ),
      ),
    );
  }
}
