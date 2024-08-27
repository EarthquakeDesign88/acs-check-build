import 'package:flutter/material.dart';
import 'package:acs_check/utils/constants.dart';
import 'package:get/get.dart';
import 'package:acs_check/routes/route_helper.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const BottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: (int index) {
        if (index == 0) {
          Get.offNamed(RouteHelper.workSchedule);
        } 
        else {
          Get.offNamed(RouteHelper.historyJob);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.mainColor,
      unselectedItemColor: Colors.grey,
      backgroundColor: AppColors.whiteColor,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'ตารางงาน',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'ประวัติตรวจงาน',
        ),
      ],
    );
  }
}
