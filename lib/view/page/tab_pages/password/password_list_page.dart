import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smzg/manager/statefull/password_list_state.dart';
import 'package:flutter_smzg/manager/statefull/home_state.dart';
import 'package:flutter_smzg/model/password.dart';
import 'package:flutter_smzg/routes/routers.dart';
import 'package:flutter_fordova/flutter_fordova.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccountListPage extends StatelessWidget {
  const AccountListPage();
  Widget build(BuildContext context) {
    return Consumer2<PasswordListState, HomeState>(
      builder: (context, accountListState, homeState, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("密码收藏"),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    //
                  })
            ],
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (accountListState.busy) {
                      return SkeletonList(
                        builder: (context, index) => SkeletonItem(),
                      );
                    }
                    if (accountListState.error &&
                        accountListState.list.isEmpty) {
                      return ViewStateErrorWidget(
                          error: accountListState.pageStateError,
                          onPressed: accountListState.initData);
                    }
                    if (accountListState.empty) {
                      return ViewStateEmptyWidget(
                          image: SizedBox.shrink(),
                          buttonText:
                              FlatButton(onPressed: () {}, child: Text("新建")),
                          message: "内容为空",
                          onPressed: accountListState.initData);
                    }
                    return SmartRefresher(
                      controller: accountListState.refreshController,
                      header: const WaterDropHeader(),
                      footer: const ClassicFooter(),
                      onRefresh: () async {
                        await accountListState.refresh(init: true);
                      },
                      onLoading: () async {
                        await accountListState.loadMore();
                      },
                      enablePullUp: true,
                      child: ListView.builder(
                        itemCount: accountListState.list.length,
                        itemBuilder: (context, index) {
                          final Password account = accountListState.list[index];

                          return ListTile(
                            leading: Icon(Icons.people),
                            title: Text(account.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () async {
                                await Routers()
                                    .goAccountDetail(context, account);
                              },
                            ),
                            onTap: () async {
                              await Routers().goAccountDetail(context, account);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
