import 'dart:convert';

import 'package:flutter_smzg/model/password.dart';
import 'package:flutter_smzg/util/convert_util.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:flutter_smzg/view/page/home_page.dart';
import 'package:flutter_smzg/view/page/tab_pages/password/password_detail_page.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_fordova/view/page/scan_page.dart';

class Routers {
  factory Routers() => _instance;
  Routers._();
  static Routers _instance = Routers._();
  static const kRoot = "/";
  static const kAddAccount = "/add_account";
  static const kAccountCard = "/account_card";
  static const kScan = "/scan";
  static const kThridPartWebView = "/thrid_part_web_view";
  static const kAccountDetailPage = "/account_detail_page";
  Router _router = Router();
  Router get router => _router;
  void pop(BuildContext context) => _router.pop(context);
  void init() {
    _router.notFoundHandler = Handler(handlerFunc:
        (BuildContext context, Map<String, List<String>> parameters) {
      return Center(
        child: Text("路由不存在"),
      );
    });
    _router.define(
      kRoot,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        return HomePage();
      }),
    );

    _router.define(
      kScan,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        String title = parameters["title"].first;
        title = ConvertUtil.cnParamsDecode(title);
        return ScanPage(
          title: title,
        );
      }),
    );
    _router.define(
      kThridPartWebView,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        String initialUrl = parameters["initialUrl"].first;
        bool showNavigatorBar = parameters["showNavigatorBar"].first == "true";
        initialUrl = ConvertUtil.cnParamsDecode(initialUrl);
        return ThridPartWebViewPage(
          initialUrl: initialUrl,
          showNavigatorBar: showNavigatorBar,
        );
      }),
    );
    _router.define(
      kAccountDetailPage,
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> parameters) {
        String userJson = parameters["accountJson"].first;
        userJson = ConvertUtil.cnParamsDecode(userJson);
        return AccountDetailPage(Password.fromJson(jsonDecode(userJson)));
      }),
    );
  }

  Future goAccountCard(BuildContext context, bool showPrkKey, Password user) {
    final String userJson =
        ConvertUtil.cnParamsEncode(jsonEncode(user.toJson()));
    return _router.navigateTo(
        context, kAccountCard + "?showPrkKey=$showPrkKey&accountJson=$userJson",
        transition: TransitionType.inFromRight);
  }

  Future goAddAccount(BuildContext context) {
    return _router.navigateTo(context, kAddAccount,
        transition: TransitionType.cupertinoFullScreenDialog);
  }

  Future goScan(BuildContext context, String title) {
    title = ConvertUtil.cnParamsEncode(title);
    return _router.navigateTo(context, kScan + "?title=$title",
        transition: TransitionType.inFromRight);
  }

  Future goThridPartWebView(BuildContext context, String initialUrl,
      {bool showNavigatorBar = true}) {
    initialUrl = ConvertUtil.cnParamsEncode(initialUrl);
    return _router.navigateTo(
        context,
        kThridPartWebView +
            "?initialUrl=$initialUrl&showNavigatorBar=showNavigatorBar",
        transition: TransitionType.inFromRight);
  }

  Future goAccountDetail(BuildContext context, Password user) {
    final String userJson =
        ConvertUtil.cnParamsEncode(jsonEncode(user.toJson()));
    return _router.navigateTo(
        context, kAccountDetailPage + "?accountJson=$userJson",
        transition: TransitionType.inFromRight);
  }
}
