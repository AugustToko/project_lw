import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_lw/entity/wallpaper.dart';
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
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final wallpaper = widget.wallpaper;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Hero(
                tag: 'image_${widget.wallpaper.id}',
                child: Image.file(
                  File(widget.wallpaper.getMainThumbnailPath()),
                  // height: h,
                  fit: BoxFit.cover,
                )),
          ),
          // Positioned.fill(
          //   child: Hero(
          //     tag: 'info_${widget.wallpaper.id}',
          //     child: Align(
          //       alignment: Alignment.bottomCenter,
          //       child: Material(
          //         color: Colors.transparent,
          //         child: Container(
          //           height: 80,
          //           width: double.infinity,
          //           color: Colors.white.withOpacity(0.8),
          //           padding: const EdgeInsets.all(12),
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text('${widget.wallpaper.path}'),
          //               Text(
          //                 '${widget.wallpaper.wallpaperType}',
          //                 style: Theme.of(context).textTheme.caption,
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: h - 80)),
                SliverToBoxAdapter(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 16,
                        sigmaY: 16,
                      ),
                      child: Column(
                        children: [
                          Hero(
                            tag: 'info_${wallpaper.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${wallpaper.path}'),
                                      Text(
                                        '${wallpaper.wallpaperType}',
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.white.withOpacity(0.8),
                            child: Column(
                              children: [
                                const Divider(),
                                ...List.generate(
                                  100,
                                  (index) {
                                    return ListTile(
                                      title: Text('$index'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
