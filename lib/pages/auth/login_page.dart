import 'package:flutter/material.dart';
import 'package:acs_check/utils/constants.dart';
import 'package:acs_check/utils/app_constants.dart';
import 'package:acs_check/widgets/big_text.dart';
import 'package:acs_check/widgets/custom_button.dart';
import 'package:acs_check/widgets/small_text.dart';
import 'package:acs_check/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:acs_check/routes/route_helper.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  late AuthService authService = AuthService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Widget _buildLoading() {
    return CircularProgressIndicator();
  }

  Future<void> _showErrorSnackBar(String message) async {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(fontSize: Dimensions.font16),
      ),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    authService = AuthService();
  }

  Widget build(BuildContext context) {
    Dimensions.init(context);
    final currentYear = DateTime.now().year;

     return FutureBuilder(
      future: null,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 8),
                const Text(
                  "ACS Check",
                  style: TextStyle(color: AppColors.whiteColor),
                ),
              ],
            ),
            backgroundColor: AppColors.mainColor,
          ),
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BigText(text: "เข้าสู่ระบบ"),
                    SizedBox(height: Dimensions.height10),
                    Container(
                      width: 320, // Set the desired width
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.blackColor),
                        ),
                      ),
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          hintText: 'บัญชีผู้ใช้งาน',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),
                    Container(
                      width: 320,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.blackColor),
                        ),
                      ),
                      child: TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          hintText: 'รหัสผ่าน',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),
                    // แสดง loading หาก isLoading เป็น true
                    isLoading ? _buildLoading() : CustomButton(
                      bgColor: AppColors.mainColor,
                      text: 'เข้าสู่ระบบ',
                      routeTo: () async {
                        final username = usernameController.text;
                        final password = passwordController.text;

                        if (username.isEmpty) {
                          _showErrorSnackBar('กรุณากรอกบัญชีผู้ใช้งาน');
                          return;
                        }
                        else if (password.isEmpty) {
                          _showErrorSnackBar('กรุณากรอกรหัสผ่าน');
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        final success = await authService.login(username, password);

                        setState(() {
                          isLoading = false; 
                        });

                        if (success) {
                          Get.offNamed(RouteHelper.workSchedule);
                        } else {
                          _showErrorSnackBar(
                              'ไม่สามารถเข้าสู่ระบบได้ กรุณาลองใหม่อีกครั้ง');
                        }
                        return;
                      },
                    ),
                    SizedBox(height: Dimensions.height5),
                    SmallText(
                      text: "App version ${AppConstants.appVersion}",
                      size: Dimensions.font16,
                      color: AppColors.greyColor,
                    ),
                    SizedBox(height: Dimensions.height5),
                    SmallText(
                      text: "©$currentYear Tuk Chang All rights reserved",
                      size: Dimensions.font16,
                      color: AppColors.greyColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
