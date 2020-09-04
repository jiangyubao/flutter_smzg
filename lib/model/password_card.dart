///密码卡
class PasswordCard {
  int id = 0;

  ///别名
  String nickName;

  ///网址
  String url;

  ///用户名
  String userName;

  ///用户密码
  String sitePassword;

  ///是否显示密码
  bool showPassword = false;

  ///默认构造函数
  PasswordCard({
    this.nickName,
    this.url,
    this.userName,
    this.sitePassword,
  });

  ///jsonMap转换为对象：sqlite数据库查询结果集转换为对象时需要
  PasswordCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nickName = json['nickName'],
        url = json['url'],
        userName = json['userName'],
        sitePassword = json['sitePassword'];

  ///新建空对象：新建密码卡需要
  PasswordCard.empty()
      : id = null,
        nickName = '',
        url = '',
        userName = '',
        sitePassword = '';

  ///克隆一个对象：编辑表单时，需要克隆表单对象，防止修改而未保存时就已经修改到provider状态对象
  PasswordCard.clone(PasswordCard passwordCard)
      : id = passwordCard.id,
        nickName = passwordCard.nickName,
        url = passwordCard.url,
        userName = passwordCard.userName,
        sitePassword = passwordCard.sitePassword;

  ///拷贝一个对象：更新密码卡成功后需要改写provider状态对象
  void copy(PasswordCard passwordCard) {
    this.nickName = passwordCard.nickName;
    this.url = passwordCard.url;
    this.userName = passwordCard.userName;
    this.sitePassword = passwordCard.sitePassword;
  }

  Map<String, dynamic> toBase64Json() => {
        'id': id,
        'nickName': nickName,
        'url': url,
        'userName': userName,
        'sitePassword': sitePassword,
      };

  PasswordCard.fromBase64Json(Map<String, dynamic> json)
      : id = json['id'],
        nickName = json['nickName'],
        url = json['url'],
        userName = json['userName'],
        sitePassword = json['sitePassword'];
}
