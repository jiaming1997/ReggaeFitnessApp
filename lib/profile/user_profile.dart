import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:reggae_fitness_studio/profile/edit_password.dart';
import 'package:reggae_fitness_studio/profile/edit_phone_number.dart';
import 'package:reggae_fitness_studio/report/report_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../auth/sign_in_page.dart';
import '../history/history_page.dart';
import '../payment/all_payment.dart';
import 'edit_username.dart';
import '../assets/constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  final double infoHeight = 364.0;
  String id = '';
  String email = '';
  String user_info = '';
  String username = '';
  String phone_number = '';
  String user_role = '';
  bool visibility = true;

  final double profileHeight = 144;

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email')!;
      user_info = preferences.getString('u_info')!;
      Map<String, dynamic> map = jsonDecode(user_info);
      id = map['u_id'];
    });
    var url =
        "http://" + constants.IP_ADDRESS + "/reggaefitness/check_user.php";
    var response = await http.post(Uri.parse(url), body: {
      "u_id": id,
    });
    var data = json.decode(response.body);
    if (data['status'] == true) {
      setState(() {
        username = data['userInfo']['u_name'];
        phone_number = data['userInfo']['u_phone_number'];
        user_role = data['userInfo']['u_type'];
        if (user_role != "1") {
          visibility = false;
        }
      });
    }
  }

  Future signOut(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('email');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInPage()));
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        20.0;
    return MaterialApp(
        title: 'Profile',
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: ReggaeFitnessTheme.background,
          appBar: AppBar(
            backgroundColor: ReggaeFitnessTheme.nearlyDarkBlue,
            actions: <Widget>[
              buildPaymentNav(),
              buildChartNav(),
              buildHistoryNav(),
            ],
          ),
          body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  buildProfileImage(),
                  const SizedBox(height: 24),
                  Expanded(
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
                      width: double.infinity,
                      child: Container(
                        constraints: BoxConstraints(
                            minHeight: infoHeight,
                            maxHeight: tempHeight > infoHeight
                                ? tempHeight
                                : infoHeight),
                        child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildBackground(),
                                buildLogoutButton(),
                              ],
                            )),
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }

  buildProfileImage() => ProfilePicture(
        name: username,
        radius: profileHeight / 2,
        fontsize: 50,
      );

  buildBackground() => Container(
        padding: EdgeInsets.only(bottom: 10, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ReggaeFitnessTheme.blueGrey,
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Container(
              width: 350,
              height: 40,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: ReggaeFitnessTheme.nearlyBlue,
                width: 1,
              ))),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUsernameFormPage(),
                          ),
                        );
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          username,
                          style: TextStyle(
                              fontSize: 16, height: 1.4, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: ReggaeFitnessTheme.nearlyBlue,
                    size: 40.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Email",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ReggaeFitnessTheme.blueGrey,
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Container(
              width: 350,
              height: 40,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: ReggaeFitnessTheme.nearlyBlue,
                width: 1,
              ))),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () {},
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            email,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: Colors.black87),
                          ),
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Phone Number",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ReggaeFitnessTheme.blueGrey,
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Container(
              width: 350,
              height: 40,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: ReggaeFitnessTheme.nearlyBlue,
                width: 1,
              ))),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPhoneNumberFormPage(),
                          ),
                        );
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          phone_number,
                          style: TextStyle(
                              fontSize: 16, height: 1.4, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: ReggaeFitnessTheme.nearlyBlue,
                    size: 40.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Security",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ReggaeFitnessTheme.blueGrey,
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Container(
              width: 350,
              height: 40,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: ReggaeFitnessTheme.nearlyBlue,
                width: 1,
              ))),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPasswordFormPage(),
                          ),
                        );
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                              fontSize: 16, height: 1.4, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: ReggaeFitnessTheme.nearlyBlue,
                    size: 40.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      );

  buildChartNav() => Visibility(
        visible: (visibility) ? true : false,
        child: IconButton(
          icon: Icon(
            Icons.add_chart,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AttendanceReport()));
          },
        ),
      );

  buildPaymentNav() => Visibility(
        visible: (visibility) ? true : false,
        child: IconButton(
          icon: Icon(
            Icons.payment,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AllPaymentPage()));
          },
        ),
      );

  buildHistoryNav() => IconButton(
        icon: Icon(
          Icons.history,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HistoryPage()));
        },
      );

  buildEditButton() => Container(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceReport(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            onPrimary: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: Text("Generate Report"),
        ),
      );

  buildLogoutButton() => Container(
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
        child: ElevatedButton.icon(
          onPressed: () {
            signOut(context);
          },
          icon: Icon(Icons.login),
          style: ElevatedButton.styleFrom(
            backgroundColor: ReggaeFitnessTheme.nearlyDarkBlue,
            foregroundColor: ReggaeFitnessTheme.nearlyWhite,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(16.0),
            ),
          ),
          label: Text(
            "LOG OUT",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0.0,
                color: ReggaeFitnessTheme.nearlyWhite),

          ),
        ),
      );
}
