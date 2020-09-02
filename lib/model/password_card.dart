import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_smzg/util/date_util.dart';

///充值卡
class PasswordCard {
  int id = 0;

  ///店铺名
  String name;

  ///店铺地址
  String address;

  ///联系电话
  String mobile;

  ///初始额度
  int init;

  ///剩余额度
  int current;

  ///充值卡拍照
  Uint8List image;

  ///充值卡过去日期
  String expiredDate;

  ///默认构造函数
  PasswordCard({
    this.name,
    this.address,
    this.mobile,
    this.init,
    this.current,
    this.image,
    this.expiredDate,
  });

  ///jsonMap转换为对象：sqlite数据库查询结果集转换为对象时需要
  PasswordCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        address = json['address'],
        mobile = json['mobile'],
        init = json['init'],
        current = json['current'],
        image = json['image'],
        expiredDate = json['expiredDate'];

  ///新建空对象：新建充值卡需要
  PasswordCard.empty()
      : id = null,
        name = '',
        address = '',
        mobile = '',
        init = 0,
        current = 0,
        image = null,
        expiredDate =
            DateUtil.formatShortDate(DateTime.now().add(Duration(days: 365)));

  ///克隆一个对象：编辑表单时，需要克隆表单对象，防止修改而未保存时就已经修改到provider状态对象
  PasswordCard.clone(PasswordCard passwordCard)
      : id = passwordCard.id,
        name = passwordCard.name,
        address = passwordCard.address,
        mobile = passwordCard.mobile,
        init = passwordCard.init,
        current = passwordCard.current,
        image = passwordCard.image,
        expiredDate = passwordCard.expiredDate;

  ///拷贝一个对象：更新充值卡成功后需要改写provider状态对象
  void copy(PasswordCard passwordCard) {
    this.name = passwordCard.name;
    this.address = passwordCard.address;
    this.mobile = passwordCard.mobile;
    this.init = passwordCard.init;
    this.current = passwordCard.current;
    this.image = passwordCard.image;
    this.expiredDate = passwordCard.expiredDate;
  }

  Map<String, dynamic> toBase64Json() => {
        'id': id,
        'name': name,
        'address': address,
        'mobile': mobile,
        'init': init,
        'current': current,
        'image': image != null ? base64Encode(image) : null,
        'expiredDate': expiredDate,
      };

  PasswordCard.fromBase64Json(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        address = json['address'],
        mobile = json['mobile'],
        init = json['init'],
        current = json['current'],
        image = json['image'] != null ? base64Decode(json['image']) : null,
        expiredDate = json['expiredDate'];
}
