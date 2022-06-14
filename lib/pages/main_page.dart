/*
 * Copyright (C) 2020 ChenLong. All rights reserved.
 *
 * This document is the property of ChenLong.
 * It is considered confidential and proprietary.
 *
 * This document may not be reproduced or transmitted in any form,
 * in whole or in part, without the express written permission of
 * ChenLong.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:project_lw/main.dart';
import 'package:project_lw/pages/library_page.dart';
import 'package:project_lw/utils/lw_theme_utils.dart';
import 'package:project_lw/widget/navbar/navbar.dart';

/// [MainPage]
/// 仅带有一个 BottomNavigationBar
class MainPage extends StatefulWidget {
  static void push(final BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return MainPage._();
      },
    ));
  }

  MainPage._();

  @override
  State<StatefulWidget> createState() {
    return _IndexState();
  }
}

class _IndexState extends State<MainPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _navBarItems = <NavBarItemData>[
    NavBarItemData('内容库', LineAwesomeIcons.home, 110, Color(0xff01b87d)),
    NavBarItemData('社区', LineAwesomeIcons.archive, 110, Color(0xff594ccf)),
    NavBarItemData('设置', LineAwesomeIcons.user, 105, Color(0xfff2873f)),
  ];

  final pages = <Widget>[
    LibraryPage(),
    Container(),
    Container(),
  ];

  int _selectedNavIndex = 0;

  var exitApp = false;

  late AnimationController mainAnimationCtl = AnimationController(duration: const Duration(milliseconds: 450), vsync: this);

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this); // 注册监听器

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setSystemUIOverlayStyle(LWThemeUtil.getSystemStyle(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (FocusManager.instance.primaryFocus?.hasFocus ?? false) {
          FocusManager.instance.primaryFocus?.unfocus();
          return false;
        }

        methodChannel.invokeMethod('backHome');
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: LWThemeUtil.getSystemStyle(context),
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            body: Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.topCenter,
                    child: IndexedStack(
                      index: _selectedNavIndex,
                      children: pages,
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: NavBar(
                    items: _navBarItems,
                    itemTapped: _handleNavBtnTapped,
                    currentIndex: _selectedNavIndex,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavBtnTapped(int index) {
    if (!mounted) return;

    Vibrate.feedback(FeedbackType.light);

    if (index == _selectedNavIndex) return;

    mainAnimationCtl.reverse().then((data) {
      setState(() {
        _selectedNavIndex = index;
      });
    });
  }
}
