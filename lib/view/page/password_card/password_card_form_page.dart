import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
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
  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _addressTextEditingController = TextEditingController();
  TextEditingController _folderTextEditingController = TextEditingController(
      text: DateUtil.formatShortDate(DateTime.now().add(Duration(days: 365))));
  TextEditingController _userNameextEditingController = TextEditingController();
  TextEditingController _sitePasswordTextEditingController =
      TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _expiredDateFocusNode = FocusNode();
  final FocusNode _mobileFocusNode = FocusNode();

  _PasswordCardFormPageState(this.passwordCard);
  KeyboardActionsConfig _buildKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardAction(
          focusNode: _mobileFocusNode,
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
    _nameTextEditingController.text = passwordCard.nickName;
    _addressTextEditingController.text = passwordCard.url;
    _sitePasswordTextEditingController.text = "${passwordCard.userName}";
  }

  Future<PickedFile> _selectImage(double maxWidth, double maxHeight) async {
    String mode = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (Map<String, dynamic> map in [
                {"name": '使用照相机拍照', "type": Icons.photo_camera},
                {"name": '从相册选取照片', "type": Icons.photo_album}
              ])
                ListTile(
                  leading: Icon(map['type']),
                  title: Text("${map['name']}"),
                  onTap: () async {
                    Navigator.of(context).pop(map['name']);
                  },
                )
            ],
          );
        });
    if (mode != null) {
      if (mode == '使用照相机拍照') {
        if (!await PermissionService().requireCameraPermission()) {
          if (await DialogService().nativeAlert("需要相机权限", "是否手工设置相机权限？") ??
              false) {
            await PermissionService().openAppSettings();
          }
        } else {
          return await ImagePicker().getImage(
            source: ImageSource.camera,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          );
        }
      } else if (mode == '从相册选取照片') {
        if (!await PermissionService().requirePhotosPermission()) {
          if (await DialogService().nativeAlert("需要相册权限", "是否手工设置相册权限？") ??
              false) {
            await PermissionService().openAppSettings();
          }
        } else {
          return await ImagePicker().getImage(
            source: ImageSource.gallery,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          );
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PasswordCardListState, ConfigState>(
      builder: (context, passwordCardListState, configState, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: passwordCard.id == null
                ? const Text("新建密码卡")
                : const Text("修改密码卡"),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () async {
                    if (_key.currentState.validate()) {
                      passwordCard.sitePassword = passwordCard.userName;
                      if (passwordCard.id == null) {
                        int id =
                            await passwordCardListState.insert(passwordCard);
                        if (id < 0) {
                          await DialogService()
                              .nativeAlert("保存失败", "系统已存在相同名字的密码卡", ok: "确定");
                          _nameFocusNode.requestFocus();
                        } else {
                          Routers().pop(context);
                        }
                      } else {
                        bool result =
                            await passwordCardListState.update(passwordCard);
                        if (!result) {
                          await DialogService()
                              .nativeAlert("保存失败", "系统已存在相同名字的密码卡", ok: "确定");
                          _nameFocusNode.requestFocus();
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
                        maxLength: 16,
                        maxLengthEnforced: true,
                        focusNode: _nameFocusNode,
                        controller: _nameTextEditingController,
                        decoration: const InputDecoration(
                          labelText: '店铺名字：',
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {
                          passwordCard.nickName = val;
                        },
                        onSaved: (String val) {},
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "店铺名字不能为空";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        maxLines: 2,
                        focusNode: _addressFocusNode,
                        controller: _addressTextEditingController,
                        maxLength: 128,
                        maxLengthEnforced: true,
                        decoration: InputDecoration(
                          labelText: '店铺地址：',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add_location),
                            iconSize: 36.h,
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              if (!await PermissionService()
                                  .requireLocationPermission()) {
                                if (await DialogService()
                                        .nativeAlert("需要定位权限", "是否手工设置定位权限？") ??
                                    false) {
                                  await PermissionService().openAppSettings();
                                }
                              } else {
                                Map<String, dynamic> map =
                                    await (locator.get<LocationState>())
                                        .getLocation();
                                Logger.info("location: ${jsonEncode(map)}");
                                _addressTextEditingController.text =
                                    map['address'];
                                passwordCard.url = map['address'];
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              }
                            },
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {
                          passwordCard.url = val;
                        },
                        onSaved: (String val) {},
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "店铺地址不能为空";
                          }
                          if (val.length > 128 || val.length < 1) {
                            return "店铺地址长度只能是1到128位";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        readOnly: true,
                        focusNode: _expiredDateFocusNode,
                        maxLength: 10,
                        maxLengthEnforced: true,
                        controller: _folderTextEditingController,
                        decoration: InputDecoration(
                          labelText: '过期日期：',
                          suffixIcon: IconButton(
                            iconSize: 36.h,
                            icon: Icon(Icons.calendar_today),
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              DateTime dt = await showDatePicker(
                                context: context,
                                initialDate:
                                    DateTime.now().add(Duration(days: 365)),
                                firstDate:
                                    DateTime.now().subtract(Duration(days: 30)),
                                lastDate: DateTime.now()
                                    .add(Duration(days: 365 * 10)),
                              );
                            },
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {},
                        onSaved: (String val) {},
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "过期日期不能为空";
                          }
                          if (val.length != 10) {
                            return "过期日期长度只能10位";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        maxLength: 16,
                        maxLengthEnforced: true,
                        focusNode: _mobileFocusNode,
                        controller: _userNameextEditingController,
                        decoration: const InputDecoration(
                          labelText: '联系电话：',
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (String val) {},
                        onSaved: (String val) {},
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "联系电话不能为空";
                          }
                          if (val.length > 16 || val.length < 1) {
                            return "联系电话长度只能是1到128位";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
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
