import 'package:acs_check/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:acs_check/utils/constants.dart';
import 'package:acs_check/widgets/bottom_navbar.dart';
import 'package:acs_check/widgets/big_text.dart';
import 'package:acs_check/widgets/small_text.dart';
import 'package:acs_check/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:acs_check/routes/route_helper.dart';
import 'package:intl/intl.dart';
import 'package:acs_check/services/location_service.dart';
import 'package:acs_check/models/location_model.dart';

class LocationDetailsPage extends StatefulWidget {
  const LocationDetailsPage({Key? key}) : super(key: key);

  @override
  State<LocationDetailsPage> createState() => _LocationDetailsPageState();
}

class _LocationDetailsPageState extends State<LocationDetailsPage> {
  final AuthService authService = AuthService();
  final LocationService locationService = LocationService();

  int _currentIndex = 0;

  int? userId;
  String? username;
  String? firstName;
  String? lastName;
  String? roleName;
  String? lastLoginAt;

  bool isLoading = false;

  List<Location> locationDetails = [];

  Widget _buildLoading() {
    return CircularProgressIndicator();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLocationDetails();
  }

  void _loadUserData() async {
    final storedUserId = await authService.getUserId();
    final storedUsername = await authService.getUsername();
    final storedFirstName = await authService.getFirstName();
    final storedLastName = await authService.getLastName();
    final storedRoleName = await authService.getRoleName();
    final storedLastLoginAt = await authService.getLastLoginAt();

    setState(() {
      userId = storedUserId;
      username = storedUsername;
      firstName = storedFirstName;
      lastName = storedLastName;
      roleName = storedRoleName;
      lastLoginAt = storedLastLoginAt;
    });
  }

  void _loadLocationDetails() async {
    setState(() {
      isLoading = true;
    });

    final arguments = Get.arguments as Map<String, dynamic>;
    final jobAuthorityId = arguments['jobAuthorityId'];
    final jobScheduleDate = arguments['jobScheduleDate'];
    final jobScheduleShiftId = arguments['jobScheduleShiftId'];

    final fetchedLocationDetails = await locationService.fetchLocationDetails(
        jobAuthorityId, jobScheduleDate, jobScheduleShiftId);

    setState(() {
      locationDetails = fetchedLocationDetails ?? [];
      isLoading = false;
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: locationDetails.length,
              itemBuilder: (context, index) {
                final location = locationDetails[index];
                return Container(
                    margin: EdgeInsets.symmetric(vertical: Dimensions.height10),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5.0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'พื้นที่:',
                          location.zoneDescription,
                          AppColors.greyColor,
                        ),
                        _buildDetailRow(
                          'บริเวณ:',
                          location.locationDescription,
                          AppColors.greyColor,
                        ),
                        _buildDetailRow(
                          'สถานะ:',
                          location.jobStatusId != 3
                              ? "ตรวจสอบแล้ว"
                              : "ยังไม่ได้ตรวจสอบ",
                          location.jobStatusId != 3
                              ? AppColors.successColor
                              : AppColors.errorColor,
                        ),
                        if (location.jobStatusId != 3)
                          _buildDetailRow(
                            'รายละเอียดสถานะ:',
                            location.jobStatusDescription,
                            AppColors.greyColor,
                          ),
                           _buildDetailRow(
                            'ตรวจสอบเวลา:',
                            location.inspectionCompletedAt,
                            AppColors.greyColor,
                          ),                  
                      ],
                    ));
              },
            ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: 0,
        onTabChanged: (index) {},
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value, Color? color) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.height10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
                fontSize: Dimensions.font16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'ไม่พบข้อมูล',
              style: TextStyle(
                color: color,
                fontSize: Dimensions.font16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
