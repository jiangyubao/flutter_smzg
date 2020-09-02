import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';

class CardBodyWidget extends StatelessWidget {
  const CardBodyWidget({
    Key key,
    @required this.passwordCard,
  }) : super(key: key);

  final PasswordCard passwordCard;

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
                '充值额度：${passwordCard.userName}元',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 28.sp),
              ),
              SizedBox(
                height: 32.h,
              ),
              Text(
                '剩余额度：${passwordCard.sitePassword}元',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 28.sp),
              ),
              SizedBox(
                height: 32.h,
              ),
              Text(
                '过期时间：${passwordCard.notes.replaceAll('-', '/')}',
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
                    await locator
                        .get<PasswordCardListState>()
                        .update(passwordCard);
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

                  await locator
                      .get<PasswordCardListState>()
                      .update(passwordCard);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
