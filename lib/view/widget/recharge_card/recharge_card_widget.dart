import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/model/recharge_card.dart';
import 'package:flutter_smzg/view/widget/recharge_card/card_body_widget.dart';
import 'package:flutter_smzg/view/widget/recharge_card/card_footer_widget.dart';
import 'package:flutter_smzg/view/widget/recharge_card/card_header_widget.dart';

///充值卡控件
class RechargeCardWidget extends StatelessWidget {
  final RechargeCard rechargeCard;
  const RechargeCardWidget({
    Key key,
    @required this.rechargeCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 8.h),
      child: Card(
        elevation: 30.h,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.h),
            bottomLeft: Radius.circular(28.h),
            bottomRight: Radius.circular(28.h),
            topRight: Radius.circular(4 * 28.h),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeaderWidget(rechargeCard: rechargeCard),
              Divider(),
              CardBodyWidget(rechargeCard: rechargeCard),
              Divider(),
              CardFooterWidget(rechargeCard: rechargeCard)
            ],
          ),
        ),
      ),
    );
  }
}
