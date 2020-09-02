import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/service/base_locator.dart';
import 'package:flutter_smzg/service/stateless/db_service.dart';

///Locator
class Locator extends BaseLocator {
  ///设置ioc容器
  Future<void> setup() async {
    await super.setup();
    locator.registerSingleton<PasswordCardListState>(PasswordCardListState());
  }

  ///Ioc容器初始化，执行顺序是被依赖的最先执行
  Future<void> init() async {
    try {
      await super.init();
      Routers().init();
      await DbService().init();
    } catch (e, s) {
      Logger.printErrorStack(e, s);
    }
  }
}
