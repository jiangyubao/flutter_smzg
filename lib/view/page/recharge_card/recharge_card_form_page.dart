import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smzg/model/recharge_card.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/recharge_card_list_state.dart';
import 'package:flutter_smzg/util/date_util.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

///充值卡表单
class RechargeCardFormPage extends StatefulWidget {
  final RechargeCard rechargeCard;
  RechargeCardFormPage({Key key, this.rechargeCard}) : super(key: key);
  @override
  _RechargeCardFormPageState createState() =>
      _RechargeCardFormPageState(this.rechargeCard);
}

class _RechargeCardFormPageState extends State<RechargeCardFormPage> {
  RechargeCard rechargeCard;
  final GlobalKey<FormState> _key = GlobalKey();
  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _addressTextEditingController = TextEditingController();
  TextEditingController _expiredDateTextEditingController =
      TextEditingController(
          text: DateUtil.formatShortDate(
              DateTime.now().add(Duration(days: 365))));
  TextEditingController _mobileTextEditingController = TextEditingController();
  TextEditingController _initTextEditingController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _expiredDateFocusNode = FocusNode();
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _initFocusNode = FocusNode();

  _RechargeCardFormPageState(this.rechargeCard);
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
    _nameTextEditingController.text = rechargeCard.name;
    _addressTextEditingController.text = rechargeCard.address;
    _expiredDateTextEditingController.text = rechargeCard.expiredDate;
    _mobileTextEditingController.text = rechargeCard.mobile;
    _initTextEditingController.text = "${rechargeCard.init}";
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
    return Consumer2<RechargeCardListState, ConfigState>(
      builder: (context, rechargeCardListState, configState, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: rechargeCard.id == null
                ? const Text("新建充值卡")
                : const Text("修改充值卡"),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () async {
                    if (_key.currentState.validate()) {
                      if (rechargeCard.image == null) {
                        await DialogService()
                            .nativeAlert("充值卡照不能为空", "请重新选择充值卡照", ok: "确定");
                        FocusScope.of(context).requestFocus(FocusNode());
                        return;
                      }
                      rechargeCard.current = rechargeCard.init;
                      if (rechargeCard.id == null) {
                        int id =
                            await rechargeCardListState.insert(rechargeCard);
                        if (id < 0) {
                          await DialogService()
                              .nativeAlert("保存失败", "系统已存在相同名字的充值卡", ok: "确定");
                          _nameFocusNode.requestFocus();
                        } else {
                          Routers().pop(context);
                        }
                      } else {
                        bool result =
                            await rechargeCardListState.update(rechargeCard);
                        if (!result) {
                          await DialogService()
                              .nativeAlert("保存失败", "系统已存在相同名字的充值卡", ok: "确定");
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
                          rechargeCard.name = val;
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
                                rechargeCard.address = map['address'];
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              }
                            },
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {
                          rechargeCard.address = val;
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
                        controller: _expiredDateTextEditingController,
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
                              if (dt != null) {
                                rechargeCard.expiredDate =
                                    DateUtil.formatShortDate(dt);
                                _expiredDateTextEditingController.text =
                                    rechargeCard.expiredDate;
                              }
                            },
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {
                          rechargeCard.expiredDate = val;
                        },
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
                        controller: _mobileTextEditingController,
                        decoration: const InputDecoration(
                          labelText: '联系电话：',
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (String val) {
                          rechargeCard.mobile = val;
                        },
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
                      TextFormField(
                        maxLength: 8,
                        maxLengthEnforced: true,
                        focusNode: _initFocusNode,
                        controller: _initTextEditingController,
                        decoration: const InputDecoration(
                          labelText: '充值金额：',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (String val) {
                          rechargeCard.init = int.parse(val);
                        },
                        onSaved: (String val) {},
                        validator: (String val) {
                          if (val.isEmpty) {
                            return "充值金额不能为空";
                          }
                          if (val.length > 8 || val.length < 1) {
                            return "充值金额长度只能是1到8位";
                          }
                          if (int.parse(val) <= 0) {
                            return "金额只能是正整数";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      InkWell(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          PickedFile file =
                              await this._selectImage(250 * 2.w, 340 * 2.h);
                          if (file != null) {
                            rechargeCard.image = await file.readAsBytes();
                            setState(() {});
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 2.w,
                                color: Theme.of(context).primaryColor),
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.w)),
                          ),
                          height: 667.w,
                          width: 375.h,
                          child: Center(
                            child: rechargeCard.image != null
                                ? Image.memory(rechargeCard.image)
                                : Text(
                                    "充值卡照片",
                                    style: TextStyle(fontSize: 36.sp),
                                  ),
                          ),
                        ),
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
