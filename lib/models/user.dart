class User {
  int _id;
  String _name;
  String _mobileNumber;
  String _amount;
  String _date;
  int _productType;
  int _amountType;
  String _imagePath;

  User(this._name, this._date, this._productType, this._amountType,
      [this._mobileNumber, this._amount, this._imagePath]);

  User.withId(this._id, this._name, this._date, this._productType,
      [this._mobileNumber, this._amount, this._imagePath]);

  int get id => _id;

  String get name => _name;

  String get mobileNumber => _mobileNumber;

  String get amount => _amount;

  int get productType => _productType;

  int get amountType => _amountType;

  String get imagePath => _imagePath;

  String get date => _date;

  set name(String newName) {
    if (newName.length <= 255) {
      this._name = newName;
    }
  }

  set mobileNumber(String newMobileNumber) {
    if (newMobileNumber.length <= 255) {
      this._mobileNumber = newMobileNumber;
    }
  }

  set imagePath(String newImagePath) {
    if (newImagePath != null) {
      this._imagePath = newImagePath;
    }
  }

  set amount(String newAmount) {
    if (newAmount.length <= 255) {
      this._amount = newAmount;
    }
  }

  set productType(int newProductType) {
    if (newProductType >= 1 && newProductType <= 2) {
      this._productType = newProductType;
    }
  }

  set amountType(int newAmountType) {
    if (newAmountType >= 1 && newAmountType <= 2) {
      this._amountType = newAmountType;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  // Convert a User object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['name'] = _name;
    map['mobile_number'] = _mobileNumber;
    map['amount'] = _amount;
    map['product_type'] = _productType;
    map['amount_type'] = _amountType;
    map['image_path'] = _imagePath;
    map['date'] = _date;

    return map;
  }

  // Extract a User object from a Map object
  User.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._mobileNumber = map['mobile_number'];
    this._amount = map['amount'];
    this._productType = map['product_type'];
    this._amountType = map['amount_type'];
    this._date = map['date'];
    this._imagePath = map['image_path'];
  }
}
