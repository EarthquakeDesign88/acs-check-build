import 'dart:io';
import 'package:flutter/material.dart';
import 'package:acs_check/utils/constants.dart';
import 'package:acs_check/widgets/bottom_navbar.dart';
import 'package:acs_check/widgets/big_text.dart';
import 'package:acs_check/widgets/small_text.dart';
import 'package:acs_check/services/auth_service.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:acs_check/routes/route_helper.dart';
import 'package:acs_check/models/job_schedule_model.dart';
import 'package:acs_check/services/job_schedule_service.dart';
import 'package:image_picker/image_picker.dart';

class JobSchedulePage extends StatefulWidget {
  const JobSchedulePage({Key? key}) : super(key: key);

  @override
  _JobSchedulePageState createState() => _JobSchedulePageState();
}

class _JobSchedulePageState extends State<JobSchedulePage> {
  final AuthService authService = AuthService();
  final JobScheduleService jobScheduleService = JobScheduleService();
  final ImagePicker _picker = ImagePicker();

  String scannedCode = 'อาตาร C_2_QR';

  int _currentIndex = 0;

  int? userId;
  String? username;
  String? firstName;
  String? lastName;
  String? roleName;
  String? lastLoginAt;

  bool isLoading = false;
  bool isJobSchedulesLoading = false;

  List<JobSchedule> jobSchedules = [];
  List<Map<String, dynamic>> jobStatuses = [];

  int totalCheckpoint = 0;
  int countCheckedPoints = 0;

  int? selectedJobStatusId;

  List<XFile>? _images = [];

  Widget _buildLoading() {
    return CircularProgressIndicator();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadJobSchedules();
    _fetchJobStatus();
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

  void _loadJobSchedules() async {
    setState(() {
      isJobSchedulesLoading = true;
    });

    final arguments = Get.arguments as Map<String, dynamic>;
    final int userId = arguments['userId'];
    final String jobScheduleDate = arguments['jobScheduleDate'];
    final int jobScheduleShiftId = arguments['jobScheduleShiftId'];

    final fetchedSchedules = await jobScheduleService.fetchJobSchedule(
        userId, jobScheduleDate, jobScheduleShiftId);

    final fetchedCountCheckedPoints = await jobScheduleService
        .countCheckedPoints(userId, jobScheduleDate, jobScheduleShiftId);

    setState(() {
      jobSchedules = fetchedSchedules ?? [];
      totalCheckpoint = jobSchedules.length;
      countCheckedPoints = fetchedCountCheckedPoints ?? 0;
      isJobSchedulesLoading = false;
    });
  }

  Future<void> _fetchJobStatus() async {
    final arguments = Get.arguments as Map<String, dynamic>;
    final int userId = arguments['userId'];
    final String jobScheduleDate = arguments['jobScheduleDate'];
    final int jobScheduleShiftId = arguments['jobScheduleShiftId'];

    final statuses = await jobScheduleService.fetchJobStatus(
        userId, jobScheduleDate, jobScheduleShiftId);

    setState(() {
      jobStatuses = statuses
              ?.where((status) =>
                  status['job_status_description'] == 'พบปัญหา' ||
                  status['job_status_description'] == 'ไม่พบปัญหา')
              .toList() ??
          [];
    });
  }

  Future<void> _pickImages() async {
    // Allow user to pick up to 3 images
    final pickedImages = await _picker.pickMultiImage(imageQuality: 100);

    if (pickedImages != null) {
      setState(() {
        _images = (_images ?? []) + pickedImages;
        if (_images!.length > 3) {
          _images = _images!.sublist(0, 3);
        }
      });
    }
  }

  Future<void> _takePicture() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (image != null) {
      setState(() {
        if (_images!.length < 3) {
          _images!.add(image);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images!.removeAt(index);
    });
  }

  Future<void> _onConfirmInspection() async {
    final arguments = Get.arguments as Map<String, dynamic>;
    final int userId = arguments['userId'];
    final String jobScheduleDate = arguments['jobScheduleDate'];
    final int jobScheduleShiftId = arguments['jobScheduleShiftId'];

    bool saveSuccess = true; 
    
    if (selectedJobStatusId == 2 && (_images == null || _images!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาถ่ายหรืออัพโหลดรูปภาพปัญหา'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    if (_images != null && _images!.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถอัปโหลดรูปภาพได้เกิน 3 รูป'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

      try {
        final response = await jobScheduleService.saveInspectionResult(
          userId: userId,
          jobScheduleDate: jobScheduleDate,
          jobScheduleShiftId: jobScheduleShiftId, 
          jobScheduleStatusId: selectedJobStatusId!,
          locationQR: scannedCode, 
          inspectionCompletedAt: DateTime.now(),
          images: _images ?? [],
        );

        if(response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: AppColors.successColor
            ),
          );

          setState(() {
            saveSuccess = true;
            scannedCode = '';
            selectedJobStatusId = null;
            _images = [];
          });
          
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: AppColors.errorColor
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('พบข้อผิดพลาด โปรดลองใหม่อีกครั้งภายหลัง'),
            backgroundColor: AppColors.errorColor
          )
        );
      }
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
              title: SmallText(text: "ออกจากระบบ", size: Dimensions.font18),
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
      body: Builder(
        builder: (context) => Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: Dimensions.height20),
                  isJobSchedulesLoading
                      ? CircularProgressIndicator()
                      : jobSchedules.isNotEmpty
                          ? Column(
                              children: [
                                BigText(
                                  text: jobSchedules[0].workShiftDescription,
                                  size: Dimensions.font34,
                                ),
                                SizedBox(height: Dimensions.height20),
                                SmallText(
                                  text: "ช่วงเวลาตั้งแต่ " + jobSchedules[0].shiftTimeSlot,
                                  size: Dimensions.font28,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                BigText(
                                  text: 'ไม่พบข้อมูล',
                                  size: Dimensions.font30,
                                ),
                                SizedBox(height: Dimensions.height20),
                                SmallText(
                                  text: 'ไม่พบข้อมูล',
                                  size: Dimensions.font30,
                                ),
                              ],
                            ),
                  SizedBox(height: Dimensions.height20),
                  Visibility(
                    visible:  countCheckedPoints != totalCheckpoint,
                    child: ElevatedButton(
                    onPressed: () async {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SimpleBarcodeScannerPage(),
                          ));
                      setState(() {
                        if (res is String) {
                          scannedCode = res;
                        }
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
                        text: scannedCode.isEmpty
                            ? "สแกนจุดตรวจ"
                            : "สแกนใหม่",
                        color: AppColors.whiteColor),
                  ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  Visibility(
                    visible: scannedCode.isNotEmpty,
                    child: Column(
                      children: [
                        SmallText(
                          text: "รหัสคิวอาร์โค้ด: $scannedCode",
                          size: Dimensions.font20,
                          color: AppColors.mainColor,
                        ),
                        SizedBox(height: Dimensions.height10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: jobStatuses.map((status) {
                            bool isActive = selectedJobStatusId == status['job_status_id'];
                            bool isNoProblem = status['job_status_description'] == 'ไม่พบปัญหา';
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedJobStatusId = status['job_status_id'];
                                    if (selectedJobStatusId == 1) {
                                      _images = [];
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive
                                      ? (isNoProblem
                                          ? AppColors.successColor
                                          : AppColors.errorColor)
                                      : AppColors.greyColor,
                                  elevation: 3,
                                  padding: const EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: SmallText(
                                    text: status['job_status_description'],
                                    size: Dimensions.font20,
                                    color: AppColors.whiteColor),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: Dimensions.height20),
                        Visibility(
                          visible: selectedJobStatusId == 2,
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _takePicture,
                                child: Text("ถ่ายรูป"),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _pickImages,
                                child: Text("อัปโหลดรูปภาพ"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),
                        Visibility(
                          visible: selectedJobStatusId != null,
                          child: ElevatedButton(
                            onPressed: () => _onConfirmInspection(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mainColor,
                                elevation: 3,
                                padding: const EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                )),
                            child: SmallText(
                              text: "ยืนยันการตรวจสอบ",
                              size: Dimensions.font20,
                              color: AppColors.whiteColor
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),
                        Visibility(
                          visible: _images!.isNotEmpty,
                          child: SizedBox(
                            height: 100,
                            child: GridView.builder(
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0, 
                                mainAxisSpacing: 8.0, 
                              ),
                              itemCount: _images!.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(
                                    File(_images![index].path),
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(), 
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height10),
                  isJobSchedulesLoading
                      ? CircularProgressIndicator()
                      : jobSchedules.isNotEmpty
                          ? countCheckedPoints == totalCheckpoint
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
                            : SmallText(
                                text: "ตรวจไปแล้ว (${countCheckedPoints}/${totalCheckpoint})",
                                size: Dimensions.font20,
                              )
                        : SmallText(
                            text: "ไม่พบข้อมูล",
                            size: Dimensions.font20,
                          ),
                  SizedBox(height: Dimensions.height10),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: totalCheckpoint,
                      itemBuilder: (context, index) {
                        JobSchedule jobSchedule = jobSchedules[index];

                        Color checkpointColor =
                            jobSchedule.jobStatusDescription ==
                                    'ยังไม่ได้ตรวจสอบ'
                                ? AppColors.mainColor.withOpacity(0.1)
                                : AppColors.successColor.withOpacity(0.6);

                        return Container(
                          decoration: BoxDecoration(
                            color: checkpointColor,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: checkpointColor,
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: BigText(
                              text: '${index + 1}',
                              size: Dimensions.font18,
                              color: AppColors.blackColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}
