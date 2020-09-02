import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:flutter_smzg/service/stateless/md_service.dart';

//用户条款和隐私协议对话框
class UserAgreementWidget extends StatefulWidget {
  const UserAgreementWidget();
  @override
  _UserAgreementWidgetState createState() => _UserAgreementWidgetState();
}

class _UserAgreementWidgetState extends State<UserAgreementWidget> {
  static const _userAgreement =
      "    欢迎使用口袋卡包APP！在你使用时，需要连接数据网络或WLAN网络，所产生的流量费用请咨询当地运营商。本APP非常重视你的隐私保护和个人信息。在你使用本APP前，请认真阅读http://《服务条款》 和http://《隐私政策》 全部条款，你同意并接受全部条款后再开始使用本APP。\n    本APP可能会用到以下信息，你可以在设备系统“设置”里进行相关权限信息管理。\n    为了让你更好的体验，我们可能会定期给你推送充值卡有效期相关的通知提醒。为了方便我们进行APP使用统计，本APP会申请读取你的设备状态、设备IDFA、IDFV等标识。当APP需要填充充值卡照片表单时，本APP会申请使用你的相机、相册照片等信息。";
  int _counter = 8;
  Timer _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _counter = _counter - 1;
        });
        if (_counter < 0) {
          _timer?.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 180.h),
        child: Card(
          elevation: 8,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "温馨提示",
                  style: TextStyle(fontSize: 36.sp),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  child: Linkify(
                    onOpen: (link) async {
                      if (link.text == "《服务条款》") {
                        await Routers().goThridPartWebView(
                          context,
                          await MdService().buildMarkdownFileUrl(
                              context, "assets/users/ua.md"),
                        );
                      } else if (link.text == "《隐私政策》") {
                        await Routers().goThridPartWebView(
                          context,
                          await MdService().buildMarkdownFileUrl(
                              context, "assets/users/pp.md"),
                        );
                      }
                    },
                    text: _userAgreement,
                    style: TextStyle(fontSize: 28.sp),
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CupertinoButton(
                        child: Text("不同意${_counter > 0 ? '（$_counter）' : ''}"),
                        onPressed: _counter > 0
                            ? null
                            : () async {
                                await DialogService().nativeAlert(
                                    "重要提醒", "请同意并接受《服务条款》和《隐私政策》全部条款后再开始使用",
                                    ok: "确定");
                              }),
                    CupertinoButton(
                        padding: EdgeInsets.all(28.w),
                        child:
                            Text("同意并继续${_counter > 0 ? '（$_counter）' : ''}"),
                        color: Theme.of(context).primaryColor,
                        onPressed: _counter > 0
                            ? null
                            : () async {
                                await locator
                                    .get<PasswordCardListState>()
                                    .updateShowUserAgreement(false);
                              }),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
