import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reggae_fitness_studio/app_theme.dart';
import 'package:reggae_fitness_studio/class/attendance_list_view.dart';
import 'package:reggae_fitness_studio/class/class_end_screen.dart';
import 'package:reggae_fitness_studio/class/edit_class_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/constants.dart' as constants;
import 'package:http/http.dart' as http;


class ClassInfoScreen extends StatefulWidget {
  final item;
  ClassInfoScreen({this.item});

  @override
  _ClassInfoScreenState createState() => _ClassInfoScreenState();
}

class _ClassInfoScreenState extends State<ClassInfoScreen>
    with TickerProviderStateMixin {
  final double infoHeight = 364.0;
  String text_join = "JOIN CLASS";
  String class_id = '';
  String id = '';
  String uid = '';
  String attendee = '';
  String user_info = '';
  String ticket_id = '';
  bool isJoin = true;
  bool visibility = true;
  bool isEnded = false;

  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_info = preferences.getString('u_info')!;
      //id = preferences.getString('uid')!;
      Map<String, dynamic> map = jsonDecode(user_info);
      id = map['u_id'];
    });
  }

  Future<void> checkReservation() async {
    await getUser();
    var url2 = "http://" + constants.IP_ADDRESS + "/reggaefitness/check_class.php";
    var response2 = await http.post(Uri.parse(url2), body: {
      "u_id": id,
      "class_id": class_id,
    });
    var data2 = json.decode(response2.body);
    setState(() {
      //get the number of attendees
      attendee = data2['joined_user'].toString();
      if(data2['class_status']=="ENDED"){
        isEnded = true;
      }
    });
    if (data2['status'] == true) {
      setState(() {
        visibility = true;
        text_join = "END CLASS";
      });
    } else if (data2['status'] == false) {
      visibility = false;
      var url = "http://" +
          constants.IP_ADDRESS +
          "/reggaefitness/check_reservation.php";
      var response = await http.post(Uri.parse(url), body: {
        "u_id": id,
        "class_id": class_id,
      });
      var data = json.decode(response.body);
      setState(() {
        if (data['status'] == true) {
          isJoin = true;
          ticket_id = data['reserveInfo']['class_ticket_id'];
          text_join = data['reserveInfo']['status'] +
              ' (' +
              data['reserveInfo']['current_number'] +
              ')';
        } else {
          isJoin = false;
        }
      });
      return data;
    }
  }

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    class_id = widget.item['class_id'];
    setData();
    getUser();
    checkReservation();
    super.initState();
  }

  Future<void> setData() async {
    animationController?.forward();
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity1 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity2 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
    });
  }

  Future joinClass(BuildContext cont) async {
    var url =
        "http://" + constants.IP_ADDRESS + "/reggaefitness/join_class.php";
    var response = await http.post(Uri.parse(url), body: {
      "u_id": id,
      "class_id": class_id,
    });
    var data = json.decode(response.body);
    setState(() {
      isJoin = true;
    });
    //return data;
    checkReservation();
  }

  Future cancelReserve(BuildContext cont) async {
    var url =
        "http://" + constants.IP_ADDRESS + "/reggaefitness/cancel_reserve.php";
    var response = await http.post(Uri.parse(url), body: {
      "class_id": class_id,
      "class_ticket_id": ticket_id,
    });
    var data = json.decode(response.body);
    setState(() {
      isJoin = false;
    });
    //return data;
    checkReservation();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        20.0;
    final date = DateTime.tryParse(widget.item['class_date']);
    String formatted_date = DateFormat("dd/MM/yyyy").format(date!);
    String formatted_starttime = DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.item['start_time']));
    String formatted_endtime = DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.item['end_time']));
    return Container(
      color: ReggaeFitnessTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          //minimum: const EdgeInsets.only(bottom: 62),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.asset(displayImage(widget.item['class_name'])),
                  ),
                ],
              ),
              Positioned(
                top: (MediaQuery.of(context).size.width / 1.2) - 50.0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: ReggaeFitnessTheme.nearlyWhite,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32.0),
                        topRight: Radius.circular(32.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints(
                            minHeight: infoHeight,
                            maxHeight: tempHeight > infoHeight
                                ? tempHeight
                                : infoHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 32.0, left: 18, right: 16),
                              child: Text(
                                widget.item['class_name'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                  letterSpacing: 0.27,
                                  color: ReggaeFitnessTheme.darkerText,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 8, top: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '\RM' + widget.item['class_cost'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22,
                                      letterSpacing: 0.27,
                                      color: ReggaeFitnessTheme.nearlyBlue,
                                    ),
                                  ),


                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          "",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 22,
                                            letterSpacing: 0.27,
                                            color: ReggaeFitnessTheme.nearlyBlue,
                                          ),
                                        ),
                                        /*
                                        Icon(
                                          Icons.account_circle_sharp,
                                          color: ReggaeFitnessTheme.nearlyBlue,
                                          size: 24,
                                        ),

                                         */
                                      ],
                                    ),
                                  )


                                ],
                              ),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity1,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: <Widget>[
                                    getTimeBoxUI(
                                        formatted_date, 'Date'),
                                    getTimeBoxUI(formatted_starttime,
                                        formatted_endtime),
                                    getTimeBoxUI(attendee+ "/" +widget.item['class_capacity'],
                                        'People'),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: opacity2,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 8, bottom: 8),
                                  child: Text(
                                    widget.item['remark'],
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      letterSpacing: 0.27,
                                      color: ReggaeFitnessTheme.grey,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity3,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, bottom: 16, right: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    BuildEditButton(),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    BuildViewButton(),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      //child: BuildJoinButton(), BuildEndButton(),
                                      child:Visibility(
                                        visible: (isEnded) ? false : true,
                                        child: (visibility)
                                            ? BuildEndButton()
                                            : BuildJoinButton(),
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).padding.bottom,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: SizedBox(
                  width: AppBar().preferredSize.height,
                  height: AppBar().preferredSize.height,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(AppBar().preferredSize.height),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getTimeBoxUI(String text1, String txt2) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Colors.blue,
                ),
              ),
              Text(
                txt2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BuildEditButton() => Visibility(
        visible: (visibility) ? true : false,
        child: Container(
          margin: const EdgeInsets.only(bottom: 62),
          width: 48,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditClassPage(widget.item)));
            },
            style: ElevatedButton.styleFrom(
              primary: ReggaeFitnessTheme.nearlyWhite,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(16.0),
              ),
            ),
            child: Icon(
              Icons.edit,
              color: Colors.blue,
              size: 20,
            ),
          ),
        ),
      );

  BuildViewButton() => Visibility(
    visible: (visibility) ? true : false,
    child: Container(
      margin: const EdgeInsets.only(bottom: 62),
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AttendanceListView(class_id)));
        },
        style: ElevatedButton.styleFrom(
          primary: ReggaeFitnessTheme.nearlyWhite,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(16.0),
          ),
        ),
        child: Icon(
          Icons.visibility,
          color: Colors.blue,
          size: 20,
        ),
      ),
    ),
  );

  BuildEndButton() => Visibility(
        visible: (visibility) ? true : false,
        child: Container(
          margin: const EdgeInsets.only(bottom: 62),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EndScreenPage(class_id)));
            },
            style: ElevatedButton.styleFrom(
              primary: ReggaeFitnessTheme.nearlyBlue,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(16.0),
              ),
            ),
            child: Center(
              child: Text(
                isJoin ? text_join : "JOIN CLASS",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    letterSpacing: 0.0,
                    color: ReggaeFitnessTheme.nearlyWhite),
              ),
            ),
          ),
        ),
      );

  BuildJoinButton() => Visibility(
        visible: (visibility) ? false : true,
        child: Container(
          margin: const EdgeInsets.only(bottom: 62),
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
              if (isJoin){
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('You will be charged with full amount upon cancellation within 24 hours. Do you still want to continue?'),
                    // content: const Text('AlertDialog description'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => {
                        cancelReserve(context),
                          Navigator.pop(context),
                        },
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                );
              }else{
                showDialog(
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
                          joinClass(context),
                          Navigator.pop(context),
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              }
            },
            /*
            onPressed: () {
              (isJoin) ? cancelReserve(context) : joinClass(context);
            },
             */
            style: ElevatedButton.styleFrom(
              primary: ReggaeFitnessTheme.nearlyBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            child: Center(
              child: Text(
                isJoin ? text_join : "JOIN CLASS",
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    letterSpacing: 0.0,
                    color: ReggaeFitnessTheme.nearlyWhite),
              ),
            ),
          ),
        ),
      );

  String displayImage(String n) {
    var url = '';
    if (n == "Zumba") {
      return 'assets/images/zumba_2.png';
    } else if (n == "Strong Nation") {
      return 'assets/images/strong_nation_2.png';
    } else if (n == "Bootcamp") {
      return 'assets/images/bootcamp_2.png';
    } else {
      return url;
    }
  }
}
