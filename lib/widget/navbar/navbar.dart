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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'navbar_button.dart';

class NavBar extends StatelessWidget {
  final ValueChanged<int> itemTapped;
  final int currentIndex;
  final List<NavBarItemData> items;

  NavBar({this.items, this.itemTapped, this.currentIndex = 0});

  NavBarItemData get selectedItem =>
      currentIndex >= 0 && currentIndex < items.length
          ? items[currentIndex]
          : null;

  @override
  Widget build(BuildContext context) {
    //For each item in our list of data, create a NavBtn widget
    List<Widget> buttonWidgets = items.map((data) {
      //Create a button, and add the onTap listener
      return NavBarButton(data, data == selectedItem, onTap: () {
        //Get the index for the clicked data
        var index = items.indexOf(data);
        //Notify any listeners that we've been tapped, we rely on a parent widget to change our selectedIndex and redraw
        itemTapped(index);
      });
    }).toList();

    final body = Container(
      height: 65,
      decoration: BoxDecoration(
        // navBar 背景颜色
        color: Theme.of(context)
            .scaffoldBackgroundColor
            .withOpacity(0.8),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: buttonWidgets,
        ),
      ),
    );

    // 创建一个包含一行的容器，然后将btn小部件添加到该行中
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 32,
            offset: Offset(0, -20))
      ]),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 32, sigmaY: 32),
          child: body,
        ),
      ),
    );
  }
}

class NavBarItemData {
  final String title;
  final IconData icon;
  final Color selectedColor;
  final double width;

  NavBarItemData(this.title, this.icon, this.width, this.selectedColor);
}
