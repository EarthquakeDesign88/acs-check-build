import 'package:acs_check/utils/app_constants.dart';
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
import 'package:acs_check/services/job_schedule_service.dart';
import 'package:acs_check/services/location_service.dart';

class LocationDetailsPage extends StatefulWidget {
  const LocationDetailsPage({Key? key}) : super(key: key);

  @override
  State<LocationDetailsPage> createState() => _LocationDetailsPageState();
}

class _LocationDetailsPageState extends State<LocationDetailsPage> {
  final AuthService authService = AuthService();
  final LocationService locationService = LocationService();
  final JobScheduleService jobImageService = JobScheduleService();

  int _currentIndex = 0;

  int? userId;
  String? firstName;
  String? lastName;

  bool isLoading = false;
  bool showImages = false;

  List<Location> locationDetails = [];
  List<Map<String, dynamic>> images = [];

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
    final storedFirstName = await authService.getFirstName();
    final storedLastName = await authService.getLastName();

    setState(() {
      userId = storedUserId;
      firstName = storedFirstName;
      lastName = storedLastName;
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

  Future<void> _fetchImagesAndShowDialog(int jobScheduleId) async {
    final fetchedImages = await jobImageService.fetchImagesJob(jobScheduleId);

    setState(() {
      images = List<Map<String, dynamic>>.from(fetchedImages ?? []);
      isLoading = false;
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
              title: SmallText(text: "ประวัติตรวจงาน", size: Dimensions.font18),
              onTap: () {
                Get.offNamed(RouteHelper.historyJob);
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
                          'จุดตรวจ:',
                          location.locationDescription,
                          AppColors.greyColor,
                        ),
                        _buildDetailRow(
                          'สถานะ:',
                          location.jobStatusId != 3
                              ? "ตรวจสอบแล้ว"
                              : "ยังไม่ได้ตรวจสอบ",
                          location.jobStatusId != 3
                              ? AppColors.greyColor
                              : AppColors.errorColor,
                        ),
                        if (location.jobStatusId != 3)
                          _buildDetailRow(
                            'รายละเอียดสถานะ:',
                            location.jobStatusDescription,
                            location.jobStatusId == 1
                                ? AppColors.successColor
                                : AppColors.errorColor,
                          ),
                        _buildDetailRow(
                          'ตรวจสอบเวลา:',
                          location.inspectionCompletedAt,
                          AppColors.greyColor,
                        ),
                        if (location.jobStatusId == 2) ...[
                          SizedBox(height: Dimensions.height10),
                          ElevatedButton(
                            onPressed: () async {
                              await _fetchImagesAndShowDialog(location.jobScheduleId);

                              setState(() {
                                showImages = !showImages;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainColor,
                              elevation: 3,
                              padding: const EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: SmallText(
                              text: showImages ? "ปิด" : "ดูรูปภาพปัญหา",
                              size: Dimensions.font18,
                              color: AppColors.whiteColor,
                            ),
                          ),
                          SizedBox(height: Dimensions.height10),
                        ],
                        Visibility(
                          visible: showImages,
                          child: Column(
                            children: [
                              if (images.isNotEmpty)
                                ...images.map((image) {
                                  String imagePath = image['image_path'];
                                  if (!imagePath.startsWith('http')) {
                                    imagePath = '${AppConstants.baseUrl}/storage/$imagePath';
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Image.network(imagePath),
                                  );
                                }).toList()
                              else
                                SmallText(
                                  text: "ไม่มีรูปภาพ",
                                  size: Dimensions.font16,
                                  color: AppColors.greyColor,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ));
              },
            ),
     bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
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
