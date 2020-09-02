import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/model/password_card.dart';

class CardFooterWidget extends StatelessWidget {
  const CardFooterWidget({
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
          '联系电话：${passwordCard.mobile}',
          style: TextStyle(
              fontWeight: FontWeight.w600, letterSpacing: 0.5, fontSize: 28.sp),
        ),
        SizedBox(
          height: 16.h,
        ),
        Text(
          '联系地址：${passwordCard.address}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.w600, letterSpacing: 0.5, fontSize: 28.sp),
        ),
      ],
    );
  }
}
