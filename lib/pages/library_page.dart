import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/loading_dialog.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:project_lw/entity/center/data_center.dart';
import 'package:project_lw/entity/wallpaper.dart';
import 'package:project_lw/pages/wallpaper_detail_page.dart';
import 'package:project_lw/utils/lw_theme_utils.dart';
import 'package:project_lw/utils/sheet_utils.dart';
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: LWThemeUtil.navBarHeight),
        child: FloatingActionButton.extended(
          elevation: 0,
          onPressed: () async {
            await SheetUtils.showSheetNoAPNoBlurCommon(
                context,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles();

                        if (result == null || result.files.single.path == null) return;
                        final file = File(result.files.single.path!);

                        await WallpaperTools.instance
                            .importWallpaper(context, file);
                      },
                      leading: const Icon(Icons.move_to_inbox_rounded),
                      title: const Text('导入文件'),
                      subtitle: const Text('导入 lwpak 壁纸文件'),
                    ),
                    ListTile(
                      title: Text('导入 URL'),
                      leading: Icon(Icons.web_asset),
                      subtitle: Text('导入一个网站'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final ctl = TextEditingController();
                            return AlertDialog(
                              title: Text('添加一个 URL'),
                              content: SizedBox(
                                width: 300,
                                child: TextField(
                                  controller: ctl,
                                  decoration:
                                      InputDecoration(hintText: '请输入 URL'),
                                ),
                              ),
                              actions: [
                                FlatButton(
                                    onPressed: () async {
                                      await WallpaperTools.instance
                                          .importUrl(context, ctl.text);
                                    },
                                    child: Text('添加'))
                              ],
                            );
                          },
                        );
                      },
                    ),
                    ListTile(
                      title: Text('导入图片'),
                      leading: Icon(Icons.image),
                      subtitle: Text('导入静态图片作为壁纸'),
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                            type: FileType.image, allowMultiple: true);

                        if (result == null) return;

                        DialogUtil.showBlurDialog(
                            context, (context) => LoadingDialog(text: '正在加载'));

                        for (final file in result.files) {
                          if (file.path == null) {
                            showMyToast('file.path == null');
                          }
                        }

                        await WallpaperTools.instance.importImage(
                            context, result.files.map((e) => e.path).toList());

                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                            type: FileType.video, allowMultiple: true);

                        if (result == null) return;

                        DialogUtil.showBlurDialog(
                            context, (context) => LoadingDialog(text: '正在加载'));

                        await WallpaperTools.instance.importVideo(
                            context, result.files.map((e) => e.path).toList());
                        Navigator.pop(context);
                      },
                      title: const Text('导入视频'),
                      leading: const Icon(Icons.movie_creation_outlined),
                      subtitle: const Text('导入视频作为壁纸'),
                    ),
                    // const ListTile(
                    //   title: Text('导入文件夹-壁纸包'),
                    //   leading: Icon(Icons.all_inbox_rounded),
                    //   subtitle: Text('导入指定文件夹下的 lwpak 文件'),
                    //   enabled: false,
                    // ),
                  ],
                ));
          },
          label: const Text('导入'),
          icon: const Icon(Icons.add),
        ),
      ),
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
                        const CupertinoContextMenuAction(
                          child: Text('喜爱'),
                          trailingIcon: Icons.favorite,
                        ),
                        const CupertinoContextMenuAction(
                          child: Text('分享'),
                          trailingIcon: Icons.ios_share,
                          onPressed: null,
                        ),
                        CupertinoContextMenuAction(
                          child: Text('删除'),
                          trailingIcon: Icons.delete,
                          onPressed: () {
                            WallpaperTools.instance
                                .removeWallpaper(context, wallpaper);
                            Navigator.pop(context);
                          },
                        )
                      ],
                      child: Stack(
                        children: [
                          Hero(
                            tag: 'image_${wallpaper.id}',
                            child: Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: wallpaper.getMainThumbnailPath() == null
                                  ? const SizedBox(
                                      width: 300,
                                      height: 300,
                                    )
                                  : Image.file(
                                      File(wallpaper.getMainThumbnailPath()!),
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
                                          borderRadius:
                                              const BorderRadius.vertical(
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
