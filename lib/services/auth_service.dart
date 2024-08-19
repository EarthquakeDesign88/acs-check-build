import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acs_check/utils/app_constants.dart';
import 'package:acs_check/models/user_model.dart';

class AuthService {
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.login}'),
        body: {
          'username': username,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('user')) {
          final Map<String, dynamic> userJson = responseData['user'];
          final user = User.fromJson(userJson);

          await _updateLoginStatus(user.userId, user.username, user.firstName, user.lastName, user.roleName, user.lastLoginAt);

          // print('Login success: ${response.statusCode} ${response.body}');

          return true;
        } else {
          print('Login failed with status code: ${response.statusCode}');
        }
      } 
      else if (response.statusCode == 401) {
        print('Login failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during login: $e');
    }

    return false;
  }

  Future<void> _updateLoginStatus(int userId, String username, String firstName, String lastName, String roleName, String lastLoginAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', userId);
    await prefs.setString('username', username);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('roleName', roleName);
    await prefs.setString('lastLoginAt', lastLoginAt);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('roleName');
    await prefs.remove('lastLoginAt');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firstName');
  }

  Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastName');
  }

  Future<String?> getRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('roleName');
  }

  Future<String?> getLastLoginAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastLoginAt');
  }
}
