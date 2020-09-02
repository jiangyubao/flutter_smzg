import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smzg/manager/statefull/password_list_state.dart';
import 'package:flutter_smzg/manager/statefull/home_state.dart';
import 'package:flutter_smzg/view/page/tab_pages/password/password_builder_page.dart';
import 'package:flutter_smzg/view/page/tab_pages/password/password_list_page.dart';
import 'package:flutter_smzg/view/page/tab_pages/setting/setting_page.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // static const _kAgreement =
  //     "    欢迎使用小密总管APP！在你使用时，需要连接数据网络或WLAN网络，所产生的流量费用请咨询当地运营商。本APP非常重视你的隐私保护和个人信息。在你使用本APP前，请认真阅读http://《服务协议》 和http://《隐私协议》 全部条款，你同意并接受全部条款后再开始使用本APP。\n    本APP可能会用到以下信息，你可以在设备系统“设置”里进行相关权限信息管理。\n    为了让你更加安全地使用本APP，我们可能会定期给你推送安全方面的通知提醒。为了方便我们进行APP使用统计，本APP会申请读取你的设备状态、设备IDFA、IDFV等标识。当你使用扫二维码操作时，本APP会申请使用你的相机、相册照片等信息。";
  static const List<Widget> _kPages = <Widget>[
    const PasswordBuilderPage(),
    const AccountListPage(),
    const SettingPage(),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PasswordListState, HomeState, ThemeState>(
      builder: (context, accountListState, homeState, themeState, child) {
        return Scaffold(
          body: WillPopScope(
            onWillPop: () async {
              if (homeState.lastPressed == null ||
                  DateTime.now().difference(homeState.lastPressed) >
                      Duration(seconds: 1)) {
                //两次点击间隔超过1秒则重新计时
                homeState.lastPressed = DateTime.now();
                return false;
              }
              return true;
            },
            child: PageView.builder(
              itemBuilder: (ctx, index) => _kPages[index],
              itemCount: _kPages.length,
              controller: homeState.pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                homeState.selectedIndex = index;
              },
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: homeState.selectedIndex,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.lock),
                title: const Text("密码生成"),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bookmark),
                title: const Text("密码收藏"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                title: const Text("系统设置"),
              ),
            ],
            onTap: (index) async {
              homeState.selectedIndex = index;
            },
          ),
        );
      },
    );
  }

  // Scaffold _buildAgreement(BuildContext context, HomeState homeState) {
  //   return Scaffold(
  //     body: Container(
  //       color: Colors.grey,
  //       padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 300.h),
  //       child: Card(
  //         elevation: 12,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadiusDirectional.circular(60.sp),
  //         ),
  //         clipBehavior: Clip.antiAlias,
  //         child: Center(
  //           child: Padding(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: 8.w,
  //               vertical: 32.h,
  //             ),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: <Widget>[
  //                 Text(
  //                   "使用须知",
  //                   style:
  //                       TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w700),
  //                 ),
  //                 Expanded(
  //                   child: Padding(
  //                     padding: EdgeInsets.symmetric(
  //                         horizontal: 20.w, vertical: 24.h),
  //                     child: SingleChildScrollView(
  //                       child: Linkify(
  //                         onOpen: (link) async {
  //                           if (link.text == "《服务协议》") {
  //                             await Routers().goThridPartWebView(
  //                               context,
  //                               await MdManager().buildMarkdownFileUrl(
  //                                   context, "assets/doc/agreement.md"),
  //                             );
  //                           } else if (link.text == "《隐私协议》") {
  //                             await Routers().goThridPartWebView(
  //                               context,
  //                               await MdManager().buildMarkdownFileUrl(
  //                                   context, "assets/doc/privacy.md"),
  //                             );
  //                           } else if (link.text == "《帮助手册》") {
  //                             await MdManager().init(context);
  //                             await Routers().goThridPartWebView(
  //                               context,
  //                               await MdManager().buildMarkdownFileUrl(
  //                                   context, "assets/doc/help.md"),
  //                             );
  //                           }
  //                         },
  //                         text: _kAgreement,
  //                         style: TextStyle(fontSize: 28.sp),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: 24.h,
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: <Widget>[
  //                     CupertinoButton(
  //                         padding: EdgeInsets.all(30.w),
  //                         child: Text("同意使用"),
  //                         color: Theme.of(context).accentColor,
  //                         onPressed: () async {
  //                           await homeState.modifyShowAgreement(false);
  //                         }),
  //                     CupertinoButton(
  //                         child: Text("不同意"),
  //                         onPressed: () async {
  //                           await DialogService().nativeAlert(
  //                               "重要提醒", "请同意并接受《服务协议》和《隐私协议》全部条款后再开始使用",
  //                               ok: "确定");
  //                         }),
  //                   ],
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
