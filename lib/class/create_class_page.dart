import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../assets/constants.dart' as constants;
import 'package:simple_time_range_picker/simple_time_range_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../home/main_home_page.dart';

class CreateClass extends StatefulWidget {
  @override
  _CreateClassState createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  TextEditingController name = TextEditingController();
  TextEditingController start_date = TextEditingController();
  TextEditingController start_time = TextEditingController();
  TextEditingController end_time = TextEditingController();
  TextEditingController capacity = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController timerange = TextEditingController();
  TextEditingController remark = TextEditingController();
  late TextEditingController uid;

  DateTime selectedDate = DateTime.now();
  // Initial Selected Value
  String? dropdownvalue;

  // List of items in our dropdown menu
  var items = [
    'Zumba',
    'Strong Nation',
    'Bootcamp',
  ];
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  String _user_id = '';

  Future getUserID() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _user_id = preferences.getString('uid')!;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserID();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    name.dispose();
    start_date.dispose();
    start_time.dispose();
    end_time.dispose();
    capacity.dispose();
    cost.dispose();
    remark.dispose();
    uid.dispose();
    timerange.dispose();
    super.dispose();
  }

  Future createClass(BuildContext cont) async {
    if (name.text == "" || start_date.text == "" || start_time.text == "" || end_time.text == "" ||capacity.text == "" || cost.text == "" || remark.text == "") {
      Fluttertoast.showToast(
        msg: "Cannot be empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    } else {
      var url =
          "http://" + constants.IP_ADDRESS + "/reggaefitness/create_class.php";
      var response = await http.post(Uri.parse(url), body: {
        "name": name.text,
        "start_date": start_date.text,
        "start_time": start_time.text,
        "end_time": end_time.text,
        "capacity": capacity.text,
        "cost": cost.text,
        "remark": remark.text,
        "uid": _user_id,
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainHomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: new Text('Create Class'),
          elevation: 0,
          backgroundColor: ReggaeFitnessTheme.nearlyDarkBlue,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          )),
      body: SingleChildScrollView(
          child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 24),
            Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        //alignment: Alignment.center,
                        //margin: EdgeInsets.symmetric(horizontal: 40),
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder()
                          ),
                          hint: Text("Class"),
                          value: dropdownvalue,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: items.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownvalue = newValue ?? "";
                              name.text = dropdownvalue!;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        //margin: EdgeInsets.symmetric(horizontal: 40),
                        //alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          decoration: InputDecoration(
                              labelText: "Date", //label text of field
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          controller: start_date,
                          onTap: () async {
                            final DateTime? selected = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (selected != null && selected != selectedDate) {
                              setState(() {
                                selectedDate = selected;
                                start_date.text =
                                    DateFormat("dd/MM/yyyy").format((selectedDate));
                                print(selectedDate);
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Time" //label text of field
                          ),
                          readOnly: true,
                          controller: timerange,
                          onTap: () => TimeRangePicker.show(
                            context: context,
                            unSelectedEmpty: true,
                            startTime: TimeOfDay(
                                hour: _startTime.hour, minute: _startTime.minute),
                            endTime:
                            TimeOfDay(hour: _endTime.hour, minute: _endTime.minute),
                            onSubmitted: (TimeRangeValue value) {
                              setState(() {
                                _startTime = value.startTime!;
                                _endTime = value.endTime!;
                                timerange.text =
                                '${_startTime.format(context)} to ${_endTime.format(context)}';
                                start_time.text = '${_startTime.format(context)}';
                                end_time.text = '${_endTime.format(context)}';
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                              labelText: "Class Cost"),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: capacity,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                              labelText: "Class Capacity",),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: cost,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                              labelText: "Remark"),
                          controller: remark,
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: ElevatedButton(
                          onPressed: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Continue?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => {
                                    createClass(context),
                                  },
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                            ),
                            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          width: size.width * 0.5,
                          decoration: new BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: ReggaeFitnessTheme.nearlyBlue,),
                          padding: const EdgeInsets.all(0),
                          child: Text(
                            "SUBMIT",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ),
                      ),
                    ],
                ),
            )
          ],
        ),
      )),
    );
  }
}
