import 'dart:io';
import 'package:acs_check/pages/location_details_page.dart';
import 'package:flutter/material.dart';
import 'package:acs_check/utils/constants.dart';
import 'package:acs_check/widgets/bottom_navbar.dart';
import 'package:acs_check/widgets/big_text.dart';
import 'package:acs_check/widgets/small_text.dart';
import 'package:acs_check/widgets/qr_scanner.dart';
import 'package:acs_check/services/auth_service.dart';
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

  int _currentIndex = 0;
  
  String scannedCode = '';

  int? userId;
  String? firstName;
  String? lastName;

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
    final storedFirstName = await authService.getFirstName();
    final storedLastName = await authService.getLastName();

    setState(() {
      firstName = storedFirstName;
      lastName = storedLastName;
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
    final statuses = await jobScheduleService.fetchJobStatus();

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
        if ((_images?.length ?? 0) + pickedImages.length > 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่สามารถอัปโหลดรูปภาพได้เกิน 3 รูป'),
              backgroundColor: AppColors.errorColor,
            ),
          );
          _images = (_images ?? []).sublist(0, 3);
        } else {
          _images = (_images ?? []) + pickedImages;
        }
      });
    }
  }

  Future<void> _takePicture() async {
    if ((_images?.length ?? 0) >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถถ่ายรูปได้เกิน 3 รูป'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (image != null) {
      setState(() {
        _images?.add(image);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images!.removeAt(index);
    });
  }

  void _showFullImage(BuildContext context, XFile imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            Image.file(File(imageFile.path), fit: BoxFit.contain),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.greyColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile imageFile, int index) {
    return GestureDetector(
      onTap: () => _showFullImage(context, imageFile),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: FileImage(File(imageFile.path)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Container(
                decoration: const BoxDecoration(
                  color: AppColors.errorColor,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: AppColors.whiteColor,
                  size: 20,
                ),
              ),
              onPressed: () {
                _removeImage(index);
              },
            ),
          ),
        ],
      ),
    );
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

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message']),
              backgroundColor: AppColors.successColor),
        );

        setState(() {
          saveSuccess = true;
          scannedCode = '';
          selectedJobStatusId = null;
          _images = [];
        });

        _loadJobSchedules();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message']),
              backgroundColor: AppColors.errorColor),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('พบข้อผิดพลาด โปรดลองใหม่อีกครั้งภายหลัง'),
          backgroundColor: AppColors.errorColor));
    }
  }

  void _navigateToLocationDetailsPage(BuildContext context, int jobAuthorityId,
      String jobScheduleDate, int jobScheduleShiftId) {
    Get.to(
      () => LocationDetailsPage(),
      arguments: {
        'jobAuthorityId': jobAuthorityId,
        'jobScheduleDate': jobScheduleDate,
        'jobScheduleShiftId': jobScheduleShiftId,
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
      body: isJobSchedulesLoading
          ? Center(child: CircularProgressIndicator()) : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: Dimensions.height20),
                Column(
                  children: [
                    BigText(
                      text: jobSchedules[0].workShiftDescription,
                      size: Dimensions.font34,
                    ),
                    SizedBox(height: Dimensions.height20),
                    SmallText(
                      text:
                          "ช่วงเวลาตั้งแต่ " + jobSchedules[0].shiftTimeSlot,
                      size: Dimensions.font28,
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                Visibility(
                  visible: countCheckedPoints != totalCheckpoint,
                  child: ElevatedButton(
                    onPressed: () async {
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRScanner(),
                        ));
                    
                        if (result is String && result.isNotEmpty) {
                          setState(() {
                            scannedCode = result;
                          });
                        }
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
                        text: scannedCode.isEmpty ? "สแกนจุดตรวจ" : "สแกนใหม่",
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
                          bool isActive =
                              selectedJobStatusId == status['job_status_id'];
                          bool isNoProblem =
                              status['job_status_description'] == 'ไม่พบปัญหา';
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
                        child: Row(
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
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _images!.isNotEmpty,
                        child: Column(
                          children: [
                            SizedBox(height: Dimensions.height20),
                            SizedBox(
                              height: 100,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                                itemCount: _images!.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Wrap(
                                        children: _images!
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int index = entry.key;
                                          XFile imageFile = entry.value;
                                          return _buildImagePreview(
                                              imageFile, index);
                                        }).toList(),
                                      ),
                                    ],
                                  );
                                },
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                            ),
                          ],
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
                                text:
                                    "ตรวจไปแล้ว (${countCheckedPoints}/${totalCheckpoint})",
                                size: Dimensions.font20,
                              )
                        : SmallText(
                            text: "ไม่พบข้อมูล",
                            size: Dimensions.font20,
                          ),
                SizedBox(height: Dimensions.height10),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  JobSchedule jobSchedule = jobSchedules[index];
                  Color checkpointColor;
                  Color hoverColor;

                  if (jobSchedule.jobScheduleStatusId == 3) {
                    checkpointColor = AppColors.mainColor.withOpacity(0.1);
                    hoverColor = AppColors.mainColor.withOpacity(0.2);
                  } 
                  else if (jobSchedule.jobScheduleStatusId == 1) {
                    checkpointColor = AppColors.successColor.withOpacity(0.6);
                    hoverColor = AppColors.successColor.withOpacity(0.8);
                  } 
                  else if (jobSchedule.jobScheduleStatusId == 2) {
                    checkpointColor = AppColors.errorColor.withOpacity(0.6);
                    hoverColor = AppColors.errorColor.withOpacity(0.8);
                  } else {
                    checkpointColor = Colors.grey.withOpacity(0.1);
                    hoverColor = Colors.grey.withOpacity(0.2); 
                  }


                  return MouseRegion(
                      onEnter: (_) => setState(() {
                            checkpointColor = hoverColor;
                          }),
                      onExit: (_) => setState(() {
                            checkpointColor =
                                jobSchedule.jobScheduleStatusId == 3
                                    ? AppColors.mainColor.withOpacity(0.1)
                                    : AppColors.successColor.withOpacity(0.6);
                          }),
                      child: GestureDetector(
                        onTap: () {
                          _navigateToLocationDetailsPage(
                            context,
                            jobSchedule.jobAuthorityId,
                            jobSchedule.jobScheduleDate,
                            jobSchedule.jobScheduleShiftId,
                          );
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('รายละเอียด'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SmallText(
                                      text:
                                          'พื้นที่: ${jobSchedule.zoneDescription}',
                                      color: AppColors.greyColor,
                                      size: Dimensions.font16,
                                    ),
                                    SmallText(
                                      text:
                                          'จุดตรวจ: ${jobSchedule.locationDescription}',
                                      color: AppColors.greyColor,
                                      size: Dimensions.font16,
                                    ),
                                    SmallText(
                                      text:
                                          'สถานะ: ${jobSchedule.jobScheduleStatusId == 3 ? 'ยังไม่ได้ตรวจสอบ' : 'ตรวจสอบแล้ว'}',
                                      color:
                                          jobSchedule.jobScheduleStatusId == 3
                                              ? AppColors.errorColor
                                              : AppColors.successColor,
                                      size: Dimensions.font16,
                                    )
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('ปิด'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
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
                        ),
                      ));
                },
                childCount: totalCheckpoint,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavbar(
      currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}
