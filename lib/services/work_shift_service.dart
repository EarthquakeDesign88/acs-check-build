import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:acs_check/models/work_shift_model.dart';
import 'package:acs_check/utils/app_constants.dart';

class WorkShiftService {
  Future<List<WorkShift>?> fetchWorkShifts(int userId, String currentDate) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.workShift}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'job_schedule_date': currentDate,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        // print('Response Data: $responseData'); 
        return responseData.map((data) => WorkShift.fromJson(data)).toList();
      } else {
        print('Failed to load work shifts');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
    return null;
  }
}
