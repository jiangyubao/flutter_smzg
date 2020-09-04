import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/view/widget/password_card/card_body_widget.dart';
import 'package:flutter_smzg/view/widget/password_card/card_footer_widget.dart';
import 'package:flutter_smzg/view/widget/password_card/card_header_widget.dart';

///密码卡控件
class PasswordCardWidget extends StatelessWidget {
  final PasswordCard passwordCard;
  const PasswordCardWidget({
    Key key,
    @required this.passwordCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 8.h),
      child: Card(
        elevation: 16.h,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.w),
            bottomLeft: Radius.circular(8.w),
            bottomRight: Radius.circular(8.w),
            topRight: Radius.circular(8.w),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeaderWidget(passwordCard: passwordCard),
              Divider(),
              CardBodyWidget(passwordCard: passwordCard),
              CardFooterWidget(passwordCard: passwordCard)
            ],
          ),
        ),
      ),
    );
  }
}
