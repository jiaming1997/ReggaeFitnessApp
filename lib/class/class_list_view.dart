import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:intl/intl.dart';
import 'package:reggae_fitness_studio/class/class_info_screen.dart';
import '../app_theme.dart';
import '../assets/constants.dart' as constants;
import 'package:http/http.dart' as http;

import '../widgets/custom_list.dart';

class ClassList extends StatefulWidget {
  const ClassList({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _ClassListState createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> with TickerProviderStateMixin {
  String selectedDate = '';

  Future getClass(String d) async {
    var url = "http://" + constants.IP_ADDRESS + "/reggaefitness/class_all.php";
    var response = await http.post(Uri.parse(url), body: {
      "filter_date": d,
    });
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Class List',
      home: Scaffold(
        backgroundColor: ReggaeFitnessTheme.background,
          appBar: CalendarAppBar(
            onDateChanged: (value) {
              setState(() {
                selectedDate = DateFormat("yyyy-MM-dd").format((value));
              });
            },
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 14)),
            backButton: false,
            padding: 5.0,
            white: ReggaeFitnessTheme.nearlyWhite, //text
            black: ReggaeFitnessTheme.dark_grey, //
            accent: ReggaeFitnessTheme.nearlyDarkBlue, //background
          ),
          body: SafeArea(
            minimum: const EdgeInsets.only(bottom: 62),
            child: FutureBuilder(
              future: getClass(selectedDate),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError){
                  return Text("Error");
                }else{
                  return snapshot.hasData
                      ? ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(right: 16, left: 16),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      List list = snapshot.data;
                      final date = DateTime.tryParse(list[index]['class_date']);
                      return Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassInfoScreen(
                                  item:list[index],
                                ),
                              ),
                            ),
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(16.0)),
                              color: ReggaeFitnessTheme.white,
                            ),
                            child: CustomList(
                              thumbnail: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(displayImage(
                                        list[index]['class_name'])),
                                  ),
                                ),
                              ),
                              class_name: list[index]['class_name'],
                              class_date: DateFormat("dd/MM/yyyy").format(date!),
                              start_time: DateFormat.jm().format(DateFormat("hh:mm:ss").parse(list[index]['start_time'])),
                              end_time: DateFormat.jm().format(DateFormat("hh:mm:ss").parse(list[index]['end_time'])),
                              class_capacity: list[index]['class_capacity'],
                            ),
                          ),
                        )
                      );
                    },
                  )
                      : const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )),
    );
  }

  String displayImage(String n) {
    var url = '';
    if (n == "Zumba") {
      return 'assets/images/zumba.png';
    } else if (n == "Strong Nation") {
      return 'assets/images/strong_nation.png';
    } else if (n == "Bootcamp") {
      return 'assets/images/bootcamp.png';
    } else {
      return url;
    }
  }
}
