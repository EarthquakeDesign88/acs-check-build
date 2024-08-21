import 'package:flutter/material.dart';

class AppColors {
  static const Color mainColor = Color.fromARGB(255, 0, 78, 142);
  static const Color mainLightColor = Color.fromARGB(255, 120, 164, 207);
  static const Color blackColor = Color(0xFF000000);
  static const Color darkGreyColor = Color(0xFF757575);
  static const Color greyColor = Color(0xFF979797);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
}

class Dimensions {
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;

  // Heights
  static double height2 = 0.0;
  static double height5 = 0.0;
  static double height10 = 0.0;
  static double height15 = 0.0;
  static double height20 = 0.0;
  static double height30 = 0.0;
  static double height40 = 0.0;
  static double height50 = 0.0;
  static double height60 = 0.0;
  static double height70 = 0.0;
  static double height80 = 0.0;

  // Widths
  static double width2 = 0.0;
  static double width5 = 0.0;
  static double width10 = 0.0;
  static double width15 = 0.0;
  static double width20 = 0.0;
  static double width30 = 0.0;
  static double width40 = 0.0;
  static double width50 = 0.0;
  static double width60 = 0.0;
  static double width70 = 0.0;
  static double width80 = 0.0;

  // Radius
  static double radius10 = 0.0;
  static double radius15 = 0.0;
  static double radius20 = 0.0;
  static double radius50 = 0.0;

  //icon Size
  static double iconSize30 = 0.0;
  static double iconSize40 = 0.0;

  // Font sizes
  static double font14 = 0.0;
  static double font16 = 0.0;
  static double font18 = 0.0;
  static double font20 = 0.0;
  static double font22 = 0.0;
  static double font24 = 0.0;
  static double font26 = 0.0;
  static double font28 = 0.0;
  static double font30 = 0.0;
  static double font34 = 0.0;
  static double font36 = 0.0;

  // Initialize constants based on screen sizes
  static void init(BuildContext context) {
    // Screen sizes for Height 781, Width 393
    final Size screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;

    // Calculate heights based on screen sizes
    height2 = screenHeight / 390.5;
    height5 = screenHeight / 156.2;
    height10 = screenHeight / 78.1;
    height15 = screenHeight / 52.06;
    height20 = screenHeight / 39.05;
    height30 = screenHeight / 26.03;
    height40 = screenHeight / 19.52;
    height50 = screenHeight / 15.62;
    height60 = screenHeight / 13.01;
    height70 = screenHeight / 11.15;
    height80 = screenHeight / 9.76;

    // Calculate widths based on screen sizes
    width2 = screenWidth / 196.5;
    width5 = screenWidth / 78.6;
    width10 = screenWidth / 39.3;
    width15 = screenWidth / 26.2;
    width20 = screenWidth / 19.65;
    width30 = screenWidth / 13.1;
    width40 = screenWidth / 9.82;
    width50 = screenWidth / 7.86;
    width60 = screenWidth / 6.55;
    width70 = screenWidth / 5.61;
    width80 = screenWidth / 4.91;

    //Radius
    radius10 = screenHeight / 78.1;
    radius15 = screenHeight / 52.06;
    radius20 = screenHeight / 39.05;
    radius50 = screenHeight / 15.62;

    //Icons
    iconSize30 = screenHeight / 26.03;
    iconSize40 = screenHeight / 19.52;

    // Calculate font sizes based on screen sizes
    font14 = screenHeight / 55.78;
    font16 = screenHeight / 48.81;
    font18 = screenHeight / 43.38;
    font20 = screenHeight / 39.05;
    font22 = screenHeight / 35.5;
    font24 = screenHeight / 32.54;
    font26 = screenHeight / 30.03;
    font28 = screenHeight / 27.89;
    font30 = screenHeight / 26.03;
    font34 = screenHeight / 22.97;
    font36 = screenHeight / 21.69;
  }
}
