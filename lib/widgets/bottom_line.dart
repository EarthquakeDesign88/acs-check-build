import 'package:flutter/material.dart';
import 'package:acs_check/utils/constants.dart';

class BottomLine extends StatelessWidget {
  final Color color;
  final double width;

  const BottomLine(
      {Key? key, this.color = AppColors.greyColor, this.width = 0.9})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: color, width: width),
          ),
        ),
      ),
    );
  }
}
