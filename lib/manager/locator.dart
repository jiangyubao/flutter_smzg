import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/manager/stateless/data_manager.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/service/base_locator.dart';

class Locator extends BaseLocator {
  Future<void> setup() async {
    await super.setup();
  }

  Future<void> init() async {
    try {
      await super.init();
      Routers().init();
      await DataManager().init();
    } catch (e, s) {
      Logger.printErrorStack(e, s);
    }
  }
}
