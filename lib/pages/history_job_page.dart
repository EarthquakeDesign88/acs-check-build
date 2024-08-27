import 'dart:io';
import 'package:flutter/material.dart';
import 'package:acs_check/utils/constants.dart';
import 'package:acs_check/widgets/bottom_navbar.dart';
import 'package:acs_check/widgets/big_text.dart';
import 'package:acs_check/widgets/small_text.dart';
import 'package:acs_check/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:acs_check/routes/route_helper.dart';
import 'package:acs_check/models/job_schedule_model.dart';
import 'package:acs_check/services/job_schedule_service.dart';


class HistoryJobPage extends StatefulWidget {
  const HistoryJobPage({Key? key}) : super(key: key);

  @override
  State<HistoryJobPage> createState() => _HistoryJobPageState();
}


class _HistoryJobPageState extends State<HistoryJobPage> {
  final AuthService authService = AuthService();
  final JobScheduleService jobScheduleService = JobScheduleService();

  int _currentIndex = 0;

  int? userId;
  String? firstName;
  String? lastName;

  bool isLoading = false;

  List<JobSchedule> jobSchedules = [];

  
  Widget _buildLoading() {
    return CircularProgressIndicator();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final storedFirstName = await authService.getFirstName();
    final storedLastName = await authService.getLastName();

    setState(() {
      firstName = storedFirstName;
      lastName = storedLastName;
    });
  }


  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "ACS Check",
            style: TextStyle(color: AppColors.whiteColor),
          ),
          backgroundColor: AppColors.mainColor,
          iconTheme: IconThemeData(color: AppColors.whiteColor),
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.mainColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: Dimensions.width80,
                      height: Dimensions.height80,
                    ),
                    SizedBox(height: Dimensions.height10),
                    const Text(
                      "ACS Check",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: SmallText(
                    text: "$firstName $lastName", size: Dimensions.font18),
              ),
              ListTile(
                title: SmallText(text: "ตารางงาน", size: Dimensions.font18),
                onTap: () {
                  Get.toNamed(RouteHelper.workSchedule);
                },
              ),
              ListTile(
                title: SmallText(text: "ประวัติสแกน", size: Dimensions.font18),
                onTap: () {
                  Get.toNamed(RouteHelper.timeSlotDetail);
                },
              ),
              ListTile(
                title: SmallText(text: "Logout", size: Dimensions.font18),
                onTap: () async {
                  await authService.logout();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Get.offAllNamed(RouteHelper.login);
                  });
                },
              ),
            ],
          ),
        ),
        body: Center(
          child: Container(
            child: BigText(text: "History Job"),
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          currentIndex: _currentIndex,
          onTabChanged: _onTabChanged,
        ),
        );
  }
}
