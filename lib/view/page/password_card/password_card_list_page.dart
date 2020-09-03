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
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:flutter_smzg/service/stateless/md_service.dart';
import 'package:flutter_smzg/view/widget/password_card/password_card_widget.dart';
import 'package:flutter_smzg/view/widget/user_agreement_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PasswordCardListPage extends StatefulWidget {
  const PasswordCardListPage();
  @override
  _PasswordCardListPageState createState() => _PasswordCardListPageState();
}

class _PasswordCardListPageState extends State<PasswordCardListPage> {
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
      child: Consumer2<PasswordCardListState, ThemeState>(
        builder: (context, passwordCardListState, themeState, child) {
          return passwordCardListState.showUserAgreement
              ? UserAgreementWidget()
              : Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: const Text("小密总管"),
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            try {
                              await Routers().goPasswordCardForm(context, -1);
                            } catch (e, s) {
                              Logger.printErrorStack(e, s);
                            }
                          })
                    ],
                  ),
                  drawer: this
                      ._buildDrawer(context, themeState, passwordCardListState),
                  body: WillPopScope(
                    onWillPop: () async {
                      if (passwordCardListState.lastPressed == null ||
                          DateTime.now().difference(
                                  passwordCardListState.lastPressed) >
                              Duration(seconds: 1)) {
                        //两次点击间隔超过1秒则重新计时
                        passwordCardListState.lastPressed = DateTime.now();
                        return false;
                      }
                      return true;
                    },
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (passwordCardListState.busy) {
                                return SkeletonList(
                                  builder: (context, index) => SkeletonItem(),
                                );
                              }
                              if (passwordCardListState.error &&
                                  passwordCardListState.list.isEmpty) {
                                return ViewStateErrorWidget(
                                    error: passwordCardListState.pageStateError,
                                    onPressed: passwordCardListState.initData);
                              }
                              if (passwordCardListState.empty) {
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
                                    message: "密码卡为空，请创建密码卡",
                                    onPressed: () async {
                                      try {
                                        await Routers()
                                            .goPasswordCardForm(context, -1);
                                      } catch (e, s) {
                                        Logger.printErrorStack(e, s);
                                      }
                                    });
                              }
                              return SmartRefresher(
                                controller:
                                    passwordCardListState.refreshController,
                                header: const WaterDropHeader(),
                                footer: const ClassicFooter(),
                                onRefresh: () async {
                                  await passwordCardListState.refresh(
                                      init: true);
                                },
                                onLoading: () async {
                                  await passwordCardListState.loadMore();
                                },
                                enablePullUp: true,
                                child: ListView.builder(
                                  itemCount: passwordCardListState.list.length,
                                  itemBuilder: (context, index) {
                                    return PasswordCardWidget(
                                      passwordCard:
                                          passwordCardListState.list[index],
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
      PasswordCardListState passwordCardListState) {
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
                    return Text("小密总管  ${snapData.data}版",
                        style: TextStyle(
                            fontSize: 32.sp, fontWeight: FontWeight.bold));
                  }),
            ),
            Divider(
              thickness: 6.h,
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
                        .save(token, passwordCardListState.toBase64Json());
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
                      await passwordCardListState.fromBase64Json(body);
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
                    await MdService().buildMarkdownFileUrl(
                        context, "assets/doc/privacy.md"));
              },
            ),
            Divider(),
            ListTile(
              title: const Text("服务条款"),
              onTap: () async {
                await Routers().goThridPartWebView(
                    context,
                    await MdService().buildMarkdownFileUrl(
                        context, "assets/doc/agreement.md"));
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
                      'https://github.com/ishemant/ishemant.github.io/issues',
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
