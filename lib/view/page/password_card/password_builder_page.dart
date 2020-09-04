import 'package:flutter_fordova/util/provider/provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/password_builder_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

///壳APP的界面
class PasswordBuilderPage extends StatefulWidget {
  const PasswordBuilderPage({Key key}) : super(key: key);
  @override
  _PasswordBuilderPageState createState() => _PasswordBuilderPageState();
}

class _PasswordBuilderPageState extends State<PasswordBuilderPage> {
  final GlobalKey<FormState> _key = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  KeyboardActionsConfig _buildKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardAction(
          focusNode: _focusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("完成"),
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<PasswordBuilderState>(
      state: PasswordBuilderState(),
      onStateReady: (passwordBuilderState) {
        passwordBuilderState.init();
      },
      builder: (context, passwordBuilderState, child) {
        final ThemeData themeData = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.close,
                size: 28.sp,
              ),
              onPressed: () {
                Routers().pop(context);
              },
            ),
            actions: [
              IconButton(
                  icon: Icon(Icons.done, size: 28.sp),
                  onPressed: () {
                    Routers().pop(
                        context, passwordBuilderState.passwordBuilder.password);
                  })
            ],
            title: Text(
              "密码生成器",
              style: TextStyle(fontSize: 30.sp),
            ),
          ),
          body: Theme(
            data: themeData.copyWith(
              inputDecorationTheme: themeData.inputDecorationTheme.copyWith(
                hintStyle: TextStyle(fontSize: 26.sp),
                errorStyle: TextStyle(fontSize: 26.sp),
                counterStyle: TextStyle(fontSize: 26.sp),
                helperStyle: TextStyle(fontSize: 26.sp),
                suffixStyle: TextStyle(fontSize: 26.sp),
                labelStyle: TextStyle(fontSize: 26.sp),
                prefixStyle: TextStyle(fontSize: 26.sp),
              ),
            ),
            child: Form(
              key: _key,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 25.h),
                child: KeyboardActions(
                  config: this._buildKeyboardConfig(context),
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(fontSize: 28.sp),
                        maxLength: 8,
                        initialValue:
                            passwordBuilderState.passwordBuilder.length,
                        decoration: InputDecoration(
                          labelText: "长度",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (String val) {
                          passwordBuilderState.passwordBuilder.length = val;
                          passwordBuilderState.buildPassword();
                        },
                        onSaved: (String val) {},
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "长度不能为空";
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
                                child: Text(
                                  "数字",
                                  style: TextStyle(fontSize: 28.sp),
                                ),
                              ),
                              CupertinoSwitch(
                                activeColor: Theme.of(context).primaryColor,
                                value:
                                    passwordBuilderState.passwordBuilder.number,
                                onChanged: (bool val) {
                                  passwordBuilderState.passwordBuilder.number =
                                      val;
                                  passwordBuilderState.buildPassword();
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
                                child: Text(
                                  "大写",
                                  style: TextStyle(fontSize: 28.sp),
                                ),
                              ),
                              CupertinoSwitch(
                                activeColor: Theme.of(context).primaryColor,
                                value: passwordBuilderState
                                    .passwordBuilder.alphabetU,
                                onChanged: (bool val) {
                                  passwordBuilderState
                                      .passwordBuilder.alphabetU = val;
                                  passwordBuilderState.buildPassword();
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
                                child: Text(
                                  "小写",
                                  style: TextStyle(fontSize: 28.sp),
                                ),
                              ),
                              CupertinoSwitch(
                                activeColor: Theme.of(context).primaryColor,
                                value: passwordBuilderState
                                    .passwordBuilder.alphabetL,
                                onChanged: (bool val) {
                                  passwordBuilderState
                                      .passwordBuilder.alphabetL = val;
                                  passwordBuilderState.buildPassword();
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
                                child: Text(
                                  "符号",
                                  style: TextStyle(fontSize: 28.sp),
                                ),
                              ),
                              CupertinoSwitch(
                                activeColor: Theme.of(context).primaryColor,
                                value:
                                    passwordBuilderState.passwordBuilder.symbol,
                                onChanged: (bool val) {
                                  passwordBuilderState.passwordBuilder.symbol =
                                      val;
                                  passwordBuilderState.buildPassword();
                                },
                              ),
                            ],
                          );
                        },
                        onSaved: (bool initialValue) {},
                      ),
                      SizedBox(
                        height: 80.h,
                        width: 20.w,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "${passwordBuilderState.passwordBuilder.password}",
                            style: TextStyle(
                              fontSize: 42.sp,
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 4.w,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 80.h,
                        width: 20.w,
                      ),
                      IconButton(
                          color: Theme.of(context).accentColor,
                          icon: Icon(
                            Icons.refresh,
                            size: 28.sp,
                          ),
                          onPressed: () {
                            passwordBuilderState.buildPassword();
                          })
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
