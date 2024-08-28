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
import 'package:acs_check/services/work_shift_service.dart';
import 'package:acs_check/models/work_shift_model.dart';
import 'package:intl/intl.dart';
import 'package:acs_check/utils/app_constants.dart';

class HistoryJobPage extends StatefulWidget {
  const HistoryJobPage({Key? key}) : super(key: key);

  @override
  State<HistoryJobPage> createState() => _HistoryJobPageState();
}

class _HistoryJobPageState extends State<HistoryJobPage> {
  final AuthService authService = AuthService();
  final JobScheduleService jobScheduleService = JobScheduleService();
  final WorkShiftService workShiftService = WorkShiftService();

  int _currentIndex = 0;

  int? userId;
  String? firstName;
  String? lastName;

  bool isLoading = false;
  bool showImages = false;


  List<JobSchedule> jobSchedules = [];
  List<WorkShift> workShifts = [];
  List<Map<String, dynamic>> statuses = [];
  List<Map<String, dynamic>> images = [];

  DateTime? _selectedDate;
  String? _selectedShift;
  String? _selectedStatus;
  int? selectedJobScheduleId;

  Widget _buildLoading() {
    return CircularProgressIndicator();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadWorkShifts();
    _loadStatuses();
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

  Future<void> _loadWorkShifts() async {
    final fetchedWorkShifts = await workShiftService.fetchWorkShifts();
    if (fetchedWorkShifts != null) {
      setState(() {
        workShifts = fetchedWorkShifts;
      });
    }
  }

  Future<void> _loadStatuses() async {
    final fetchedStatuses = await jobScheduleService.fetchJobStatus();
    if (fetchedStatuses != null) {
      setState(() {
        statuses =
            List<Map<String, dynamic>>.from(fetchedStatuses.map((status) => {
                  'job_status_id': status['job_status_id'].toString(),
                  'job_status_description': status['job_status_description'],
                }));
      });
    }
  }

  void _searchJobSchedules() async {
  if (_selectedDate == null) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ข้อผิดพลาด"),
          content: const Text("กรุณาเลือกวันที่ตรวจสอบก่อนทำการค้นหา"),
          actions: [
            TextButton(
              child: const Text("ตกลง"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return; 
  }


    setState(() {
      isLoading = true;
    });

    var formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    if (userId != null && _selectedDate != null) {
      var fetchedJobSchedulesHistory =
          await jobScheduleService.fetchJobSchedulesHistory(
              userId!,
              formattedDate,
               _selectedShift != null ? int.parse(_selectedShift!) : null,
               _selectedStatus != null ? int.parse(_selectedStatus!) : null,
              );

      setState(() {
        jobSchedules = fetchedJobSchedulesHistory ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Some required parameters are null');
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _fetchImagesAndShowDialog(int jobScheduleId) async {
    final fetchedImages = await jobScheduleService.fetchImagesJob(jobScheduleId);

    setState(() {
      images = List<Map<String, dynamic>>.from(fetchedImages ?? []);
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
          iconTheme: IconThemeData(color: AppColors.whiteColor)),
      drawer: _buildDrawer(),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchFilters(context),
              const SizedBox(height: 16),
              isLoading
                  ? CircularProgressIndicator()
                  : Expanded(child: _buildJobSchedulesList()),
            ],
          )
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
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
    );
  }

  Widget _buildSearchFilters(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "เลือกวันที่ตรวจสอบ",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _selectedDate == null
                      ? ''
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "เลือกช่วงเวลา",
                  border: OutlineInputBorder(),
                ),
                items: workShifts.map((WorkShift shift) {
                  return DropdownMenuItem<String>(
                    value: shift.workShiftId.toString(),
                    child: Text(shift.shiftTimeSlot),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedShift = newValue;
                  });
                },
                value: _selectedShift,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "เลือกสถานะ",
            border: OutlineInputBorder(),
          ),
          items: statuses.map((status) {
            return DropdownMenuItem<String>(
              value: status['job_status_id'].toString(),
              child: Text(status['job_status_description']),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedStatus = newValue;
            });
          },
          value: _selectedStatus,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _searchJobSchedules,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainColor,
            elevation: 3,
            padding: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: SmallText(text: "ค้นหา", color: AppColors.whiteColor),
        ),
      ],
    );
  }

  Widget _buildJobSchedulesList() {
    return ListView.builder(
      itemCount: jobSchedules.length,
      itemBuilder: (context, index) {
        JobSchedule jobSchedule = jobSchedules[index];

        return ListTile(
          title: BigText(
            text: "จุดตรวจ: ${jobSchedule.locationDescription}",
            size: Dimensions.font18,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallText(text: "พื้นที่: ${jobSchedule.zoneDescription}", color: AppColors.greyColor, size: Dimensions.font16),
              SizedBox(height: Dimensions.height5),
              SmallText(text: "สถานะ: ${jobSchedule.jobStatusDescription}", color: AppColors.greyColor, size: Dimensions.font16),
              SizedBox(height: Dimensions.height5),
              if (jobSchedule.jobScheduleStatusId != 3)
                SmallText(text: "ตรวจสอบเวลา: ${jobSchedule.inspectionCompletedAt}", color: AppColors.greyColor, size: Dimensions.font16),
              if (jobSchedule.jobScheduleStatusId == 2) ...[
                SizedBox(height: Dimensions.height10),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      selectedJobScheduleId = jobSchedule.jobScheduleId;
                      isLoading = true;
                    });


                    await _fetchImagesAndShowDialog(selectedJobScheduleId!);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    elevation: 3,
                    padding: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: SmallText(
                    text: selectedJobScheduleId == jobSchedule.jobScheduleId ? "ปิด" : "ดูรูปภาพปัญหา",
                    size: Dimensions.font16,
                    color: AppColors.whiteColor,
                  ),
                ),
                SizedBox(height: Dimensions.height5),
              ],
              Visibility(
                visible: selectedJobScheduleId == jobSchedule.jobScheduleId,
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
          )
        );
      },
    );
  }
}
