import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_lw/entity/center/data_center.dart';
import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/pages/wallpaper_detail_page.dart';
import 'package:project_lw/utils/lw_theme_utils.dart';
import 'package:project_lw/utils/wallpaper_tools.dart';
import 'package:provider/provider.dart';

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
                    const SizedBox(height: 8),
                    Selector<DataCenter, List<Wallpaper>>(
                      builder: (_, val, child) {
                        return Text('${val.length}张壁纸');
                      },
                      selector: (_, foo) => foo.wallpapers,
                    ),
                  ],
                ),
              ),
            ),
            Selector<DataCenter, List<Wallpaper>>(
              builder: (_, val, child) {
                return SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  itemCount: val.length,
                  itemBuilder: (context, index) {
                    final wallpaper = val[index];

                    return CupertinoContextMenu(
                      actions: [
                        CupertinoContextMenuAction(child: Text('Fav')),
                        CupertinoContextMenuAction(child: Text('Del'))
                      ],
                      child: Stack(
                        children: [
                          Hero(
                            tag: 'image_${wallpaper.id}',
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.file(
                                File(wallpaper.getMainThumbnailPath()),
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Hero(
                                  tag: 'info_${wallpaper.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      height: 80,
                                      alignment: Alignment.centerLeft,
                                      width: double.infinity,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(16))),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('${wallpaper.mainFilepath}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2),
                                          Text(
                                            '${wallpaper.wallpaperType}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  WallpaperDetailPage.push(context, wallpaper);
                                },
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                    return Stack(
                      children: [
                        Container(
                            clipBehavior: Clip.antiAlias,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: FileImage(
                                  File(wallpaper.getMainThumbnailPath()),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 180),
                                Container(
                                  width: double.infinity,
                                  color: Colors.white.withOpacity(0.8),
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${wallpaper.mainFilepath}'),
                                      Text(
                                        '${wallpaper.id}',
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      ),
                                      Text(
                                        '${wallpaper.wallpaperType}',
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                WallpaperDetailPage.push(context, wallpaper);
                                // await SharedPreferenceUtil.setString(
                                //     SpfKeys.LAST_WALLPAPER,
                                //     json.encode(wallpaper));
                                // NativeTool.setWallpaper(wallpaper);
                              },
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                );
              },
              selector: (_, foo) => foo.wallpapers,
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
