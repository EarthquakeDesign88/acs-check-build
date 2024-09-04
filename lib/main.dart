import 'package:flutter/material.dart';
import 'package:acs_check/pages/work_shift_page.dart';
import 'package:acs_check/pages/auth/login_page.dart';
import 'package:acs_check/services/auth_service.dart';
import 'package:acs_check/utils/constants.dart';
import 'package:get/get.dart';
import 'package:acs_check/routes/route_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    Dimensions.init(context);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ACS Check",
      theme: ThemeData(
        primaryColor: AppColors.mainColor,
      ),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: FutureBuilder<bool>(
        future: authService.isLoggedIn(),
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? WorkShiftPage() : LogInPage();
        },
      ),
      getPages: RouteHelper.routes
    );
  }
}
