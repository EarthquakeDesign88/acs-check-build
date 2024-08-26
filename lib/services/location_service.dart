import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:acs_check/models/location_model.dart';
import 'package:acs_check/utils/app_constants.dart';

class LocationService {
  Future<List<Location>?> fetchLocationDetails(int jobAuthorityId, String jobScheduleDate, int jobScheduleShiftId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.fetchLocationDetails}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'job_authority_id': jobAuthorityId,
          'job_schedule_date': jobScheduleDate,
          'job_schedule_shift_id': jobScheduleShiftId
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        // print('Response Data: $responseData'); 
        return responseData.map((data) => Location.fromJson(data)).toList();
      } else {
        print('Failed to load location details');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
    return null;
  }
}
