import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smzg/model/password_card.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_smzg/service/statefull/password_card_list_state.dart';
import 'package:flutter_smzg/util/smzg_icon_font.dart';
import 'package:url_launcher/url_launcher.dart';

class CardBodyWidget extends StatelessWidget {
  const CardBodyWidget({
    Key key,
    @required this.passwordCard,
  }) : super(key: key);

  final PasswordCard passwordCard;

  @override
  Widget build(BuildContext context) {
    final TextStyle _textStyle = TextStyle(
        fontWeight: FontWeight.w600, letterSpacing: 0.5, fontSize: 28.sp);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Text(
              '账号：',
              style: _textStyle,
            ),
            Expanded(
              child: Text(
                passwordCard.userName,
                style: _textStyle,
              ),
            ),
            IconButton(
              icon: Icon(
                SmzgIconFont.qrcode,
              ),
              onPressed: () async {
                if (!await locator
                    .get<PasswordCardListState>()
                    .requestLocalAuth()) {
                  return;
                }
                await Routers().goPasswordCardImage(context, passwordCard.id);
              },
            ),
            SizedBox(
              width: 8.w,
            ),
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: passwordCard.userName));
                await DialogService().nativeAlert("账号已拷贝", "");
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(
              '密码：',
              style: _textStyle,
            ),
            Expanded(
              child: Text(
                passwordCard.showPassword
                    ? passwordCard.sitePassword
                    : "********",
                style: _textStyle,
              ),
            ),
            IconButton(
              icon: Icon(
                SmzgIconFont.eye,
              ),
              onPressed: () async {
                if (!await locator
                    .get<PasswordCardListState>()
                    .requestLocalAuth()) {
                  return;
                }
                locator.get<PasswordCardListState>().updatePasswordShow(
                    passwordCard.id, passwordCard.showPassword);
              },
            ),
            SizedBox(
              width: 8.w,
            ),
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () async {
                if (!await locator
                    .get<PasswordCardListState>()
                    .requestLocalAuth()) {
                  return;
                }
                await Clipboard.setData(
                    ClipboardData(text: passwordCard.sitePassword));
                await DialogService().nativeAlert("密码已拷贝", "");
              },
            ),
          ],
        ),
        SizedBox(
          height: 4.h,
        ),
        Row(
          children: [
            Text(
              '网址：',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _textStyle,
            ),
            Expanded(
              child: Text(
                passwordCard.url,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _textStyle,
              ),
            ),
            IconButton(
              icon: Icon(
                SmzgIconFont.safari,
              ),
              onPressed: () async {
                await launch(
                  passwordCard.url,
                  forceSafariVC: false,
                  enableDomStorage: true,
                  enableJavaScript: true,
                );
              },
            ),
            SizedBox(
              width: 8.w,
            ),
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: passwordCard.url));
                await DialogService().nativeAlert("网址已拷贝", "");
              },
            ),
          ],
        ),
      ],
    );
  }
}
