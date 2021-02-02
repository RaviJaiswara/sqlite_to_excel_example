import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlitetoexcel/sqlitetoexcel.dart';
import 'package:sqlitetoexcel_example/screens/user_details.dart';
import 'package:sqlitetoexcel_example/models/user.dart';
import 'package:sqlitetoexcel_example/utils/database_helper.dart';

class UserList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserListState();
  }
}

class UserListState extends State<UserList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<User> userList;
  int count = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    if (userList == null) {
      userList = List<User>();
      updateListView();
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Center(child: Text('User List')),
        actions: [
          InkWell(
            child: Container(
              child: Image.asset(
                'assets/images/ambulance.png',
              ),
              width: 100,
            ),
          ),
        ],
      ),
      body: getUserListView(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          confirmationPopup(context);
        },
        tooltip: 'Add User',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getUserListView(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 8.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.yellow,
              child: this.userList[position].imagePath != null
                  ? Image.file(File(this.userList[position].imagePath))
                  : Icon(Icons.keyboard_arrow_right),
            ),
            title: Text(
              this.userList[position].name +
                  ' - ' +
                  this.userList[position].mobileNumber,
              style: titleStyle,
            ),
            subtitle: Text(this.userList[position].date),
            trailing: Text(
              this.userList[position].amount != null
                  ? '₹ ' + this.userList[position].amount
                  : '',
              style: titleStyle,
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.userList[position], 'Edit User', context);
            },
          ),
        );
      },
    );
  }

  void navigateToDetail(User user, String title, BuildContext context) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return UserDetail(user, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<User>> userListFuture = databaseHelper.getUserList();
      userListFuture.then((userList) {
        setState(() {
          this.userList = userList;
          this.count = userList.length;
        });
      });
    });
  }

  confirmationPopup(BuildContext dialogContext) {
    var alertStyle = AlertStyle(
      animationType: AnimationType.grow,
      overlayColor: Colors.black87,
      isCloseButton: true,
      isOverlayTapDismiss: true,
      titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      descStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      animationDuration: Duration(milliseconds: 400),
    );

    Alert(
        context: dialogContext,
        style: alertStyle,
        title: "Please select any option?",
        buttons: [
          DialogButton(
            child: Text(
              "Add",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              debugPrint('FAB clicked');
              navigateToDetail(User('', '', 1, 1), 'Add User', dialogContext);
            },
            color: Colors.green,
          ),
          DialogButton(
            child: Text(
              "Export",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _exportSingleTable().then((path) {
                showSnackBar(path.toString());
              });
            },
            color: Colors.red,
          )
        ]).show();
  }

  getPermission() async {
    await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((status) {
      if (status == PermissionStatus.denied) {
        requestPermission();
      }
    });
  }

  void showSnackBar(String message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Your excel file is saved in ' + message),
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: scaffoldKey.currentState.hideCurrentSnackBar,
      ),
    ));
  }

  requestPermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  Future<String> _exportSingleTable() async {
    var excludes = new List();
    var dbPath, dir;
    var prettify = new Map<dynamic, dynamic>();
    var finalpath = "";

    // Exclude column(s) from being exported
    excludes.add("id");

    // Prettifies columns name
    prettify["name"] = "Name";

    // Table name that will be exported
    var tableName = "user_table";

    final directory = await getExternalStorageDirectory();
    var path = directory.path;
    path = directory.path;
    dbPath = join(directory.path, 'users.db');
    print(dbPath);
    dir = path + "/";

    try {
      finalpath = await Sqlitetoexcel.exportSingleTable(
          dbPath, "documents", "", "users.xls", tableName, excludes, prettify);
    } on PlatformException catch (e) {
      print(e.message.toString());
    }
    return finalpath;
  }
}
