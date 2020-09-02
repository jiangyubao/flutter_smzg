import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smzg/manager/statefull/password_list_state.dart';
import 'package:flutter_smzg/model/password.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class AccountDetailPage extends StatelessWidget {
  final ScreenshotController screenshotController = ScreenshotController();
  final Password account;
  AccountDetailPage(this.account);
  Widget build(BuildContext context) {
    return Consumer<PasswordListState>(
      builder: (context, accountListState, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("${account.name}"),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
