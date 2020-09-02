import 'package:flutter_smzg/manager/statefull/home_state.dart';
import 'package:flutter_fordova/util/provider/provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svprogresshud/svprogresshud.dart';

///壳APP的界面
class PasswordBuilderPage extends StatefulWidget {
  const PasswordBuilderPage({Key key}) : super(key: key);
  @override
  _PasswordBuilderPageState createState() => _PasswordBuilderPageState();
}

class _PasswordBuilderPageState extends State<PasswordBuilderPage> {
  final GlobalKey<FormState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<HomeState>(
      state: HomeState(),
      onStateReady: (homeState) {
        homeState.init();
      },
      builder: (context, homeState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("密码生成"),
            actions: [
              IconButton(
                  icon: Icon(Icons.content_copy),
                  onPressed: () async {
                    homeState.copyToClipBoard();
                    await SVProgressHUD.showSuccess("密码已拷贝到粘贴板");
                    await Future.delayed(Duration(seconds: 1));
                    await SVProgressHUD.dismiss();
                  })
            ],
          ),
          body: Form(
            key: _key,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    initialValue: homeState.passwordBuilder.length,
                    decoration: InputDecoration(
                      labelText: "密码长度：",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (String val) {
                      homeState.passwordBuilder.length = val;
                      homeState.buildPassword();
                    },
                    onSaved: (String val) {},
                    validator: (String val) {
                      if (val.isEmpty) {
                        return "密码长度不能为空";
                      }
                      return null;
                    },
                  ),
                  FormField<bool>(
                    builder: (FormFieldState<bool> state) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text("使用数字："),
                          ),
                          CupertinoSwitch(
                            activeColor: Theme.of(context).accentColor,
                            value: homeState.passwordBuilder.number,
                            onChanged: (bool val) {
                              homeState.passwordBuilder.number = val;
                              homeState.buildPassword();
                            },
                          ),
                        ],
                      );
                    },
                    onSaved: (bool initialValue) {},
                  ),
                  FormField<bool>(
                    builder: (FormFieldState<bool> state) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text("使用大写字母："),
                          ),
                          CupertinoSwitch(
                            activeColor: Theme.of(context).accentColor,
                            value: homeState.passwordBuilder.alphabetU,
                            onChanged: (bool val) {
                              homeState.passwordBuilder.alphabetU = val;
                              homeState.buildPassword();
                            },
                          ),
                        ],
                      );
                    },
                    onSaved: (bool initialValue) {},
                  ),
                  FormField<bool>(
                    builder: (FormFieldState<bool> state) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text("使用小写字母："),
                          ),
                          CupertinoSwitch(
                            activeColor: Theme.of(context).accentColor,
                            value: homeState.passwordBuilder.alphabetL,
                            onChanged: (bool val) {
                              homeState.passwordBuilder.alphabetL = val;
                              homeState.buildPassword();
                            },
                          ),
                        ],
                      );
                    },
                    onSaved: (bool initialValue) {},
                  ),
                  FormField<bool>(
                    builder: (FormFieldState<bool> state) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text("使用符号："),
                          ),
                          CupertinoSwitch(
                            activeColor: Theme.of(context).accentColor,
                            value: homeState.passwordBuilder.symbol,
                            onChanged: (bool val) {
                              homeState.passwordBuilder.symbol = val;
                              homeState.buildPassword();
                            },
                          ),
                        ],
                      );
                    },
                    onSaved: (bool initialValue) {},
                  ),
                  const SizedBox(
                    height: 40,
                    width: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("${homeState.passwordBuilder.password}"),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                    width: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          if (_key.currentState.validate()) {
                            homeState.buildPassword();
                          }
                        },
                        child: Text("重新生成"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
