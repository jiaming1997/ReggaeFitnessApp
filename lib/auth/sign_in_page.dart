import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reggae_fitness_studio/auth/sign_up_page.dart';
import 'package:reggae_fitness_studio/components/background.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reggae_fitness_studio/home/main_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wc_form_validators/wc_form_validators.dart';
import 'package:validators/validators.dart';
import 'package:form_validator/form_validator.dart';
import '../assets/constants.dart' as constants;

class SignInPage extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  late SharedPreferences logindata;
  late bool newuser;

  bool _passwordVisible = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }
  void checkLogin() async {
    logindata = await SharedPreferences.getInstance();
    newuser = (logindata.getBool('login') ?? true);
    print(newuser);
    if (newuser == false) {
      Navigator.pushReplacement(
          context, new MaterialPageRoute(builder: (context) => MainHomePage()));
    }
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future signIn(BuildContext cont) async {
    if(email.text == "" || password.text == ""){
      Fluttertoast.showToast(
        msg: "Cannot be empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,);
    }
    else{
      var url = "http://"+constants.IP_ADDRESS+"/reggaefitness/login_user.php";
      var response = await http.post(Uri.parse(url), body: {
        "email": email.text,
        "password": password.text,
      });
      var data = json.decode(response.body);
      if (data['loginStatus']== true) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('email', data['userInfo']['u_email']);
        preferences.setString('uid', data['userInfo']['u_id']);
        preferences.setString('u_info', jsonEncode(data['userInfo']));
        Navigator.push(cont, MaterialPageRoute(builder: (context) => MainHomePage()));
      }
      else if(data['loginStatus']== false){
        Fluttertoast.showToast(
          msg: "Invalid email or password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,);
      }
    }
  }

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2661FA),
                      fontSize: 36
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

              SizedBox(height: size.height * 0.03),

              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                      labelText: "Email"
                  ),
                  controller: email,
                ),
              ),

              SizedBox(height: size.height * 0.03),

              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                      labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        _passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  controller: password,
                  obscureText: _passwordVisible,
                ),
              ),

              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0XFF2661FA)
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.05),

              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),

                child: ElevatedButton(
                  onPressed: () {
                    signIn(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    padding: const EdgeInsets.all(0),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    width: size.width * 0.5,
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: new LinearGradient(
                            colors: [
                              Color.fromARGB(255, 255, 136, 34),
                              Color.fromARGB(255, 255, 177, 41)
                            ]
                        )
                    ),
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      "LOGIN",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white,
                      ),
                    ),

                  ),
                ),
              ),

              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: GestureDetector(
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()))
                  },
                  child: Text(
                    "Don't Have an Account? Sign up",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2661FA)
                    ),
                  ),
                ),
              )
            ],
          ),
        )

      ),
    );
  }
}

