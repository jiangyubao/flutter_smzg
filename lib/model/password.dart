class Password {
  int id = -1;
  String name;
  String account;
  String password;
  String description;
  Password({this.name, this.account, this.password, this.description});
  Password.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? -1,
        name = json['name'],
        account = json['account'],
        password = json['password'],
        description = json['description'];
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'account': account,
        'password': password,
        'description': description,
      };
}
