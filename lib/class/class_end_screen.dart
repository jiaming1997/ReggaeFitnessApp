import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../assets/constants.dart' as constants;
import 'package:http/http.dart' as http;

import '../home/main_home_page.dart';
import '../models/attendance.dart';

class EndScreenPage extends StatefulWidget {
  final class_id;
  EndScreenPage(this.class_id);

  @override
  EndScreenPageState createState() => new EndScreenPageState();
}

class EndScreenPageState extends State<EndScreenPage> {
  late List<bool> _isChecked;
  var userStatus = List<bool>.empty(growable: true);
  var joined = List.empty(growable: true);
  var notjoined = List.empty(growable: true);
  bool selectAll = false;

  Future getAttendee() async {
    var url = "http://" +
        constants.IP_ADDRESS +
        "/reggaefitness/get_all_attendee.php";
    var response = await http.post(Uri.parse(url), body: {
      "class_id": widget.class_id,
    });
    var data = json.decode(response.body);

    List<Attendance> a = [];

    for (var u in data) {
      Attendance attend =
      Attendance(u['current_number'], u["u_name"], u["class_ticket_id"], u["payment_status"]);
      a.add(attend);
      userStatus.add(false);
      notjoined.add(u["class_ticket_id"]);
    }
    return a;
  }

  Future updateAttendance(BuildContext cont) async {
    var url = "http://" +
        constants.IP_ADDRESS +
        "/reggaefitness/update_attendance.php";
    var response = await http.post(Uri.parse(url), body: {
      "ticket_id": json.encode(joined),
      "nticket": json.encode(notjoined),
      "class_id": widget.class_id,
    });
    Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context) => MainHomePage()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance List"),
        backgroundColor: ReggaeFitnessTheme.nearlyDarkBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 100),
          child: Container(
          padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Column(children: [
              FutureBuilder(
                future: getAttendee(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:
                    const EdgeInsets.only(top: 16),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      List list = snapshot.data;
                      /*
                      if(selectAll == true){
                        joined.add(list[index].ticket);
                        notjoined.remove(list[index].ticket);
                      }else if(selectAll == false){
                        joined.remove(list[index].ticket);
                        notjoined.add(list[index].ticket);
                      }
                       */
                      return Column(
                        children: [
                          Card(
                              color: Colors.white,
                              child: ListTile(
                                title: Text(list[index].name),
                                subtitle: Text(list[index].paymentStatus),
                                trailing: Container(
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    shape: CircleBorder(),
                                    activeColor: Colors.blue,
                                    value: userStatus[index],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        userStatus[index] = !userStatus[index];
                                        if (userStatus[index] == true) {
                                          _onSelected(true, list[index].ticket);
                                        }else{
                                          _onSelected(false, list[index].ticket);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              )
                          ),
                        ],
                      );
                    },
                  )
                      : const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
              BuildSubmitButton(),
            ]),
          ),
        ),
      ),
    );
  }

  BuildSubmitButton() => Container(
    margin: const EdgeInsets.only(bottom: 62, top: 10),
    height: 48,
    decoration: BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: ReggaeFitnessTheme.nearlyBlue.withOpacity(0.5),
            offset: const Offset(1.1, 1.1),
            blurRadius: 10.0),
      ],
    ),
    child: ElevatedButton(
      onPressed: () {
        updateAttendance(context);
      },
      style: ElevatedButton.styleFrom(
        primary: ReggaeFitnessTheme.nearlyBlue,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(16.0),
        ),
      ),
      child: Center(
        child: Text(
          "Submit",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.0,
              color: ReggaeFitnessTheme.nearlyWhite),
        ),
      ),
    ),
  );

  void _onSelected(bool selected, String ticket) {
    if (selected == true) {
      setState(() {
        notjoined.remove(ticket);
        joined.add(ticket);
      });
    } else{
      setState(() {
        joined.remove(ticket);
        notjoined.add(ticket);
      });
    }
  }
}
