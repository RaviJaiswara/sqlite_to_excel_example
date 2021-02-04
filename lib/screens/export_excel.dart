import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExportExcel extends StatefulWidget {
  static final String id = '/eport_view';
  @override
  State<StatefulWidget> createState() {
    return _ExportExcel();
  }
}

class _ExportExcel extends State<ExportExcel>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      key: scaffoldKey,
      onWillPop: () => Future.value(false),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              height: 250,
              width: 400,
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0))),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        _selectStartDate(context);
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          style: Theme.of(context).textTheme.title,
                          controller: startDateController,
                          decoration: InputDecoration(
                            hintText: "Start date",
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
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        _selectEndDate(context);
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          style: Theme.of(context).textTheme.title,
                          controller: endDateController,
                          decoration: InputDecoration(
                            hintText: "End date",
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
                    padding: const EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ButtonTheme(
                        minWidth: 20.0,
                        height: 30.0,
                        child: RaisedButton(
                          child: Text(
                            'Export',
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.0),
                          ),
                          onPressed: () {
                            if (startDateController.text.isNotEmpty &&
                                endDateController.text.isNotEmpty) {
                              Map<dynamic, String> map =
                                  new Map<dynamic, String>();
                              map['startDate'] = startDateController.text;
                              map['endDate'] = endDateController.text;
                              Navigator.pop(context, map);
                            } else {
                              Navigator.pop(context, 'error');
                            }
                          },
                          color: Colors.deepOrange[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _selectStartDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2030));
    if (picked != null) {
      setState(() {
        startDateController.text =
            DateFormat("dd-MM-yyyy").format(DateTime.parse(picked.toString()));
      });
    }
  }

  Future _selectEndDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2030));
    if (picked != null) {
      setState(() {
        endDateController.text =
            DateFormat("dd-MM-yyyy").format(DateTime.parse(picked.toString()));
      });
    }
  }
}
