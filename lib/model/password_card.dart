///密码卡
class PasswordCard {
  int id = 0;

  ///店铺名
  String name;

  ///店铺地址
  String url;

  ///联系电话
  String folder;

  ///初始额度
  String userName;

  ///剩余额度
  String sitePassword;

  ///密码卡过去日期
  String notes;

  ///默认构造函数
  PasswordCard({
    this.name,
    this.url,
    this.folder,
    this.userName,
    this.sitePassword,
    this.notes,
  });

  ///jsonMap转换为对象：sqlite数据库查询结果集转换为对象时需要
  PasswordCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        url = json['url'],
        folder = json['folder'],
        userName = json['userName'],
        sitePassword = json['sitePassword'],
        notes = json['notes'];

  ///新建空对象：新建密码卡需要
  PasswordCard.empty()
      : id = null,
        name = '',
        url = '',
        folder = '',
        userName = '',
        sitePassword = '',
        notes = '';

  ///克隆一个对象：编辑表单时，需要克隆表单对象，防止修改而未保存时就已经修改到provider状态对象
  PasswordCard.clone(PasswordCard passwordCard)
      : id = passwordCard.id,
        name = passwordCard.name,
        url = passwordCard.url,
        folder = passwordCard.folder,
        userName = passwordCard.userName,
        sitePassword = passwordCard.sitePassword,
        notes = passwordCard.notes;

  ///拷贝一个对象：更新密码卡成功后需要改写provider状态对象
  void copy(PasswordCard passwordCard) {
    this.name = passwordCard.name;
    this.url = passwordCard.url;
    this.folder = passwordCard.folder;
    this.userName = passwordCard.userName;
    this.sitePassword = passwordCard.sitePassword;
    this.notes = passwordCard.notes;
  }

  Map<String, dynamic> toBase64Json() => {
        'id': id,
        'name': name,
        'url': url,
        'folder': folder,
        'userName': userName,
        'sitePassword': sitePassword,
        'notes': notes,
      };

  PasswordCard.fromBase64Json(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        url = json['url'],
        folder = json['folder'],
        userName = json['userName'],
        sitePassword = json['sitePassword'],
        notes = json['notes'];
}
