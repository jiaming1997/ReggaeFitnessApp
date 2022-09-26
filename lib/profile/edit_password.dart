import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:reggae_fitness_studio/home/main_home_page.dart';
import 'package:reggae_fitness_studio/profile/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../assets/constants.dart' as constants;

// This class handles the Page to edit the Email Section of the User Profile.
class EditPasswordFormPage extends StatefulWidget {
  const EditPasswordFormPage({Key? key}) : super(key: key);

  @override
  _EditPasswordFormPageState createState() => _EditPasswordFormPageState();
}

class _EditPasswordFormPageState extends State<EditPasswordFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _currentpasswordVisible = true;
  bool _newpasswordVisible = true;
  bool _cpasswordVisible = true;
  final currentpasswordController = TextEditingController();
  final newpasswordController = TextEditingController();
  final cpasswordController = TextEditingController();
  String user_info = '';
  String id = '';

  @override
  void dispose() {
    currentpasswordController.dispose();
    newpasswordController.dispose();
    cpasswordController.dispose();
    super.dispose();
  }

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_info = preferences.getString('u_info')!;
      Map<String, dynamic> map = jsonDecode(user_info);
      id = map['u_id'];
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  Future updateUsername(BuildContext cont) async {
    if (currentpasswordController.text == "" ||
        newpasswordController.text == "" ||
        cpasswordController.text == "") {
      Fluttertoast.showToast(
        msg: "Cannot be empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    } else {
      var url = "http://" +
          constants.IP_ADDRESS +
          "/reggaefitness/update_password.php";
      var response = await http.post(Uri.parse(url), body: {
        "u_id": id,
        "old_password": currentpasswordController.text,
        "new_password": newpasswordController.text,
        "c_password": cpasswordController.text,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: ReggaeFitnessTheme.nearlyDarkBlue,
        title: Text("Edit"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 24),
            SizedBox(
              width: 320,
              child: const Text(
                "Enter Password",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: ReggaeFitnessTheme.nearlyBlack,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                    height: 80,
                    width: 320,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Current Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _currentpasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _currentpasswordVisible =
                                  !_currentpasswordVisible;
                            });
                          },
                        ),
                      ),
                      controller: currentpasswordController,
                      // Handles Form Validation
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        // Return null if the entered password is valid
                        return null;
                      },
                      obscureText: _currentpasswordVisible,
                    ))),
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                    height: 80,
                    width: 320,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "New Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _newpasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _newpasswordVisible = !_newpasswordVisible;
                            });
                          },
                        ),
                      ),
                      // Handles Form Validation
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        if (value.trim().length < 8) {
                          return 'Password must be at least 8 characters in length';
                        }
                        // Return null if the entered password is valid
                        return null;
                      },
                      controller: newpasswordController,
                      obscureText: _newpasswordVisible,
                    ))),
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                    height: 80,
                    width: 320,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _cpasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _cpasswordVisible = !_cpasswordVisible;
                            });
                          },
                        ),
                      ),
                      // Handles Form Validation
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        if (value != newpasswordController.text) {
                          return 'Password does not match';
                        }
                        // Return null if the entered password is valid
                        return null;
                      },
                      controller: cpasswordController,
                      obscureText: _cpasswordVisible,
                    ))),
            Padding(
              padding: EdgeInsets.only(top:80, bottom: 100),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 320,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        updateUsername(context);
                      } else {
                        print('unsuccessful');
                      }
                      ;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ReggaeFitnessTheme.nearlyDarkBlue,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(16.0),
                      ),
                    ),
                    child: const Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
