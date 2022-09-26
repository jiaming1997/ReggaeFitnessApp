import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reggae_fitness_studio/class/update_payment_page.dart';
import '../app_theme.dart';
import '../assets/constants.dart' as constants;
import 'package:http/http.dart' as http;

class CustomAttendanceList extends StatelessWidget {
  const CustomAttendanceList({
    Key? key,
    required this.position,
    required this.name,
    required this.status,
  }) : super(key: key);

  final String position;
  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            //padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      width: 80.0,
                      child: Text(position),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      width: 100.0,
                      child: Text(name),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(right: 16, top: 4),
                        width: 100.0,
                        child: Text(status, textAlign: TextAlign.right),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AttendList extends StatefulWidget {
  const AttendList({
    Key? key,
    required this.position,
    required this.name,
    required this.status,
  }) : super(key: key);

  final String position;
  final String name;
  final String status;

  @override
  State<AttendList> createState() => _AttendListState();
}

class _AttendListState extends State<AttendList> {
  @override
  Widget build(BuildContext context) {
    return CustomAttendanceList(
      position: widget.position,
      name: widget.name,
      status: widget.status,
    );
  }
}

class AttendanceListView extends StatefulWidget {
  final class_id;
  AttendanceListView(this.class_id);

  @override
  _AttendanceListViewState createState() => _AttendanceListViewState();
}

class _AttendanceListViewState extends State<AttendanceListView> {
  Future getAttendee() async {
    var url = "http://" +
        constants.IP_ADDRESS +
        "/reggaefitness/get_all_attendee.php";
    var response = await http.post(Uri.parse(url), body: {
      "class_id": widget.class_id,
    });
    var data = json.decode(response.body);
    return data;
  }

  @override
  void initState() {
    getAttendee();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List"),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            width: 80.0,
                            child: Text("Index",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            width: 100.0,
                            child: Text("Name",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(right: 16, top: 4),
                              width: 100.0,
                              child: Text("Status",
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: getAttendee(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      return snapshot.hasData
                          ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          List list = snapshot.data;
                          return AttendList(
                            position: list[index]['current_number'],
                            name: list[index]['u_name'],
                            status: list[index]['status'],
                          );
                        },
                      )
                          : const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  Container(
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
                    child: BuildUpdateButton(),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  BuildUpdateButton() => ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdatePaymentPage(widget.class_id),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: ReggaeFitnessTheme.nearlyBlue,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(16.0),
          ),
        ),
        child: Center(
          child: Text(
            "Update Payment",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0.0,
                color: ReggaeFitnessTheme.nearlyWhite),
          ),
        ),
      );
}

class Attend {
  final String position;
  final String name;
  final String ticket;

  Attend(this.position, this.name, this.ticket);
}
