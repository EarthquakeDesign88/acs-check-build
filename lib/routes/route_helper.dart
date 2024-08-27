import 'package:get/get.dart';
import 'package:acs_check/pages/auth/login_page.dart';
import 'package:acs_check/pages/work_shift_page.dart';
import 'package:acs_check/pages/job_schedule_page.dart';
import 'package:acs_check/pages/history_job_page.dart';

class RouteHelper {
  static String initial = "/";
  static String login = "/login";
  static String workSchedule = "/work_schedule";
  static String timeSlotDetail = "/time_slot_detail";
  static String historyJob = "/history_job";

  static List<GetPage> routes = [
    GetPage(name: workSchedule, page: () => WorkShiftPage()),
    GetPage(name: timeSlotDetail, page: () => JobSchedulePage()),
    GetPage(name: login, page: () => LogInPage()),
    GetPage(name: historyJob, page: () => HistoryJobPage()),
  ];
}
