import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/entity/wallpaper_info.dart';
import 'package:project_lw/utils/native_tools.dart';
import 'package:project_lw/utils/shared_prefs.dart';
import 'package:project_lw/utils/spf_keys.dart';
import 'package:project_lw/utils/wallpaper_tools.dart';

class WallpaperDetailPage extends StatefulWidget {
  static void push(BuildContext context, Wallpaper wallpaper) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return WallpaperDetailPage._(wallpaper);
      },
    ));
  }

  WallpaperDetailPage._(this.wallpaper) : assert(wallpaper != null);

  final Wallpaper wallpaper;

  @override
  _WallpaperDetailPageState createState() => _WallpaperDetailPageState();
}

class _WallpaperDetailPageState extends State<WallpaperDetailPage> {
  static const OPACITY = 0.88;
  final backgroundColor = Colors.white.withOpacity(OPACITY);

  final scrollCtl = ScrollController();

  final _valueNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final wallpaper = widget.wallpaper;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // print((notification.metrics.pixels / 20).clamp(0, 32.0));
        _valueNotifier.value = notification.metrics.pixels;
        return true;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          elevation: 0,
          onPressed: () async {
            await SharedPreferenceUtil.setString(SpfKeys.LAST_WALLPAPER, json.encode(wallpaper));
            NativeTool.setWallpaper(wallpaper);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        body: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                itemBuilder: (context, index) {
                  return Hero(
                      tag: 'image_${widget.wallpaper.id}',
                      child: Image.file(
                        File(wallpaper.getAllThumbnailPath()![index]),
                        // height: h,
                        fit: BoxFit.cover,
                      ));
                },
                itemCount: wallpaper.thumbnails?.length ?? 0,
              ),
            ),
            Positioned.fill(
              child: ClipRect(
                child: ValueListenableBuilder<double>(
                  valueListenable: _valueNotifier,
                  builder: (context, value, child) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaY: (value / 20).clamp(0, 32.0).toDouble(), sigmaX: (value / 20).clamp(0, 32.0).toDouble()),
                      child: Container(
                        color: Colors.white.withOpacity(0),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: CustomScrollView(
                // physics: const BouncingScrollPhysics(),
                controller: scrollCtl,
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: h - 80)),
                  SliverToBoxAdapter(
                    child: Hero(
                      tag: 'info_${wallpaper.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          height: 80,
                          color: backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${wallpaper.mainFilepath}'),
                                Text(
                                  '${wallpaper.wallpaperType}',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Material(
                      color: backgroundColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          buildTitle('描述'),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('${wallpaper.description}'),
                          ),
                          const Divider()
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Material(
                      color: backgroundColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          buildTitle('预览图'),
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...List.generate(wallpaper.thumbnails?.length ?? 0, (index) {
                                  return Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    width: 200,
                                    height: 200,
                                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    child: Image.file(
                                      File(wallpaper.getAllThumbnailPath()![index]),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                })
                              ],
                            ),
                          ),
                          // const Divider()
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Material(
                      color: backgroundColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          buildTitle('信息'),
                          FutureBuilder<WallpaperExtInfo>(
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return CircularProgressIndicator();

                              final data = snapshot.data;
                              if (data == null) return Text('NULL');

                              return Column(
                                children: [
                                  ListTile(
                                    title: Text('作者'),
                                    subtitle: Text(wallpaper.author),
                                  ),
                                  ListTile(
                                    title: Text('壁纸类型'),
                                    subtitle: Text('${wallpaper.wallpaperType.name()}'),
                                  ),
                                  ListTile(
                                    title: Text('版本信息'),
                                    subtitle: Text('${wallpaper.versionCode} - ${wallpaper.versionName}'),
                                  ),
                                  ListTile(
                                    title: Text('路径'),
                                    subtitle: Text(data.filePath),
                                  ),
                                  ExpansionTile(
                                    title: Text('所有文件路径'),
                                    children: [
                                      ...List.generate(
                                        data.allPath.length,
                                        (index) => ListTile(
                                          title: Text(data.allPath[index]),
                                          dense: true,
                                        ),
                                      )
                                    ],
                                  ),
                                  ListTile(
                                    title: Text('大小'),
                                    subtitle: Text('${(data.size / 1024 / 1024).round()} MB'),
                                  ),
                                  ListTile(
                                    title: Text('验证信息'),
                                    subtitle: Text(data.verification ? '已验证' : '未验证'),
                                    trailing: IconButton(
                                      icon: data.verification ? Icon(Icons.check_circle) : Icon(Icons.error),
                                      onPressed: () {
                                        // ...
                                      },
                                      color: data.verification ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              );
                            },
                            initialData: null,
                            future: wallpaper.extInfo(),
                          ),
                          // const Divider(),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Material(
                      color: backgroundColor,
                      child: ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          FlatButton.icon(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('请稍后'),
                                    );
                                  },
                                  barrierDismissible: false);
                              await WallpaperTools.instance.shareWallpaper(wallpaper);

                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.ios_share),
                            label: Text('分享'),
                            textColor: Colors.blueAccent,
                          ),
                          FlatButton.icon(
                            onPressed: () {
                              WallpaperTools.instance.removeWallpaper(context, wallpaper);
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.delete),
                            label: Text('删除'),
                            textColor: Colors.redAccent,
                          )
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      child: SizedBox(height: 100),
                      color: backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(final String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '$title',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
