import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../assets/constants.dart' as constants;
import 'package:http/http.dart' as http;

import '../models/attendance.dart';
import '../models/payment.dart';

class UpdatePaymentPage extends StatefulWidget {
  final class_id;
  UpdatePaymentPage(this.class_id);

  @override
  UpdatePaymentPageState createState() => new UpdatePaymentPageState();
}

class UpdatePaymentPageState extends State<UpdatePaymentPage> {
  var _isChecked = List<bool>.empty(growable: true);
  var _isPaid = List.empty(growable: true);
  var _notPaid = List.empty(growable: true);
  bool selectAll = false;

  Future getPaymentAttendee() async {
    var url = "http://" +
        constants.IP_ADDRESS +
        "/reggaefitness/get_attendee_payment.php";
    var response = await http.post(Uri.parse(url), body: {
      "class_id": widget.class_id,
    });
    var data = json.decode(response.body);

    List<Payment> p = [];

    for (var i in data) {
      Payment payment = Payment(i["u_name"],i["status"], i["payment_status"], i["class_ticket_id"], i['reserve_cancel_datetime'], i['u_phone_number']);
      p.add(payment);

      if(payment.paymentStatus == "PAID"){
        _isChecked.add(true);
      }else{
        _isChecked.add(false);
      }
    }
    return p;
  }

  Future updatePayment(BuildContext cont) async {
    var url = "http://" +
        constants.IP_ADDRESS +
        "/reggaefitness/update_payment.php";
    var response = await http.post(Uri.parse(url), body: {
      "paidTicket": json.encode(_isPaid),
      "unpaidTicket": json.encode(_notPaid),
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    getPaymentAttendee();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 100),
          child: Column(children: [
            FutureBuilder(
              future: getPaymentAttendee(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.only(top: 16, right: 16, left: 16),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    List list = snapshot.data;
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(list[index].username+" ("+list[index].phoneNumber+")"),
                        subtitle: Text(list[index].entryStatus),
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
                              }else{
                                _notPaid.add(list[index].ticket);
                              }
                            });
                          },
                        ),
                      )
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
    );
  }

  BuildSubmitButton() => ElevatedButton(
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
        "Submit",
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
