import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:acs_check/models/job_schedule_model.dart';
import 'package:acs_check/utils/app_constants.dart';

class JobScheduleService {
  Future<List<JobSchedule>?> fetchJobSchedule(int userId, String currentDate, int jobScheduleShiftId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.jobSchedule}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'job_schedule_date': currentDate,
          'job_schedule_shift_id': jobScheduleShiftId
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        // print('Response Data: $responseData');
        return responseData.map((data) => JobSchedule.fromJson(data)).toList();
      } else {
        print('Failed to load job schedule');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
    return null;
  }

  Future<int?> countCheckedPoints(int userId, String currentDate, int jobScheduleShiftId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.countCheckedPoints}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'job_schedule_date': currentDate,
          'job_schedule_shift_id': jobScheduleShiftId
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;

        int countCheckedPoints = responseData['checked_points_count'];

        return countCheckedPoints;
      } else {
        print('Failed to count checked points');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> fetchJobStatus(
    int userId, String currentDate, int jobScheduleShiftId) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.jobStatus}').replace(queryParameters: {
        'user_id': userId.toString(),
        'job_schedule_date': currentDate,
        'job_schedule_shift_id': jobScheduleShiftId.toString(),
      });

     final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        json.decode(response.body) as List<dynamic>,
      );
    } else {
      print('Failed to load job statuses');
    }
    } catch (e) {
      print('Error during API call: $e');
    }
    return null;
  }
}
