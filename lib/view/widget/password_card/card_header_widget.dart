import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';

class CardHeaderWidget extends StatelessWidget {
  const CardHeaderWidget({
    Key key,
    @required this.passwordCard,
  }) : super(key: key);

  final PasswordCard passwordCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${passwordCard.nickName}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontSize: 32.sp),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              size: 28.sp,
            ),
            onPressed: () async {
              if (await DialogService().nativeConfirm("删除密码卡确认", "是否要删除该密码卡",
                      ok: "是", cancel: "否") ??
                  false) {
                await locator
                    .get<PasswordCardListState>()
                    .delete(passwordCard.id);
              }
            },
          ),
          SizedBox(
            width: 16.w,
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              size: 28.sp,
            ),
            onPressed: () async {
              await Routers().goPasswordCardForm(context, passwordCard.id);
            },
          ),
          SizedBox(
            width: 16.w,
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              size: 28.sp,
            ),
            onPressed: () async {},
          ),
          SizedBox(
            width: 16.w,
          ),
          IconButton(
            icon: Icon(
              Icons.print,
              size: 28.sp,
            ),
            onPressed: () async {},
          ),
        ],
      ),
    );
  }
}
