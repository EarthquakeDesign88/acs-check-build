import 'package:get/get.dart';
import 'package:acs_check/pages/auth/login_page.dart';
import 'package:acs_check/pages/work_shift_page.dart';
import 'package:acs_check/pages/job_schedule_page.dart';
import 'package:acs_check/pages/location_details_page.dart';

class RouteHelper {
  static String initial = "/";
  static String login = "/login";
  static String workSchedule = "/work_schedule";
  static String timeSlotDetail = "/time_slot_detail";

  static List<GetPage> routes = [
    GetPage(name: workSchedule, page: () => WorkShiftPage()),
    GetPage(name: timeSlotDetail, page: () => JobSchedulePage()),
    GetPage(name: login, page: () => LogInPage()),
  ];
}
