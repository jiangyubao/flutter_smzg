import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/model/recharge_card.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/recharge_card_list_state.dart';

class CardBodyWidget extends StatelessWidget {
  const CardBodyWidget({
    Key key,
    @required this.rechargeCard,
  }) : super(key: key);

  final RechargeCard rechargeCard;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '充值额度：${rechargeCard.init}元',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 28.sp),
              ),
              SizedBox(
                height: 32.h,
              ),
              Text(
                '剩余额度：${rechargeCard.current}元',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 28.sp),
              ),
              SizedBox(
                height: 32.h,
              ),
              Text(
                '过期时间：${rechargeCard.expiredDate.replaceAll('-', '/')}',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 28.sp),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 0.h),
          child: Column(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    int value =
                        await Routers().goBalanceForm(context, "请输入充值金额", 0);
                    if (value == null) {
                      return;
                    }
                    rechargeCard.init += value;
                    rechargeCard.current += value;
                    await locator
                        .get<RechargeCardListState>()
                        .update(rechargeCard);
                  }),
              IconButton(
                icon: Icon(Icons.remove_circle),
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  int value =
                      await Routers().goBalanceForm(context, "请输入消费金额", 0);
                  if (value == null) {
                    return;
                  }
                  if (rechargeCard.current < value) {
                    await DialogService()
                        .nativeAlert("消费金额不能大于当前余额", "请重新输入消费金额", ok: "确定");
                    return;
                  }
                  rechargeCard.current -= value;
                  await locator
                      .get<RechargeCardListState>()
                      .update(rechargeCard);
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 667.h / 2.5,
          width: 375.w / 2.5,
          child: InkWell(
            onTap: () async {
              await Routers().goImageDisplay(context, rechargeCard.id);
            },
            child: Image.memory(rechargeCard.image),
          ),
        ),
      ],
    );
  }
}
