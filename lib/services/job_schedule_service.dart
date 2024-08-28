import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:acs_check/models/job_schedule_model.dart';
import 'package:acs_check/utils/app_constants.dart';
import 'package:image_picker/image_picker.dart';

class JobScheduleService {
  Future<List<JobSchedule>?> fetchJobSchedule(
      int userId, String currentDate, int jobScheduleShiftId) async {
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

  Future<int?> countCheckedPoints(
      int userId, String currentDate, int jobScheduleShiftId) async {
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

  Future<List<Map<String, dynamic>>?> fetchJobStatus() async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.jobStatus}');

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

  Future<Map<String, dynamic>> saveInspectionResult({
    required int userId,
    required String jobScheduleDate,
    required int jobScheduleShiftId,
    required int jobScheduleStatusId,
    required String locationQR,
    required DateTime inspectionCompletedAt,
    required List<XFile> images,
  }) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${AppConstants.baseUrl}${AppConstants.saveInspectionResult}'));

    request.fields['user_id'] = userId.toString();
    request.fields['job_schedule_date'] = jobScheduleDate;
    request.fields['job_schedule_shift_id'] = jobScheduleShiftId.toString();
    request.fields['job_schedule_status_id'] = jobScheduleStatusId.toString();
    request.fields['location_qr'] = locationQR;
    request.fields['inspection_completed_at'] =
        inspectionCompletedAt.toIso8601String();

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('images_path[]', image.path));
    }

    try {
      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);
      var responseData = json.decode(responseBody.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Failed to save inspection result'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error saving inspection result: $e'};
    }
  }

  Future<List<Map<String, dynamic>>?> fetchCompletedSchedules(
      int userId, String date) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}${AppConstants.countCompletedSchedules}?user_id=$userId&job_schedule_date=$date'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List<dynamic>;
        return responseData.map((item) {
          return {
            'job_schedule_date': item['job_schedule_date'],
            'job_schedule_shift_id': item['job_schedule_shift_id'],
            'work_shift_description': item['work_shift_description'],
            'shift_time_slot': item['shift_time_slot'],
            'total_job_schedules': item['total_job_schedules'],
            'completed_job_schedules': item['completed_job_schedules'],
          };
        }).toList();
      } else {
        print('Failed to fetch completed schedules');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
    return null;
  }

  Future<List<dynamic>?> fetchImagesJob(int jobScheduleId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.fetchImagesJob}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'job_schedule_id': jobScheduleId}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        return responseData;
      } else {
        print('Failed to load images job');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
    return null;
  }


  Future<List<JobSchedule>?> fetchJobSchedulesHistory(
    int userId, String date, int? jobScheduleShiftId, int? jobScheduleStatusId) async {
      try {
        final response = await http.post(
          Uri.parse('${AppConstants.baseUrl}${AppConstants.fetchJobScheduleHistory}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'job_schedule_date': date,
            'job_schedule_shift_id': jobScheduleShiftId,
            'job_schedule_status_id': jobScheduleStatusId
          }),
        );

        if (response.statusCode == 200) {
          final List<dynamic> responseData = json.decode(response.body);
          // print('Response Data: $responseData');
          return responseData.map((data) => JobSchedule.fromJson(data)).toList();
        } else {
          print('Failed to load job history');
        }
      } catch (e) {
        print('Error during API call: $e');
      }
      return null;
    }

  }
