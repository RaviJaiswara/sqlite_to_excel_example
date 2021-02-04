import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlitetoexcel_example/models/user.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String userTable = 'user_table';
  String localUserTable = 'local_user_table';
  String colId = 'id';
  String colName = 'name';
  String colMobileNumber = 'mobile_number';
  String colAmount = 'amount';
  String colProductType = 'product_type';
  String colAmountType = 'amount_type';
  String colDate = 'date';
  String colImagePath = 'image_path';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }
/* 
  Future<Database> get localdatabase async {
    if (_database == null) {
      _database = await initializeLocalDatabase();
    }
    return _database;
  } */

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getExternalStorageDirectory();
    String path = join(directory.path, 'users.db');

    // Open/create the database at a given path
    var usersDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);

    return usersDatabase;
  }

  /*  Future<Database> initializeLocalDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getExternalStorageDirectory();
    String pathToExcel = join(directory.path, 'localusers.db');

    // Open/create the database at a given path
    var localUsersDatabase =
        await openDatabase(pathToExcel, version: 1, onCreate: _createDb);
    return localUsersDatabase;
  } */

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $userTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, '
        '$colMobileNumber TEXT, $colImagePath TEXT, $colAmount TEXT, $colProductType INTEGER, $colAmountType INTEGER, $colDate DATETIME)');
    await db.execute(
        'CREATE TABLE $localUserTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, '
        '$colMobileNumber TEXT, $colImagePath TEXT, $colAmount TEXT, $colProductType INTEGER, $colAmountType INTEGER, $colDate DATETIME)');
  }

  // Fetch Operation: Get all user objects from database
  Future<List<Map<String, dynamic>>> getUserMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $userTable order by $colPriority ASC');
    var result = await db.query(userTable, orderBy: '$colProductType ASC');
    return result;
  }

  // Insert Operation: Insert a User object to database
  Future<int> insertUser(User user) async {
    Database db = await this.database;
    var result = await db.insert(userTable, user.toMap());
    return result;
  }

  // Insert Operation: Insert a local User object to database
  Future<int> insertLocalUser(User user) async {
    Database db = await this.database;
    var result = await db.insert(localUserTable, user.toMap());

    return result;
  }

  // Update Operation: Update a User object and save it to database
  Future<int> updateUser(User user) async {
    var db = await this.database;
    var result = await db.update(userTable, user.toMap(),
        where: '$colId = ?', whereArgs: [user.id]);
    return result;
  }

  // Delete Operation: Delete a User object from database
  Future<int> deleteUser(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $userTable WHERE $colId = $id');
    return result;
  }

  // Delete Operation: Delete a local User object from database
  Future<int> deleteLocalUser() async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $localUserTable');
    return result;
  }

  // Delete Operation: Delete a User object from database
  Future<List<User>> getUserBetweenDate(
      String startDate, String endDate) async {
    print('SELECT * FROM $userTable WHERE $colDate BETWEEN ' +
        startDate +
        ' AND ' +
        endDate +
        '');
    var db = await this.database;
    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM $userTable WHERE $colDate BETWEEN "' +
            startDate +
            '" AND "' +
            endDate +
            '"');
    int count = result.length; // Count the number of map entries in db table

    List<User> userList = List<User>();
    // For loop to create a 'User List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      userList.add(User.fromMapObject(result[i]));
    }

    return userList;
  }

  // Get number of User objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $userTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'User List' [ List<User> ]
  Future<List<User>> getUserList() async {
    var userMapList = await getUserMapList(); // Get 'Map List' from database
    int count =
        userMapList.length; // Count the number of map entries in db table

    List<User> userList = List<User>();
    // For loop to create a 'User List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      userList.add(User.fromMapObject(userMapList[i]));
    }

    return userList;
  }
}
