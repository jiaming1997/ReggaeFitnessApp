import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reggae_fitness_studio/auth/sign_in_page.dart';
import 'package:reggae_fitness_studio/components/background.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:wc_form_validators/wc_form_validators.dart';
import '../assets/constants.dart' as constants;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController cpassword = TextEditingController();
  TextEditingController phone = TextEditingController();

  bool _passwordVisible = true;
  bool _cpasswordVisible = true;

  Future signUp(BuildContext cont) async {
    if (name.text == "" ||
        password.text == "" ||
        email.text == "" ||
        phone.text == "" ||
        cpassword.text == "") {
      Fluttertoast.showToast(
        msg: "Cannot be empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    } else {
      var url =
          "http://" + constants.IP_ADDRESS + "/reggaefitness/register_user.php";
      var response = await http.post(Uri.parse(url), body: {
        "name": name.text,
        "email": email.text,
        "password": password.text,
        "phone": phone.text,
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
            cont, MaterialPageRoute(builder: (context) => SignInPage()));
      } else if (data == "Error") {
        Fluttertoast.showToast(
          msg: "The data is existed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
          child: Form(
        key: _form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "SIGN UP",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2661FA),
                    fontSize: 36),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                controller: name,
                decoration: InputDecoration(labelText: "Name"),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                controller: email,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email address';
                  }
                  // Check if the entered email has the right format
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  // Return null if the entered email is valid
                  return null;
                },
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                controller: password,
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
                obscureText: _passwordVisible,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                controller: cpassword,
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
                validator: (value) {
                  if (value == '' && value == null) {
                    return 'Empty';
                  }
                  if (value != password.text) {
                    return 'Password does not match';
                  }
                  return null;
                },
                obscureText: _cpasswordVisible,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                controller: phone,
                decoration: InputDecoration(labelText: "Phone Number"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  // Return null if the entered password is valid
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    signUp(context);
                  } else {
                    print('unsuccessful');
                  };
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
                      gradient: new LinearGradient(colors: [
                        Color.fromARGB(255, 255, 136, 34),
                        Color.fromARGB(255, 255, 177, 41)
                      ])),
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    "Sign Up",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
              child: GestureDetector(
                onTap: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInPage()))
                },
                child: Text(
                  "Already registered? Sign in",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2661FA)),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
