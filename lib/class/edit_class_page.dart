import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:reggae_fitness_studio/class/class_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../assets/constants.dart' as constants;
import 'package:simple_time_range_picker/simple_time_range_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../home/main_home_page.dart';

class EditClassPage extends StatefulWidget {
  final item;
  EditClassPage(this.item);

  @override
  _EditClassPageState createState() => _EditClassPageState();
}

class _EditClassPageState extends State<EditClassPage> {
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
  //int classCapacity = 0;
  //double classCost= 0.0;

  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();


  @override
  void initState() {
    name.text = widget.item['class_name'];
    start_date.text = widget.item['class_date'];
    start_time.text = widget.item['start_time'];
    end_time.text = widget.item['end_time'];
    timerange.text = widget.item['start_time'] + " to " + widget.item['end_time'];
    capacity.text = widget.item['class_capacity'];
    cost.text = widget.item['class_cost'];
    remark.text = widget.item['remark'];
    super.initState();
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
    super.dispose();
  }

  Future editClass(BuildContext cont) async {
      var url =
          "http://" + constants.IP_ADDRESS + "/reggaefitness/update_class.php";
      var response = await http.post(Uri.parse(url), body: {
        "class_name": name.text,
        "start_date": start_date.text,
        "start_time": start_time.text,
        "end_time": end_time.text,
        "capacity": capacity.text,
        "cost": cost.text,
        "remark": remark.text,
        "class_id":widget.item['class_id'],
      });

      var data = json.decode(response.body);
      if (data == "Success") {
        Fluttertoast.showToast(
          msg: "Success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainHomePage()));
      }
  }

  Future deleteClass(BuildContext cont) async {
    var url =
        "http://" + constants.IP_ADDRESS + "/reggaefitness/delete_class.php";
    var response = await http.post(Uri.parse(url), body: {
      "class_id":widget.item['class_id'],
    });
    var data = json.decode(response.body);
    if (data == "Success") {
      Fluttertoast.showToast(
        msg: "Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
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
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Edit Class',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(64, 105, 225, 1),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            labelText: "Name",
                          ),
                          //hint: Text("Class"),
                          value: name.text,
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
                          controller: cost,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Class Capacity"),
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
                              labelText: "Remark",),
                          controller: remark,
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),

                      Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(bottom: 100),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                BuildDeleteButton(),
                                SizedBox(width:10),
                                Container(
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
                                              editClass(context),
                                              Navigator.pop(context),
                                            },
                                            child: const Text('Submit'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(80.0)),
                                      ),
                                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
                                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 48,
                                      width: size.width * 0.5,
                                      decoration: new BoxDecoration(
                                          borderRadius: BorderRadius.circular(80.0),
                                          gradient: new LinearGradient(colors: [
                                            Color.fromARGB(255, 255, 136, 34),
                                            Color.fromARGB(255, 255, 177, 41)
                                          ])),
                                      padding: const EdgeInsets.all(0),
                                      child: Text(
                                        "Submit",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                ],
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

  BuildDeleteButton() => Container(
    width: 48,
    height: 48,
    child: ElevatedButton(
      onPressed: () {
        deleteClass(context);
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.redAccent,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(16.0),
        ),
      ),
      child: Icon(
        Icons.delete,
        color: Colors.white,
        size: 20,
      ),
    ),
  );

}
