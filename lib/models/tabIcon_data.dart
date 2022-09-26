import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    this.imagePath = '',
    this.index = 0,
    this.selectedImagePath = '',
    this.isSelected = false,
    this.animationController,
  });

  String imagePath;
  String selectedImagePath;
  bool isSelected;
  int index;

  AnimationController? animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      imagePath: 'assets/images/workout_1.png',
      selectedImagePath: 'assets/images/workout_2.png',
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/user_1.png',
      selectedImagePath: 'assets/images/user_2.png',
      index: 1,
      isSelected: false,
      animationController: null,
    ),
  ];
}
