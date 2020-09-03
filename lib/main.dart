import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_fordova/generated/l10n.dart' as FordovaL10n;
import 'package:flutter_fordova/service/stateless/js_function_mapper/permission_mapper.dart';
//import 'package:flutter_hyble/flutter_hyble.dart';
import 'package:flutter_wechat_plugin/js_function_mapper/wechat_mapper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_scc/flutter_scc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_umpush/flutter_umpush.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/locator.dart' as FL;
import 'package:flutter_smzg/service/provider_manager.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:flutter_smzg/view/page/password_card/password_card_list_page.dart';

String amapKeyIOS = 'b97ddfd6946da974f3b8b1b630428113';

String amapKeyAndroid =
    'de5b3${ET.s}658922c${ET.s}4c187da2${ET.s}fc32708b${ET.s}1b9f';
// 极光认证key：a3deecd520245cd723a3b4ee
String jVerifyKeyIOS = 'f07c834085ed3de1020627ca';
String jVerifyKeyAndroid = 'ce5e${ET.s}8c483009${ET.s}cab8b7ab9d32';
// // 极光认证channel
String jVerifyChannel = 'qq';
// const String openApiUrl =
//     'https://jack.51bixin.net/ios_api_config/com.github.smzg_dt.json';
// const String openApiUrl =
//     'https://jack.51bixin.net/ios_api_config/com.github.smzg_ad.json';
String openApiUrl =
    'https://ja${ET.s}ck.51b${ET.s}ixin.ne${ET.s}t/ios_a${ET.s}pi_config/co${ET.s}m.gith${ET.s}ub.smz${ET.s}g_dt.json?s=${DateTime.now().millisecondsSinceEpoch}';

String openApiBackupUrl =
    'https://ish${ET.s}emant.git${ET.s}hub.i${ET.s}o/md${ET.s}5.js';

main() async {
  Provider.debugCheckInvalidValueType = null;
  try {
    ConfigState.openApiUrl = openApiUrl;
    ConfigState.openApiBackupUrl = openApiBackupUrl;
    WidgetsFlutterBinding.ensureInitialized();

    final Directory tmpDir = await getTemporaryDirectory();
    Logger.init(writeFile: true, logFilePath: "${tmpDir.path}/kdkb.log");
    Logger.info("程序开始启动");
    final FL.Locator _locator = FL.Locator();
    await _locator.setup();
    await _locator.init();
    await locator.get<ThemeState>().init(colorIndex: 3);
    String jverifyAppKey = Platform.isIOS ? jVerifyKeyIOS : jVerifyKeyAndroid;
    Logger.info("jverifyAppKey: $jverifyAppKey");
    await JVerifyService().init(jverifyAppKey, jVerifyChannel);

    try {
      // 初始化远程配置
      await locator.get<ConfigState>().init();
    } catch (e, s) {
      Logger.printErrorStack(e, s);
    }
    try {
      //初始化高德定位
      String key = Platform.isAndroid ? amapKeyAndroid : amapKeyIOS;
      await AmapCore.init(key);
    } catch (e, s) {
      Logger.printErrorStack(e, s);
    }
    //运行MainApp

    runApp(const MainApp());
    //设置状态栏
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness:
              Platform.isIOS ? Brightness.dark : Brightness.light),
    );
  } catch (e, s) {
    Logger.printErrorStack(e, s);
  }
}

//在MainApp中统一设置Locale、MultiProvider框架、MaterialApp、路由
class MainApp extends StatelessWidget {
  const MainApp();
  @override
  Widget build(BuildContext context) {
    //使用OKToast
    return MultiProvider(
      providers: [...providers, ...baseProviders],
      child: Consumer2<ThemeState, LocaleState>(
        builder: (context, themeState, localeState, child) {
          return ProviderWidget2<ConfigState, PasswordCardListState>(
            //ConfigState是单例，方便locator查找
            state1: locator.get<ConfigState>(),
            //PasswordCardListState是单例，方便locator查找
            state2: locator.get<PasswordCardListState>(),
            onStateReady: (configState, passwordCardListState) {
              if (configState.keyLength != null &&
                  configState.keyLength == 64) {
                Logger.info("APP onStateReady");
                passwordCardListState.init();
              }
            },
            builder: (context, configState, passwordCardListState, child) {
              Logger.info("keyLength: ${configState.keyLength}");
              //设置MaterialApp
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: themeState.themeData(), //主题
                darkTheme: themeState.themeData(platformDarkMode: true), //暗黑主题
                locale: const Locale("zh", "CN"),
                localizationsDelegates: const [
                  FordovaL10n.S.delegate,
                  RefreshLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate
                ],
                //使用fluro路由框架
                onGenerateRoute: Routers().router.generator,
                home: MainPage(configState),
              );
            },
          );
        },
      ),
    );
  }
}

///在MainPage统一设置ScreenUtil.init(context, width: 750, height: 1334)和resume
class MainPage extends StatefulWidget {
  final ConfigState configState;
  const MainPage(this.configState);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  @override
  void initState() {
    Logger.info("_HomePageState initState");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    Logger.info("_HomePageState dispose");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      //触发onResume函数
      //Logger.info("onWebViewCreated ChcpState.chcpCheckUpdate");
      Logger.info("_HomePageState resume ");
      await widget.configState.init();
    } else if (state == AppLifecycleState.inactive) {
      //ignore
    } else if (state == AppLifecycleState.paused) {
      //ignore
    } else if (state == AppLifecycleState.detached) {
      //ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    final int keyLength = widget.configState.keyLength;
    if (JsFunctionService().jsFunctionMappers == null &&
        keyLength != null &&
        keyLength == 2048) {
      JsFunctionService().jsFunctionMappers = [
        BasicMapper(),
        UmengTagAliasMapper(),
        JverifyMapper(),
        ProgressHudMapper(),
        PermissionMapper(),
        WeChatMapper(),
        //以下三个都依赖蓝牙
        // if (widget.configState.config.enableBlue) ...[
        //   BlueMapper(),
        //   TerminalMapper(),
        //   T$ick$etQueueMapper(),
        // ]
      ];
    }
    return keyLength == null
        ? NetworkErrorWidget(
            onPressed: () async {
              FlutterUmpush().addTag("network_error_at_main");
              await locator.get<ConfigState>().init();
            },
          )
        : keyLength == 64
            ? const PasswordCardListPage()
            : keyLength == 2048
                ? const FdvWebViewPluginPage()
                : const PasswordCardListPage();
  }
}
