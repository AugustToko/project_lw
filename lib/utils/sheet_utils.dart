import 'package:flutter/material.dart';

class SheetUtils {
  static Future<T?> showSheetNoAPNoBlurCommon<T>(
    BuildContext context,
    final Widget child, {
    bool cancelable = true,
  }) {
    return showModalBottomSheet<T>(
        context: context,
        isDismissible: cancelable,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
        builder: (ctx) {
          return Material(
              color: Theme.of(ctx).scaffoldBackgroundColor, child: child);
        });
  }
}
