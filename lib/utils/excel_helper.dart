import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlitetoexcel/sqlitetoexcel.dart';

class ExcelHelper {
  Future<String> exportSingleTable() async {
    var excludes = new List();
    var dbPath, dir;
    var prettify = new Map<dynamic, dynamic>();
    var finalpath = "";

    // Exclude column(s) from being exported
    excludes.add("id");

    // Prettifies columns name
    prettify["name"] = "Name";

    // Table name that will be exported
    var tableName = "local_user_table";

    final directory = await getExternalStorageDirectory();
    var path = directory.path;
    path = directory.path;
    dbPath = join(directory.path, 'users.db');
    print(dbPath);
    dir = path + "/";

    try {
      finalpath = await Sqlitetoexcel.exportSingleTable(
          dbPath, "downloads", "", "users.xls", tableName, excludes, prettify);
    } on PlatformException catch (e) {
      print(e.message.toString());
    }
    return finalpath;
  }
}
