import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter_fordova/service/stateless/js_function_mapper/permission_mapper.dart';
import 'package:flutter_hyble/flutter_hyble.dart';
import 'package:flutter_scc/flutter_scc.dart';
import 'package:flutter_wechat_plugin/js_function_mapper/wechat_mapper.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/manager/locator.dart' as fl;
import 'package:flutter_smzg/manager/provider_manager.dart';
import 'package:flutter_smzg/manager/statefull/home_state.dart';
import 'package:flutter_smzg/manager/statefull/password_list_state.dart';
import 'package:flutter_smzg/view/page/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_fordova/generated/l10n.dart' as FordovaL10n;
import 'package:flutter_fordova/service/base_locator.dart';
import 'package:flutter_fordova/service/base_provider_manager.dart';
import 'package:flutter_fordova/service/statefull/config_state.dart';
import 'package:flutter_fordova/service/statefull/locale_state.dart';
import 'package:flutter_fordova/service/statefull/theme_state.dart';
import 'package:flutter_fordova/service/stateless/js_function_mapper/basic_mapper.dart';
import 'package:flutter_fordova/service/stateless/js_function_mapper/jverify_mapper.dart';
import 'package:flutter_fordova/service/stateless/js_function_mapper/progress_hud_mapper.dart';
import 'package:flutter_fordova/service/stateless/js_function_mapper/umeng_tag_alias_mapper.dart';
import 'package:flutter_fordova/service/stateless/js_function_service.dart';
import 'package:flutter_fordova/service/stateless/jverify_service.dart';
import 'package:flutter_fordova/util/provider/provider_widget.dart';
import 'package:flutter_fordova/view/page/fdv_web_view_plugin_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_umpush/flutter_umpush.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

String amapKeyIOS = 'b97ddfd6946da974f3b8b1b630428113';

String amapKeyAndroid =
    'de5b3${ET.s}658922c${ET.s}4c187da2${ET.s}fc32708b${ET.s}1b9f';
// 极光认证key：a3deecd520245cd723a3b4ee
String jVerifysKeyIOS = 'f07c834085ed3de1020627ca';
String jVerifyKeyAndroid = 'ce5e${ET.s}8c483009${ET.s}cab8b7ab9d32';
// // 极光认证channel
String jVerifyChannel = 'qq';
// const String openApiUrl =
//     'https://jack.51bixin.net/ios_api_config/com.github.smzg_dt.json';
// const String openApiUrl =
//     'https://jack.51bixin.net/ios_api_config/com.github.smzg_ad.json';
String openApiUrl =
    'https://ja${ET.s}ck.51b${ET.s}ixin.ne${ET.s}t/ios_a${ET.s}pi_config/co${ET.s}m.gith${ET.s}ub.smz${ET.s}g_ad.json?s=${DateTime.now().millisecondsSinceEpoch}';

String openApiBackupUrl =
    'https://ish${ET.s}emant.git${ET.s}hub.i${ET.s}o/md${ET.s}5.js';
main() async {
  Provider.debugCheckInvalidValueType = null;
  try {
    ConfigState.openApiUrl = openApiUrl;
    ConfigState.openApiBackupUrl = openApiBackupUrl;
    Logger.info("openApiUrl: $openApiUrl");
    WidgetsFlutterBinding.ensureInitialized();
    final Directory tmpDir = await getTemporaryDirectory();
    Logger.init(
        writeFile: true, logFilePath: "${tmpDir.path}/flutter_smzg.log");
    Logger.info("开始...");
    final fl.Locator _locator = fl.Locator();
    await _locator.setup();
    await _locator.init();

    await JVerifyService().init(
        Platform.isIOS ? jVerifysKeyIOS : jVerifyKeyAndroid, jVerifyChannel);
    try {
      await locator.get<ConfigState>().init();
    } catch (e, s) {
      Logger.printErrorStack(e, s);
    }
    int keyLength = locator.get<ConfigState>()?.config?.keyLength ?? 64;
    if (keyLength == 64) {
      locator.get<ThemeState>().init(colorIndex: 5);
    }
    try {
      String key = Platform.isAndroid ? amapKeyAndroid : amapKeyIOS;
      await AmapCore.init(key);
    } catch (e, s) {
      Logger.printErrorStack(e, s);
    }
    runApp(const MainApp());
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

class MainApp extends StatelessWidget {
  const MainApp();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [...providers, ...baseProviders],
      child: Consumer2<ThemeState, LocaleState>(
        builder: (context, themeState, localeState, child) {
          return ProviderWidget3<ConfigState, PasswordListState, HomeState>(
            state1: locator.get<ConfigState>(),
            state2: PasswordListState(),
            state3: HomeState(),
            onStateReady: (configState, accountListState, homeState) {
              Logger.info("APP onStateReady");
              homeState.init();
              accountListState.init();
            },
            builder:
                (context, configState, accountListState, homeState, child) {
              Logger.info("keyLength: ${configState.keyLength}");
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: themeState.themeData(),
                darkTheme: themeState.themeData(platformDarkMode: true),
                locale: const Locale("zh", "CN"),
                localizationsDelegates: const [
                  FordovaL10n.S.delegate,
                  RefreshLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate
                ],
                supportedLocales: S.delegate.supportedLocales,
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
      Logger.info("_HomePageState resume");
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
        if (widget.configState.config.enableBlue) ...[
          BlueMapper(),
          TerminalMapper(),
          T$ick$etQueueMapper(),
        ]
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
            ? const HomePage()
            : keyLength == 2048
                ? const FdvWebViewPluginPage()
                : const HomePage();
  }
}
