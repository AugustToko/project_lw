import 'package:flutter/material.dart';
import 'package:project_lw/utils/data_base_helper.dart';
import 'package:provider/provider.dart';

class DataCenter  extends ChangeNotifier {
  static DataCenter get(BuildContext context) {
    return Provider.of<DataCenter>(context, listen: false);
  }

  Future<void> init() async {
    await DataBaseHelper.instance.init();
  }
}