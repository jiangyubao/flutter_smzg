import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smzg/manager/statefull/password_list_state.dart';
import 'package:flutter_smzg/manager/stateless/http_manager.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage();

  Future<String> _buildVersionString() async {
    final String appVersion = await PlatformService().getAppVersion();
    final String buildNum = await PlatformService().getBuildNum();
    return "$appVersion+$buildNum";
  }

  void _switchDarkMode(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    } else {
      Provider.of<ThemeState>(context, listen: false).switchTheme(
          userDarkMode: Theme.of(context).brightness == Brightness.light);
    }
  }

  Widget build(BuildContext context) {
    return Consumer<PasswordListState>(
      builder: (context, accountListState, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("系统设置"),
            actions: <Widget>[],
          ),
          body: ListView(
            children: <Widget>[
              FutureBuilder(
                  future: this._buildVersionString(),
                  initialData: "",
                  builder: (context, snapData) {
                    return ListTile(
                      title: const Text("软件版本："),
                      trailing: Text("${snapData.data}"),
                    );
                  }),
              ListTile(
                title: const Text("云端备份："),
                onTap: () async {
                  await HttpManager().upload(context, accountListState);
                },
                trailing: Icon(Icons.cloud_upload),
              ),
              ListTile(
                title: const Text("云端恢复："),
                onTap: () async {
                  await HttpManager().download(context, accountListState);
                },
                trailing: Icon(Icons.cloud_download),
              ),
              /*
              ListTile(
                title: const Text("反馈建议："),
                onTap: () async {
                  final String url =
                      'mailto:23674242@qq.com?subject=feedback&body=feedback';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    await Future.delayed(Duration(seconds: 1));
                    launch(
                        'https://github.com/ishemant/ishemant.github.io/issues',
                        forceSafariVC: true);
                  }
                },
                trailing: Icon(Icons.chevron_right),
              ),*/
              ListTile(
                title: const Text("暗黑模式："),
                onTap: () {
                  _switchDarkMode(context);
                },
                trailing: CupertinoSwitch(
                  activeColor: Theme.of(context).accentColor,
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    _switchDarkMode(context);
                  },
                ),
              ),
              /*
              ListTile(
                title: const Text("隐私协议："),
                onTap: () async {
                  await Routers().goThridPartWebView(
                      context,
                      await MdManager().buildMarkdownFileUrl(
                          context, "assets/doc/privacy.md"));
                },
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                title: const Text("服务协议："),
                onTap: () async {
                  await Routers().goThridPartWebView(
                      context,
                      await MdManager().buildMarkdownFileUrl(
                          context, "assets/doc/agreement.md"));
                },
                trailing: Icon(Icons.chevron_right),
              ),
              */
            ],
          ),
        );
      },
    );
  }
}
