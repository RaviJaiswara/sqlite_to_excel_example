import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sqlitetoexcel_example/utils/database_helper.dart';
import 'package:sqlitetoexcel_example/models/user.dart';

class UserDetail extends StatefulWidget {
  final String appBarTitle;
  final User user;

  UserDetail(this.user, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return UserDetailState(this.user, this.appBarTitle);
  }
}

class UserDetailState extends State<UserDetail> {
  static var _productType = ['Product', 'Service'];
  static var _amountType = ['Cash', 'Online', 'Gpay'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  User user;

  TextEditingController nameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  File _image;
  final picker = ImagePicker();

  UserDetailState(this.user, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    nameController.text = user.name;
    mobileNumberController.text = user.mobileNumber;
    amountController.text = user.amount;

    return WillPopScope(
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(appBarTitle),
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
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First Element
                Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: TextField(
                    controller: nameController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Name Text Field');
                      updateName();
                    },
                    decoration: InputDecoration(
                      hintText: "Name",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                    ),
                  ),
                ),

                // Second Element
                Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: TextField(
                    controller: mobileNumberController,
                    style: textStyle,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      debugPrint(
                          'Something changed in Mobile Number Text Field');
                      updatemobileNumber();
                    },
                    decoration: InputDecoration(
                      hintText: "Mobile Number",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                    ),
                  ),
                ),

                // Third Element
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: DropdownButton(
                            items:
                                _productType.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            style: textStyle,
                            value: getProductTypeAsString(user.productType),
                            onChanged: (valueSelectedByUser) {
                              setState(() {
                                debugPrint(
                                    'User selected $valueSelectedByUser');
                                updateProductTypeAsInt(valueSelectedByUser);
                              });
                            }),
                      ),
                    ),
                    // Third Element
                    Expanded(
                      child: ListTile(
                        title: DropdownButton(
                            items: _amountType.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            style: textStyle,
                            value: getAmountTypeAsString(user.amountType),
                            onChanged: (valueSelectedByUser) {
                              setState(() {
                                debugPrint(
                                    'User selected $valueSelectedByUser');
                                updateAmountTypeAsInt(valueSelectedByUser);
                              });
                            }),
                      ),
                    ),
                  ],
                ),

                // Fourth Element
                Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: TextField(
                    controller: amountController,
                    style: textStyle,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      debugPrint('Something changed in Amount Text Field');
                      updateAmount();
                    },
                    decoration: InputDecoration(
                      hintText: "Amount",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap: () {
                      _selectDate();
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        style: textStyle,
                        controller: dateController,
                        decoration: InputDecoration(
                          hintText: "Select date",
                          suffixIcon: Icon(Icons.date_range),
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Center(
                        child: _image == null
                            ? Text('No image selected.',
                                style: TextStyle(color: Colors.red))
                            : Text(
                                'Image selected successfully',
                                style: TextStyle(color: Colors.green),
                              ),
                      ),
                      _image == null
                          ? InkWell(
                              onTap: () {
                                getImage();
                              },
                              child: Icon(Icons.add_a_photo),
                            )
                          : Container()
                    ],
                  ),
                ),

                // Fourth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              if (nameController.text.isEmpty) {
                                _showAlertDialog('Error', 'Name is required');
                              } else if (mobileNumberController.text.isEmpty) {
                                _showAlertDialog(
                                    'Error', 'Mobile Number is required');
                              } else {
                                _save();
                              }
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        updateImage();
      } else {
        print('No image selected.');
      }
    });
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String product type in the form of integer before saving it to Database
  void updateProductTypeAsInt(String value) {
    switch (value) {
      case 'Product':
        user.productType = 1;
        break;
      case 'Service':
        user.productType = 2;
        break;
    }
  }

  // Convert the String product type in the form of integer before saving it to Database
  void updateAmountTypeAsInt(String value) {
    switch (value) {
      case 'Cash':
        user.amountType = 1;
        break;
      case 'Online':
        user.amountType = 2;
        break;
      case 'Gpay':
        user.amountType = 2;
        break;
    }
  }

  // Convert int productType to String productType and display it to user in DropDown
  String getProductTypeAsString(int value) {
    String productType;
    switch (value) {
      case 1:
        productType = _productType[0]; // 'Product'
        break;
      case 2:
        productType = _productType[1]; // 'Service'
        break;
    }
    return productType;
  }

  // Convert int productType to String productType and display it to user in DropDown
  String getAmountTypeAsString(int value) {
    String amountType;
    switch (value) {
      case 1:
        amountType = _amountType[0]; // 'Cash'
        break;
      case 2:
        amountType = _amountType[1]; // 'Online'
        break;
      case 2:
        amountType = _amountType[2]; // 'Gpay'
        break;
    }
    return amountType;
  }

  // Update the name of User object
  void updateName() {
    user.name = nameController.text;
  }

  // Update the image of User Object
  void updateImage() {
    user.imagePath = _image.path;
  }

  // Update the mobile number of User object
  void updatemobileNumber() {
    user.mobileNumber = mobileNumberController.text;
  }

  // Update the amount of the User object
  void updateAmount() {
    user.amount = amountController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    user.date = dateController.text.isNotEmpty
        ? dateController.text
        : DateFormat("dd-MM-yyyy").format(DateTime.now());

    int result;
    if (user.id != null) {
      // Case 1: Update operation
      result = await helper.updateUser(user);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertUser(user);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'User Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving User');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW USER i.e. he has come to
    // the detail page by pressing the FAB of UserList page.
    if (user.id == null) {
      _showAlertDialog('Status', 'No User was deleted');
      return;
    }

    // Case 2: User is trying to delete the old user that already has a valid ID.
    int result = await helper.deleteUser(user.id);
    if (result != 0) {
      _showAlertDialog('Status', 'User Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting User');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2030));
    if (picked != null) {
      setState(() {
        dateController.text =
            DateFormat("dd-MM-yyyy").format(DateTime.parse(picked.toString()));
      });
    }
  }
}
