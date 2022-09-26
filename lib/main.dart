import 'package:flutter/material.dart';
import 'package:reggae_fitness_studio/auth/sign_in_page.dart';
import 'package:reggae_fitness_studio/auth/sign_up_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home/main_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var email = preferences.getString('email');
  runApp(MaterialApp(home: email == null? MyApp() : MainHomePage()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reggae Fitness Studio by VA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInPage(),
    );
  }
}
