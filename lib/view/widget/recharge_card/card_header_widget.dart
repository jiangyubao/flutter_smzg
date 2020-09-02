import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/model/recharge_card.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/recharge_card_list_state.dart';

class CardHeaderWidget extends StatelessWidget {
  const CardHeaderWidget({
    Key key,
    @required this.rechargeCard,
  }) : super(key: key);

  final RechargeCard rechargeCard;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.delete),
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              if (await DialogService().nativeAlert("删除充值卡确认", "是否要删除该充值卡") ??
                  false) {
                await locator
                    .get<RechargeCardListState>()
                    .delete(rechargeCard.id);
              }
            }),
        Expanded(
          child: Text(
            '${rechargeCard.name}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Theme.of(context).accentColor,
                fontSize: 42.sp),
          ),
        ),
        IconButton(
            icon: Icon(Icons.edit),
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              await Routers().goRechargeCardForm(context, rechargeCard.id);
            }),
      ],
    );
  }
}
