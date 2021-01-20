import 'package:project_lw/entity/wallpaper.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  static DataBaseHelper instance = DataBaseHelper._();

  DataBaseHelper._();

  Database db;

  Future<void> init() async {
    db = await openDatabase('database.db', version: 1,
        onCreate: (database, version) async {
      var batch = database.batch();
      batch.execute(Wallpaper.CREATE_TABLE);
      await batch.commit();
    }, onUpgrade: (database, oldVersion, newVersion) async {
      var batch = database.batch();
      for (var i = oldVersion; i < newVersion; i++) {
        print('========================== DB VERSION ==========================');
        print(i);
        // switch (i) {
        //   case 1:
        //     batch.execute('ALTER TABLE ${EventData.TABLE} ADD COLUMN isComplete INTEGER');
        //     break;
        // }
      }
      await batch.commit();
    });
  }
}
