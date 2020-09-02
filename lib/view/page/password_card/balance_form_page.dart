import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BalanceFormPage extends StatefulWidget {
  final int value;
  final String title;
  BalanceFormPage({this.title, this.value, Key key}) : super(key: key);

  @override
  _BalanceFormPageState createState() => _BalanceFormPageState(value: value);
}

class _BalanceFormPageState extends State<BalanceFormPage> {
  GlobalKey<FormState> _key = GlobalKey();
  int value;
  _BalanceFormPageState({this.value});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop<String>();
          },
          icon: const Icon(Icons.close),
        ),
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (_key.currentState.validate()) {
                Navigator.of(context).pop<int>(value);
              } else {
                //showToast("金额长度只能是1到8位");
                DialogService().nativeAlert("操作失败", "金额长度只能是1到8位");
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _key,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 80.w, vertical: 60.h),
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: "$value",
                decoration: const InputDecoration(
                  labelText: '金额：',
                ),
                keyboardType: TextInputType.number,
                onChanged: (String val) {
                  setState(() {
                    value = int.parse(val);
                  });
                },
                onSaved: (String val) {},
                validator: (String val) {
                  if (val.isEmpty) {
                    return "金额不能为空";
                  }
                  if (val.length > 8 || val.length < 1) {
                    return "金额长度只能是1到8位";
                  }
                  if (int.parse(val) <= 0) {
                    return "金额只能是正整数";
                  }
                  return null;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
