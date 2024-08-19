import 'package:flutter/material.dart';
import 'package:acs_check/utils/constants.dart';
import 'package:acs_check/widgets/big_text.dart';

class CustomButton extends StatelessWidget {
  final double? size;
  final Color? bgColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;
  final String? text;
  final IconData? icon;
  final Function? routeTo;

  const CustomButton({
    Key? key,
    this.size = 50,
    this.bgColor = AppColors.mainColor,
    this.borderColor = AppColors.mainColor,
    this.iconColor = AppColors.whiteColor,
    this.textColor = AppColors.whiteColor,
    required this.text,
    this.icon,
    this.routeTo
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: 320,
      color: bgColor,
      child: MaterialButton(
          height: size,
          onPressed: routeTo != null ? routeTo! as void Function() : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            side: BorderSide(
              color: borderColor!,
              width: 2,
            ),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null && iconColor != null)
              Icon(
                icon,
                color: iconColor,
              ),
            SizedBox(width: Dimensions.width5),
            BigText(text: text!, size: Dimensions.font18, color: textColor),
          ]
        )
      )
    );
  }
}
