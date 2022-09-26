import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../assets/constants.dart' as constants;
import 'package:http/http.dart' as http;
import '../models/history.dart';
import '../models/payment.dart';

class AllPaymentPage extends StatefulWidget {
  const AllPaymentPage({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _AllPaymentPageState createState() => _AllPaymentPageState();
}

class _AllPaymentPageState extends State<AllPaymentPage>
    with TickerProviderStateMixin {
  var _isChecked = List<bool>.empty(growable: true);
  var _isPaid = List.empty(growable: true);
  var _notPaid = List.empty(growable: true);
  String user_info = '';
  String id = '';

  Future getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_info = preferences.getString('u_info')!;
      Map<String, dynamic> map = jsonDecode(user_info);
      id = map['u_id'];
    });
  }

  Future getAllPayment(String status) async {
    var url =
        "http://" + constants.IP_ADDRESS + "/reggaefitness/get_all_payment.php";
    var response = await http.post(Uri.parse(url), body: {
      "u_id": id,
      "status": status,
    });
    var data = json.decode(response.body);

    List<AllPayment> p = [];

    for (var i in data) {
      AllPayment payment = AllPayment(
          i["u_name"],
          i["status"],
          i["payment_status"],
          i["class_ticket_id"],
          i['reserve_cancel_datetime'],
          i['u_phone_number'],
          i['class_name'],
          i['class_date']);
      p.add(payment);
      _isChecked.add(false);
    }
    return p;
  }

  Future updatePayment(BuildContext cont) async {
    var url =
        "http://" + constants.IP_ADDRESS + "/reggaefitness/update_payment.php";
    var response = await http.post(Uri.parse(url), body: {
      "paidTicket": json.encode(_isPaid),
      "unpaidTicket": json.encode(_notPaid),
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: ReggaeFitnessTheme.nearlyDarkBlue,
        title: new Text('Payment'),
        elevation: 0,
      ),
      body: DefaultTabController(
          length: 3,
          child: Column(
            children: <Widget>[
              Material(
                color: Colors.grey.shade300,
                child: TabBar(
                  unselectedLabelColor: Colors.blue,
                  labelColor: Colors.blue,
                  indicatorColor: Colors.white,
                  //controller: _tabController,
                  labelPadding: const EdgeInsets.all(0.0),
                  tabs: [
                    new Tab(text: "Unpaid"),
                    new Tab(text: "Paid"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  //physics: NeverScrollableScrollPhysics(),
                  //controller: _tabController,
                  children: [UnpaidPayment("UNPAID"), paidPayment("PAID")],
                ),
              ),
            ],
          )),
    );
  }

  UnpaidPayment(String st) => SingleChildScrollView(
          child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 100),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              FutureBuilder(
                future: getAllPayment(st),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            List list = snapshot.data;
                            return Card(
                                child: ListTile(
                              leading: ProfilePicture(
                                name: list[index].username,
                                radius: 20,
                                fontsize: 21,
                              ),
                              title: Text(list[index].username +
                                  " (" +
                                  list[index].phoneNumber +
                                  ")"),
                              subtitle: Text(list[index].className +
                                  " (" +
                                  list[index].classDate +
                                  ")"),
                              trailing: Checkbox(
                                checkColor: Colors.white,
                                shape: CircleBorder(),
                                activeColor: Colors.blue,
                                value: _isChecked[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isChecked[index] = !_isChecked[index];
                                    if (_isChecked[index] == true) {
                                      _isPaid.add(list[index].ticket);
                                    } else {
                                      _notPaid.add(list[index].ticket);
                                    }
                                  });
                                },
                              ),
                            ));
                          },
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        );
                },
              ),
              BuildSubmitButton(),
            ])),
      ));

  paidPayment(String st) => SingleChildScrollView(
          child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 100),
        child: Column(children: [
          FutureBuilder(
            future: getAllPayment(st),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasError) print(snapshot.error);
              return snapshot.hasData
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.only(top: 16, right: 16, left: 16),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        List list = snapshot.data;
                        return Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: ProfilePicture(
                                name: list[index].username,
                                radius: 20,
                                fontsize: 21,
                              ),
                              title: Text(list[index].username +
                                  " (" +
                                  list[index].phoneNumber +
                                  ")"),
                              subtitle: Text(list[index].className +
                                  " (" +
                                  list[index].classDate +
                                  ")"),
                            ));
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            },
          ),
        ]),
      ));

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
          updatePayment(context);
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
      ));
}
