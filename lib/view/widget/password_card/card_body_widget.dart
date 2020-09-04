import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/model/password_card.dart';

class CardBodyWidget extends StatelessWidget {
  const CardBodyWidget({
    Key key,
    @required this.passwordCard,
  }) : super(key: key);

  final PasswordCard passwordCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '登录账号：${passwordCard.userName}',
          style: TextStyle(
              fontWeight: FontWeight.w600, letterSpacing: 0.5, fontSize: 28.sp),
        ),
        SizedBox(
          height: 16.h,
        ),
        Text(
          '登录密码：${passwordCard.sitePassword}',
          style: TextStyle(
              fontWeight: FontWeight.w600, letterSpacing: 0.5, fontSize: 28.sp),
        ),
      ],
    );
  }
}
