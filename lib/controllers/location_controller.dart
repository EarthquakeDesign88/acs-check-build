import 'package:get/get.dart';
import 'package:acs_check/utils/app_constants.dart';
import 'package:acs_check/models/location_model.dart';
import 'package:acs_check/services/location_service.dart';
import 'package:acs_check/services/job_schedule_service.dart';
import 'package:acs_check/services/auth_service.dart';

class LocationController extends GetxController {
  final AuthService authService = AuthService();
  final LocationService locationService = LocationService();
  final JobScheduleService jobImageService = JobScheduleService();

  RxInt currentIndex = 0.obs;
  RxBool isLoading = true.obs;
  RxBool showImages = false.obs;

  RxList<Location> locationDetails = <Location>[].obs;
  RxList<Map<String, dynamic>> images = <Map<String, dynamic>>[].obs;

  String? firstName;
  String? lastName;
  int? userId;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadLocationDetails();
  }

  Future<void> _loadUserData() async {
    try {
      userId = await authService.getUserId();
      firstName = await authService.getFirstName();
      lastName = await authService.getLastName();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadLocationDetails() async {
    isLoading.value = true;

    try {
      final arguments = Get.arguments as Map<String, dynamic>;
      final jobAuthorityId = arguments['jobAuthorityId'];
      final jobScheduleDate = arguments['jobScheduleDate'];
      final jobScheduleShiftId = arguments['jobScheduleShiftId'];

      final fetchedLocationDetails = await locationService.fetchLocationDetails(
        jobAuthorityId, jobScheduleDate, jobScheduleShiftId
      );

      locationDetails.value = fetchedLocationDetails ?? [];
    } catch (e) {
      print('Error loading location details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchImagesAndShowDialog(int jobScheduleId) async {
    try {
      final fetchedImages = await jobImageService.fetchImagesJob(jobScheduleId);
      images.value = List<Map<String, dynamic>>.from(fetchedImages ?? []);
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  void onTabChanged(int index) {
    currentIndex.value = index;
  }

  void toggleImageVisibility() {
    showImages.value = !showImages.value;
  }
}
