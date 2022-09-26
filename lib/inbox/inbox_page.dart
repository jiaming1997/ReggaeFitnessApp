import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:intl/intl.dart';
import 'package:reggae_fitness_studio/app_theme.dart';
import 'package:reggae_fitness_studio/class/class_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/constants.dart' as constants;
import 'package:http/http.dart' as http;
import '../models/history.dart';
import '../widgets/custom_list.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with TickerProviderStateMixin {
  String selectedDate = '';
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

  Future userClass() async{
    var url = "http://" + constants.IP_ADDRESS + "/reggaefitness/unpaid_class.php";
    var response = await http.post(Uri.parse(url), body: {
      "u_id": id,
    });
    var data = json.decode(response.body);
    List<History> h = [];
    for (var i in data) {
      History history = History(i["class_id"], i["class_date"],i["class_name"], i["status"]);
      h.add(history);
    }
    return h;
  }

  Future joinedClass() async{
    var url = "http://" + constants.IP_ADDRESS + "/reggaefitness/joined_class.php";
    var response = await http.post(Uri.parse(url), body: {
      "u_id": id,
    });
    var data = json.decode(response.body);
    List<History> h = [];
    for (var i in data) {
      History history = History(i["class_id"], i["class_date"],i["class_name"], i["status"]);
      h.add(history);
    }
    return h;
  }

  Future inQueueClass() async{
    var url = "http://" + constants.IP_ADDRESS + "/reggaefitness/in_queue_class.php";
    var response = await http.post(Uri.parse(url), body: {
      "u_id": id,
    });
    var data = json.decode(response.body);
    List<History> h = [];
    for (var i in data) {
      History history = History(i["class_id"], i["class_date"],i["class_name"], i["status"]);
      h.add(history);
    }
    return h;
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
        backgroundColor: ReggaeFitnessTheme.nearlyDarkBlue,
        centerTitle: true,
        title: new Text('Inbox'),
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
                    new Tab(text: "Joined"),
                    new Tab(text: "In-Queue"),
                    new Tab(text: "Unpaid")
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  //controller: _tabController,
                  children: [
                    BuildJoined(),
                    BuildInQueue(),
                    BuildUnpaid(),
                  ],
                ),
              ),
            ],
          )),

    );
  }

  BuildUnpaid() => Container(
    child: SafeArea(
      minimum: const EdgeInsets.only(bottom: 62),
      child: FutureBuilder(
        future: userClass(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData){
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              padding:
              const EdgeInsets.only(top: 16, right: 16, left: 16),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                List list = snapshot.data;
                return Card(
                  child: ListTile(
                    leading: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 88,
                        minHeight: 88,
                        maxWidth: 128,
                        maxHeight: 128,
                      ),
                      child: Image.asset(displayImage(list[index].classname), fit: BoxFit.cover),
                    ),
                    title: Text(list[index].classname),
                    subtitle: Text(list[index].date),
                    trailing: Text(list[index].status),
                  ),
                );
              },
            );
          }else{
            return Text("");
          }
        },
      ),
    ),
  );

  BuildInQueue() => Container(
    child: SafeArea(
      minimum: const EdgeInsets.only(bottom: 62),
      child: FutureBuilder(
        future: inQueueClass(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData){
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              padding:
              const EdgeInsets.only(top: 16, right: 16, left: 16),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                List list = snapshot.data;
                return Card(
                  child: ListTile(
                    leading: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 88,
                        minHeight: 88,
                        maxWidth: 128,
                        maxHeight: 128,
                      ),
                      child: Image.asset(displayImage(list[index].classname), fit: BoxFit.cover),
                    ),
                    title: Text(list[index].classname),
                    subtitle: Text(list[index].date),
                    trailing: Text(list[index].status),
                  ),
                );
              },
            );
          }else{
            return Text("Nothing to show");
          }
        },
      ),
    ),
  );

  BuildJoined() => Container(
    child: SafeArea(
      minimum: const EdgeInsets.only(bottom: 62),
      child: FutureBuilder(
        future: joinedClass(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData){
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              padding:
              const EdgeInsets.only(top: 16, right: 16, left: 16),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                List list = snapshot.data;
                return Card(
                  child: ListTile(
                    leading: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 88,
                        minHeight: 88,
                        maxWidth: 128,
                        maxHeight: 128,
                      ),
                      child: Image.asset(displayImage(list[index].classname), fit: BoxFit.cover),
                    ),
                    title: Text(list[index].classname),
                    subtitle: Text(list[index].date),
                    trailing: Text(list[index].status),
                  ),
                );
              },
            );
          }else{
            return Text("");
          }
        },
      ),
    ),
  );

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
