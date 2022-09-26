import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reggae_fitness_studio/app_theme.dart';
import 'package:reggae_fitness_studio/class/class_list_view.dart';
import 'package:reggae_fitness_studio/components/background.dart';
import 'package:reggae_fitness_studio/profile/user_profile.dart';

import '../bottom_bar_navigation/bottom_bar_view.dart';
import '../models/tabIcon_data.dart';


class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHomePage> with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: Colors.white,
  );

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = ClassList(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {},
          changeIndex: (int index) {
            if (index == 0) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      ClassList(animationController: animationController);
                });
              });
            } else if (index == 1) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      UserProfile(animationController: animationController);
                });
              });
            }
          },
        ),
      ],
    );
  }
}


