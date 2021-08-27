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

import 'dart:core';

import 'package:flutter/material.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:project_lw/widget/navbar/rotation_3d.dart';

import 'clipped_view.dart';
import 'navbar.dart';

// Handle the transition between selected and de-deselected, by animating it's own width,
// and modifying the color/visibility of some child widgets
class NavBarButton extends StatefulWidget {
  final NavBarItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarButton(this.data, this.isSelected, {required this.onTap});

  @override
  _NavBarButtonState createState() => _NavBarButtonState();
}

class _NavBarButtonState extends State<NavBarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimController;
  bool? _wasSelected;
  double _animScale = 1;

  @override
  void initState() {
    //Create a tween + controller which will drive the icon rotation
    int duration = (350 / _animScale).round();
    _iconAnimController = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );
    Tween<double>(begin: 0, end: 1).animate(_iconAnimController)
      //Listen for tween updates, and rebuild the widget tree on each tick
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _startAnimIfSelectedChanged(widget.isSelected);
    // Create our main button, a Row, with an icon and some text
    // Inject the data from our widget.data property
    var content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        //Rotate the icon using the current animation value
        Rotation3d(
          rotationY: 180 * _iconAnimController.value,
          child: Icon(
            widget.data.icon,
            size: 24,
            color: widget.isSelected ? Colors.white : Colors.grey,
          ),
        ),
        //Add some hz spacing
        const SizedBox(width: 12),
        //Label
        SizedBox(
          width: 60,
          child: MarqueeText(
            speed: 20,
            text: widget.data.title,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );

    var paddingV = 8.0;
    var paddingH = 4.0;

//    Wrap btn in GestureDetector so we can listen to taps
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              top: paddingV, bottom: paddingV, right: paddingH, left: paddingH),
          //Wrap in an animated container, so changes to width & color automatically animate into place
          child: AnimatedContainer(
            alignment: Alignment.center,
            //Determine target width, selected item is wider
            width: widget.isSelected ? widget.data.width : 56,
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(12),
            duration: Duration(milliseconds: (700 / _animScale).round()),
            //Use BoxDecoration top create a rounded container
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                gradient: LinearGradient(colors: [
                  widget.isSelected
                      ? widget.data.selectedColor
                      : Theme.of(context).backgroundColor,
                  widget.isSelected
                      ? widget.data.selectedColor.withOpacity(0.5)
                      : Theme.of(context).backgroundColor
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            //Wrap the row in a ClippedView to suppress any overflow errors if we momentarily exceed the screen size
            child: ClippedView(child: content),
          ),
        ),
        // 修复点击水波
        Positioned.fill(
          bottom: paddingV,
          top: paddingV,
          left: paddingH,
          right: paddingH,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _startAnimIfSelectedChanged(bool isSelected) {
    if (_wasSelected != widget.isSelected) {
      //Go forward or reverse, depending on the isSelected state
      widget.isSelected
          ? _iconAnimController.forward()
          : _iconAnimController.reverse();
    }
    _wasSelected = widget.isSelected;
  }
}
