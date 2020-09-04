import 'dart:math';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/util/provider/view_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smzg/model/password_builder.dart';

class PasswordBuilderState extends ViewState {
  static const String kAlphabetL = 'qwertyuiopasdfghjklzxcvbnm';
  static const String kAlphabetU = 'QWERTYUIOPASDFGHJKLZXCVBNM';
  static const String kNumber = '0123456789';
  static const String kSymbol = '!@#\$%^&*()_+~?><';
  Random _random = Random();
  PasswordBuilder passwordBuilder = PasswordBuilder();
  Future<void> init() async {
    this.buildPassword();
  }

  void buildPassword() {
    Logger.info(
        "length: ${passwordBuilder.length}, alphabetL: ${passwordBuilder.alphabetL}, alphabetU: ${passwordBuilder.alphabetU}, number: ${passwordBuilder.number}, symbol: ${passwordBuilder.symbol}");

    String letter = (passwordBuilder.alphabetL ? kAlphabetL : '') +
        (passwordBuilder.alphabetU ? kAlphabetU : '') +
        (passwordBuilder.number ? kNumber : '') +
        (passwordBuilder.symbol ? kSymbol : '');
    if (letter.isEmpty) {
      letter = kAlphabetL;
    }
    passwordBuilder.password = '';
    for (var i = 0; i < (int.tryParse(passwordBuilder.length) ?? 8); i++) {
      passwordBuilder.password += letter[_random.nextInt(letter.length)];
    }
    Logger.info("home_state:notify set _password: ${passwordBuilder.password}");
    notifyListeners();
  }

  void copyToClipBoard() {
    Clipboard.setData(ClipboardData(text: passwordBuilder.password));
    Logger.info("拷贝成功");
  }
}
