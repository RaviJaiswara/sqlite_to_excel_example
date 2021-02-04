import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlitetoexcel_example/screens/user_details.dart';
import 'package:sqlitetoexcel_example/screens/export_excel.dart';
import 'package:sqlitetoexcel_example/models/user.dart';
import 'package:sqlitetoexcel_example/utils/database_helper.dart';
import 'package:sqlitetoexcel_example/utils/excel_helper.dart';

class UserList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserListState();
  }
}

class UserListState extends State<UserList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  ExcelHelper excelHelper = ExcelHelper();
  List<User> userList;
  int count = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
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
              showDialog(
                barrierDismissible: false,
                context: dialogContext,
                builder: (_) => ExportExcel(),
              ).then((value) {
                if (value == 'error') {
                  showSnackBar('Please select date range');
                } else {
                  databaseHelper
                      .getUserBetweenDate(value['startDate'].toString(),
                          value['endDate'].toString())
                      .then((value) {
                    for (int i = 0; i < value.length; i++) {
                      databaseHelper.insertLocalUser(value[i]);
                    }
                    excelHelper.exportSingleTable().then((path) {
                      databaseHelper.deleteLocalUser();
                      showSnackBar(
                          'Your excel file is saved in ' + path.toString());
                    });
                  });
                }
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
      content: Text(message),
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
}
