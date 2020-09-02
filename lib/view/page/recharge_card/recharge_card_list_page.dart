import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/recharge_card_list_state.dart';
import 'package:flutter_smzg/service/stateless/markdown_service.dart';
import 'package:flutter_smzg/view/widget/recharge_card/recharge_card_widget.dart';
import 'package:flutter_smzg/view/widget/user_agreement_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pie_chart/pie_chart.dart';

class RechargeCardListPage extends StatefulWidget {
  const RechargeCardListPage();
  @override
  _RechargeCardListPageState createState() => _RechargeCardListPageState();
}

class _RechargeCardListPageState extends State<RechargeCardListPage> {
  void _switchDarkMode(BuildContext context, ThemeState themeState) {
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      //showToast("检测到系统为暗黑模式,已为你自动切换", position: ToastPosition.bottom);
      DialogService().nativeAlert("温馨提示", "检测到系统为暗黑模式,已为你自动切换");
    } else {
      themeState.switchTheme(
          userDarkMode: Theme.of(context).brightness == Brightness.light);
    }
  }

  Future<String> _buildVersionString() async {
    final String appVersion = await PlatformService().getAppVersion();
    return "$appVersion";
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Consumer2<RechargeCardListState, ThemeState>(
        builder: (context, rechargeCardListState, themeState, child) {
          return rechargeCardListState.showUserAgreement
              ? UserAgreementWidget()
              : Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: const Text("口袋卡包"),
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            try {
                              await Routers().goRechargeCardForm(context, -1);
                            } catch (e, s) {
                              Logger.printErrorStack(e, s);
                            }
                          })
                    ],
                  ),
                  drawer: this
                      ._buildDrawer(context, themeState, rechargeCardListState),
                  body: WillPopScope(
                    onWillPop: () async {
                      if (rechargeCardListState.lastPressed == null ||
                          DateTime.now().difference(
                                  rechargeCardListState.lastPressed) >
                              Duration(seconds: 1)) {
                        //两次点击间隔超过1秒则重新计时
                        rechargeCardListState.lastPressed = DateTime.now();
                        return false;
                      }
                      return true;
                    },
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (rechargeCardListState.busy) {
                                return SkeletonList(
                                  builder: (context, index) => SkeletonItem(),
                                );
                              }
                              if (rechargeCardListState.error &&
                                  rechargeCardListState.list.isEmpty) {
                                return ViewStateErrorWidget(
                                    error: rechargeCardListState.pageStateError,
                                    onPressed: rechargeCardListState.initData);
                              }
                              if (rechargeCardListState.empty) {
                                return ViewStateEmptyWidget(
                                    image: Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: SizedBox(
                                        height: 200.h,
                                        width: 200.w,
                                        child: Icon(
                                          Icons.error,
                                          size: 200.h,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withAlpha(180),
                                        ),
                                      ),
                                    ),
                                    buttonText: Text(
                                      "立即创建",
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                          fontSize: 32.sp),
                                    ),
                                    message: "卡包为空，请创建充值卡",
                                    onPressed: () async {
                                      try {
                                        await Routers()
                                            .goRechargeCardForm(context, -1);
                                      } catch (e, s) {
                                        Logger.printErrorStack(e, s);
                                      }
                                    });
                              }
                              return SmartRefresher(
                                controller:
                                    rechargeCardListState.refreshController,
                                header: const WaterDropHeader(),
                                footer: const ClassicFooter(),
                                onRefresh: () async {
                                  await rechargeCardListState.refresh(
                                      init: true);
                                },
                                onLoading: () async {
                                  await rechargeCardListState.loadMore();
                                },
                                enablePullUp: true,
                                child: ListView.builder(
                                  itemCount: rechargeCardListState.list.length,
                                  itemBuilder: (context, index) {
                                    return RechargeCardWidget(
                                      rechargeCard:
                                          rechargeCardListState.list[index],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Future<int> _getId() async {
    var iosDeviceInfo = await PlatformService().getDeviceInfo();
    return iosDeviceInfo.name.hashCode;
  }

  Future<bool> _jverifyCheck() async {
    try {
      if (await JVerifyService().isInitSuccess() == false) {
        await DialogService().nativeAlert("一键登录SDK初始化失败", "请重新启动");
        return false;
      }
      if (await JVerifyService().checkVerifyEnable() == false) {
        await DialogService().nativeAlert("不支持一键登录", "请开启4G网络");
        return false;
      }
      return true;
    } catch (e, s) {
      Logger.printErrorStack(e, s);
      return false;
    }
  }

  Future<String> _getAuthToken(int phoneId) async {
    try {
      Map<dynamic, dynamic> map = await JVerifyService().loginAuth(context);
      if (map != null) {
        if (map['code'] == 6000) {
          String message = map['message'];
          return await JssService().auth("$phoneId", message);
        }
      }
    } catch (e, s) {
      Logger.printErrorStack(e, s);
    }
    return null;
  }

  Widget _buildDrawer(BuildContext context, ThemeState themeState,
      RechargeCardListState rechargeCardListState) {
    double totalCurrent =
        locator.get<RechargeCardListState>().totalCurrent().toDouble();
    double totalInit =
        locator.get<RechargeCardListState>().totalInit().toDouble();
    double totalConsume = totalInit - totalCurrent;
    return InkWell(
      onTap: () {
        Routers().pop(context);
      },
      child: Drawer(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 0.h, 16.h),
              child: FutureBuilder(
                  future: this._buildVersionString(),
                  initialData: "",
                  builder: (context, snapData) {
                    return Text("口袋卡包  ${snapData.data}版",
                        style: TextStyle(
                            fontSize: 32.sp, fontWeight: FontWeight.bold));
                  }),
            ),
            Divider(
              thickness: 6.h,
              color: Theme.of(context).primaryColorLight,
            ),
            if (totalInit > 0)
              Container(
                height: 200.h,
                child: PieChart(
                  colorList: [
                    Theme.of(context).accentColor,
                    Theme.of(context).primaryColorLight
                  ],
                  dataMap: {
                    '总剩余': totalCurrent,
                    '总消费': totalConsume,
                  },
                ),
              ),
            if (totalInit > 0)
              Divider(
                thickness: 2.h,
                color: Theme.of(context).primaryColorLight,
              ),
            if (totalInit > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.h, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "总充值：${totalInit.toStringAsFixed(0)}元",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontSize: 26.sp),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      "总剩余：${totalCurrent.toStringAsFixed(0)}元",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontSize: 26.sp),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      "总消费：${totalConsume.toStringAsFixed(0)}元",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontSize: 26.sp),
                    ),
                  ],
                ),
              ),
            if (totalInit > 0)
              Divider(
                thickness: 8.h,
                color: Theme.of(context).primaryColorLight,
              ),
            ListTile(
              title: const Text("数据备份"),
              onTap: () async {
                if (await DialogService()
                    .nativeAlert("备份数据提示", "是否要把本地数据备份到云端")) {
                  int phoneId = await this._getId();
                  String token = StorageService()
                      .sharedPreferences
                      .getString("auth_token_key");
                  if (token == null) {
                    if (await this._jverifyCheck()) {
                      token = await this._getAuthToken(phoneId);
                      if (token == null) {
                        await DialogService().nativeAlert("操作失败", "授权失败");
                      } else {
                        StorageService()
                            .sharedPreferences
                            .setString("auth_token_key", token);
                      }
                    }
                  }
                  if (token != null) {
                    ProgressHUD.of(context).show();
                    bool result = await JssService()
                        .save(token, rechargeCardListState.toBase64Json());
                    ProgressHUD.of(context).dismiss();
                    if (result) {
                      await DialogService().nativeAlert("操作成功", "数据备份成功");
                    } else {
                      await DialogService().nativeAlert("操作失败", "数据备份失败");
                    }
                  }
                }
                Routers().pop(context);
              },
              trailing: Icon(Icons.cloud_upload),
            ),
            ListTile(
              title: const Text("数据恢复"),
              onTap: () async {
                if (await DialogService()
                    .nativeAlert("数据恢复", "是否要把云端数据下载到本地")) {
                  int phoneId = await this._getId();
                  String token = StorageService()
                      .sharedPreferences
                      .getString("auth_token_key");
                  if (token == null) {
                    if (await this._jverifyCheck()) {
                      token = await this._getAuthToken(phoneId);
                      if (token == null) {
                        await DialogService().nativeAlert("操作失败", "授权失败");
                      } else {
                        StorageService()
                            .sharedPreferences
                            .setString("auth_token_key", token);
                      }
                    }
                  }
                  if (token != null) {
                    ProgressHUD.of(context).show();
                    String body = await JssService().load(token);
                    ProgressHUD.of(context).dismiss();
                    if (body != null) {
                      await rechargeCardListState.fromBase64Json(body);
                      await DialogService().nativeAlert("操作成功", "数据恢复成功");
                    } else {
                      await DialogService().nativeAlert("操作失败", "数据恢复失败");
                    }
                  }
                }
                Routers().pop(context);
              },
              trailing: Icon(Icons.cloud_download),
            ),
            Divider(),
            ListTile(
              title: const Text("暗黑模式"),
              onTap: () {
                Routers().pop(context);
                _switchDarkMode(context, themeState);
              },
              trailing: CupertinoSwitch(
                activeColor: Theme.of(context).accentColor,
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  Routers().pop(context);
                  _switchDarkMode(context, themeState);
                },
              ),
            ),
            Divider(),
            ListTile(
              title: const Text("隐私政策"),
              onTap: () async {
                await Routers().goThridPartWebView(
                    context,
                    await MarkdownService()
                        .buildMarkdownFileUrl(context, "assets/users/pp.md"));
              },
            ),
            Divider(),
            ListTile(
              title: const Text("服务条款"),
              onTap: () async {
                await Routers().goThridPartWebView(
                    context,
                    await MarkdownService()
                        .buildMarkdownFileUrl(context, "assets/users/ua.md"));
              },
            ),
            ListTile(
              title: const Text("反馈建议"),
              onTap: () async {
                final String url =
                    'mailto:3317964980@qq.com?subject=feedback&body=feedback';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  await Future.delayed(Duration(seconds: 1));
                  launch(
                      'https://github.com/wuqi-jack/wuqi-jack.github.io/issues',
                      forceSafariVC: true);
                }
              },
              trailing: Icon(Icons.feedback),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
