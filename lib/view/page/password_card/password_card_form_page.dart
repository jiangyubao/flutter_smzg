import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:flutter_smzg/util/date_util.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

///密码卡表单
class PasswordCardFormPage extends StatefulWidget {
  final PasswordCard passwordCard;
  PasswordCardFormPage({Key key, this.passwordCard}) : super(key: key);
  @override
  _PasswordCardFormPageState createState() =>
      _PasswordCardFormPageState(this.passwordCard);
}

class _PasswordCardFormPageState extends State<PasswordCardFormPage> {
  PasswordCard passwordCard;
  final GlobalKey<FormState> _key = GlobalKey();
  TextEditingController _nickNameTextEditingController =
      TextEditingController();
  TextEditingController _urlTextEditingController = TextEditingController();
  TextEditingController _userNameTextEditingController = TextEditingController(
      text: DateUtil.formatShortDate(DateTime.now().add(Duration(days: 365))));
  TextEditingController _sitePasswordTextEditingController =
      TextEditingController();
  final FocusNode _nickNameFocusNode = FocusNode();
  final FocusNode _urlFocusNode = FocusNode();
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _sitePasswordFocusNode = FocusNode();

  _PasswordCardFormPageState(this.passwordCard);
  KeyboardActionsConfig _buildKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardAction(
          focusNode: _sitePasswordFocusNode,
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
  void initState() {
    super.initState();
    _nickNameTextEditingController.text = passwordCard.nickName;
    _urlTextEditingController.text = passwordCard.url;
    _userNameTextEditingController.text = passwordCard.userName;
    _sitePasswordTextEditingController.text = passwordCard.sitePassword;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PasswordCardListState, ConfigState>(
      builder: (context, passwordCardListState, configState, child) {
        final ThemeData themeData = Theme.of(context);
        return Theme(
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
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 28.sp,
                  ),
                  onPressed: () {
                    Routers().pop(context);
                  }),
              centerTitle: true,
              title: passwordCard.id == null
                  ? Text(
                      "新建密码卡",
                      style: TextStyle(fontSize: 30.sp),
                    )
                  : Text(
                      "修改密码卡",
                      style: TextStyle(fontSize: 30.sp),
                    ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.check, size: 28.sp),
                    onPressed: () async {
                      if (_key.currentState.validate()) {
                        if (passwordCard.id == null) {
                          int id =
                              await passwordCardListState.insert(passwordCard);
                          if (id < 0) {
                            await DialogService()
                                .nativeAlert("保存失败", "系统已存在相同名字的密码卡", ok: "确定");
                            _nickNameFocusNode.requestFocus();
                          } else {
                            Routers().pop(context);
                          }
                        } else {
                          bool result =
                              await passwordCardListState.update(passwordCard);
                          if (!result) {
                            await DialogService()
                                .nativeAlert("保存失败", "系统已存在相同名字的密码卡", ok: "确定");
                            _nickNameFocusNode.requestFocus();
                          } else {
                            Routers().pop(context);
                          }
                        }
                      }
                    }),
              ],
            ),
            body: Form(
              key: _key,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 25.h),
                child: KeyboardActions(
                  config: this._buildKeyboardConfig(context),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          autofocus: true,
                          style: TextStyle(fontSize: 28.sp),
                          maxLength: 8,
                          maxLengthEnforced: true,
                          focusNode: _nickNameFocusNode,
                          controller: _nickNameTextEditingController,
                          decoration: InputDecoration(
                            labelText: '别名：',
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (String val) {
                            passwordCard.nickName = val;
                          },
                          onSaved: (String val) {},
                          validator: (String val) {
                            if (val.isEmpty) {
                              return "别名不能为空";
                            }
                            if (val.length > 8 || val.length < 1) {
                              return "别名长度只能是1到8位";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 16.h,
                        ),
                        TextFormField(
                          style: TextStyle(fontSize: 28.sp),
                          maxLines: 1,
                          focusNode: _urlFocusNode,
                          controller: _urlTextEditingController,
                          maxLength: 32,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            labelText: '网址：',
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (String val) {
                            passwordCard.url = val;
                          },
                          onSaved: (String val) {},
                          validator: (String val) {
                            if (val.isEmpty) {
                              return "网址不能为空";
                            }
                            if (val.length > 32 || val.length < 1) {
                              return "网址长度只能是1到32位";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 16.h,
                        ),
                        TextFormField(
                          style: TextStyle(fontSize: 28.sp),
                          focusNode: _userNameFocusNode,
                          maxLength: 16,
                          maxLengthEnforced: true,
                          controller: _userNameTextEditingController,
                          decoration: InputDecoration(
                            labelText: '账号：',
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (String val) {
                            passwordCard.userName = val;
                          },
                          onSaved: (String val) {},
                          validator: (String val) {
                            if (val.isEmpty) {
                              return "账号不能为空";
                            }
                            if (val.length > 16 || val.length < 1) {
                              return "账号长度只能1到16位";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          style: TextStyle(fontSize: 28.sp),
                          focusNode: _sitePasswordFocusNode,
                          maxLength: 16,
                          maxLengthEnforced: true,
                          controller: _sitePasswordTextEditingController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.lock,
                                  size: 28.sp,
                                ),
                                onPressed: () async {
                                  String val = await Routers()
                                      .goPasswordBuilderPage(context);
                                  passwordCard.sitePassword = val;
                                  _sitePasswordTextEditingController.text = val;
                                }),
                            labelText: '密码：',
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (String val) {
                            passwordCard.sitePassword = val;
                          },
                          onSaved: (String val) {},
                          validator: (String val) {
                            if (val.isEmpty) {
                              return "密码不能为空";
                            }
                            if (val.length > 16 || val.length < 1) {
                              return "密码长度只能1到32位";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
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
