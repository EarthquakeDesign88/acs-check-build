import 'package:flutter/material.dart';
import 'package:acs_check/utils/constants.dart';
import 'package:acs_check/widgets/bottom_navbar.dart';
import 'package:acs_check/widgets/big_text.dart';
import 'package:acs_check/widgets/small_text.dart';
import 'package:acs_check/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:acs_check/routes/route_helper.dart';
import 'package:acs_check/pages/job_schedule_page.dart';
import 'package:acs_check/models/work_shift_model.dart';
import 'package:acs_check/services/work_shift_service.dart';
import 'package:acs_check/services/job_schedule_service.dart';

class WorkShiftPage extends StatefulWidget {
  const WorkShiftPage({Key? key}) : super(key: key);

  @override
  _WorkShiftPageState createState() => _WorkShiftPageState();
}

class _WorkShiftPageState extends State<WorkShiftPage> {
  final AuthService authService = AuthService();
  final WorkShiftService workShiftService = WorkShiftService();
  final JobScheduleService jobScheduleService = JobScheduleService();

  int _currentIndex = 0;

  int? userId;
  String? username;
  String? firstName;
  String? lastName;
  String? roleName;
  String? lastLoginAt;

  bool isLoading = true;
  int countCompletedSchedules = 0;
  int completedSchedules  = 0;

  List<WorkShift>? workShifts;
  String? jobScheduleDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
    _fetchWorkShifts();
  }

  void _fetchWorkShifts() async {
    if (userId != null) {
      final currentDate = DateTime.now();
      final formattedDate = currentDate.toIso8601String().split('T')[0];
      // print(formattedDate);
      final shifts = await workShiftService.fetchWorkShifts(userId!, formattedDate);
      
      setState(() {
        workShifts = shifts;
        jobScheduleDate = formattedDate;
        isLoading = false;
      });

      final completedData = await jobScheduleService.fetchCompletedSchedules(userId!, formattedDate);

          
      if (completedData != null) {
        for (var item in completedData) {
          int totalJobSchedules = int.parse(item['total_job_schedules'].toString());
          int completedJobSchedules = int.parse(item['completed_job_schedules'].toString());
          
          if (totalJobSchedules == completedJobSchedules) {
            countCompletedSchedules++;
          }
        }

        setState(() {
          completedSchedules = countCompletedSchedules;
        });
      }
    }
  }

  void _navigateToJobSchedulePage(BuildContext context, int shiftId) {
    Get.to(
      () => JobSchedulePage(),
      arguments: {
        'userId': userId,
        'jobScheduleDate': jobScheduleDate,
        'jobScheduleShiftId': shiftId,
      },
      preventDuplicates: false, 
    );
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
    : Column(
        children: [
          if (workShifts != null && workShifts!.isNotEmpty) ...[
            SizedBox(height: Dimensions.height20),
            BigText(text: "ตารางงานวันนี้", size: Dimensions.font30),
            SizedBox(height: Dimensions.height20),
            BigText(
                text: "มีทั้งหมด ${workShifts?.length ?? 0} รอบ",
                size: Dimensions.font24),
            SizedBox(height: Dimensions.height20),
            isLoading
      ? CircularProgressIndicator() :
      completedSchedules == workShifts?.length 
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.successColor,
                    size: Dimensions.font22,
                  ),
                  SizedBox(width: 8),
                  BigText(
                    text: "ตรวจครบแล้ว",
                    size: Dimensions.font22,
                    color: AppColors.successColor,
                  ),
                ],
              )
            :  
            SmallText(
              text: "ตรวจไปแล้ว ($completedSchedules/${workShifts?.length ?? 0})",
              size: Dimensions.font20
            ),
            SizedBox(height: Dimensions.height20),
            Expanded(
              child: ListView.builder(
                itemCount: workShifts?.length ?? 0,
                itemBuilder: (context, index) {
                  final workShift = workShifts![index];
                  return _buildTimeSlotTile(
                    context,
                    workShift.shiftTimeSlot,
                    AppColors.mainColor,
                    workShift.jobScheduleShiftId
                  );
                },
              ),
            ),
          ],
          if (workShifts == null || workShifts!.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/no_schedule.png',
                      height: 200.0,
                      width: 200.0,
                    ),
                    SizedBox(height: Dimensions.height20),
                    BigText(
                      text: "ไม่มีตารางงานวันนี้",
                      size: Dimensions.font30,
                    ),
                    SizedBox(height: Dimensions.height10),
                    SmallText(
                      text:
                          "คุณไม่มีตารางงานสำหรับวันนี้ โปรดตรวจสอบอีกครั้งภายหลัง",
                      size: Dimensions.font20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: 0,
        onTabChanged: (index) {},
      ),
    );
  }

  Widget _buildLoading() {
    return CircularProgressIndicator();
  }

  Widget _buildTimeSlotTile(
      BuildContext context, String timeSlot, Color color, int shiftId) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Center(
          child: Text(
            timeSlot,
            style: TextStyle(fontSize: Dimensions.font18, color: Colors.white),
          ),
        ),
        onTap: () => _navigateToJobSchedulePage(context, shiftId)
      ),
    );
  }
}
