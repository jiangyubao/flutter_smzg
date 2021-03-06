import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_fordova/view/page/scan_page.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:flutter_smzg/util/convert_util.dart';
import 'package:flutter_smzg/view/page/password_card/password_builder_page.dart';
import 'package:flutter_smzg/view/page/password_card/password_card_form_page.dart';
import 'package:flutter_smzg/view/page/password_card/password_card_image_page.dart';
import 'package:flutter_smzg/view/page/password_card/password_card_list_page.dart';

///路由定义
class Routers {
  factory Routers() => _instance;
  Routers._();
  static Routers _instance = Routers._();

  ///跟路由
  static const _root = "/";

  ///添加或修改表单
  static const _passwordCardForm = "/password_card_form";

  ///密码卡图片
  static const _passwordCardImage = "/password_card_image";

  static const _passwordBuilderPage = "/password_builder_page";
  //fordova必须：webview
  //fordova必须：扫码
  static const _scan = "/scan";
  //fordova必须：带导航栏的webview，导航栏包括关闭、前进、后退、刷新按钮
  static const _thirdPartWebView = "/third_part_web_view";

  ///单例
  FluroRouter _router = FluroRouter();
  FluroRouter get router => _router;

  ///路由pop
  void pop<T extends Object>(BuildContext context, [T result]) {
    Navigator.of(context).pop<T>(result);
  }

  ///初始化路由
  void init() {
    ///路由不存在
    _router.notFoundHandler = Handler(handlerFunc:
        (BuildContext context, Map<String, List<String>> parameters) {
      return Center(
        child: Text("路由不存在"),
      );
    });

    ///跟路由
    _router.define(
      _root,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        return PasswordCardListPage();
      }),
    );

    _router.define(
      _scan,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        //扫码窗口标题
        String title = parameters["title"].first;
        title = ConvertUtil.cnParamsDecode(title);
        return ScanPage(
          title: title,
        );
      }),
    );
    _router.define(
      _thirdPartWebView,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        //url
        String initialUrl = parameters["initialUrl"].first;
        //是否显示标题栏
        bool showNavigatorBar = parameters["showNavigatorBar"].first == "true";
        initialUrl = ConvertUtil.cnParamsDecode(initialUrl);
        return ThridPartWebViewPage(
          initialUrl: initialUrl,
          showNavigatorBar: showNavigatorBar,
        );
      }),
    );

    _router.define(
      _passwordCardForm,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        //id
        int id = int.parse(parameters["id"].first);
        PasswordCard passwordCard = id == -1
            ? PasswordCard.empty()
            : locator
                .get<PasswordCardListState>()
                .list
                .firstWhere((element) => element.id == id);
        //备注：这里必须克隆一个对象，防止修改而未保存时导致provider状态对象发生改变
        return PasswordCardFormPage(
            passwordCard: PasswordCard.clone(passwordCard));
      }),
    );
    _router.define(
      _passwordCardImage,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        //id
        int id = int.parse(parameters["id"].first);
        PasswordCard passwordCard = id == -1
            ? PasswordCard.empty()
            : locator
                .get<PasswordCardListState>()
                .list
                .firstWhere((element) => element.id == id);
        return PasswordCardImagePage(passwordCard: passwordCard);
      }),
    );
    _router.define(
      _passwordBuilderPage,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        return PasswordBuilderPage();
      }),
    );
  }

  Future goPasswordCardForm(BuildContext context, int id) {
    return _router.navigateTo(context, "$_passwordCardForm?id=$id",
        transition: TransitionType.cupertinoFullScreenDialog);
  }

  Future goPasswordBuilderPage(BuildContext context) {
    return _router.navigateTo(context, _passwordBuilderPage,
        transition: TransitionType.inFromRight);
  }

  Future goScan(BuildContext context, String title) {
    title = ConvertUtil.cnParamsEncode(title);
    return _router.navigateTo(context, "$_scan?title=$title",
        transition: TransitionType.inFromRight);
  }

  Future goPasswordCardImage(BuildContext context, int id) {
    return _router.navigateTo(context, "$_passwordCardImage?id=$id",
        transition: TransitionType.cupertinoFullScreenDialog);
  }

  Future goThridPartWebView(BuildContext context, String initialUrl,
      {bool showNavigatorBar = true}) {
    initialUrl = ConvertUtil.cnParamsEncode(initialUrl);
    return _router.navigateTo(context,
        "$_thirdPartWebView?initialUrl=$initialUrl&showNavigatorBar=showNavigatorBar",
        transition: TransitionType.inFromRight);
  }
}
