class User {
  final String ownerName;
  final String dairyName;
  final String mobile;
  final double a;
  final double b;
  final String password; // add this

  User({
    required this.ownerName,
    required this.dairyName,
    required this.mobile,
    this.a = 8,
    this.b = 2,
    this.password = '', // default empty
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      ownerName: json['o_name'] ?? '',
      dairyName: json['Dairy_name'] ?? '',
      mobile: json['Mobile_no'] ?? '',
      a: (json['a'] ?? 8).toDouble(),
      b: (json['b'] ?? 2).toDouble(),
      password: json['password'] ?? '', // optional from API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'o_name': ownerName,
      'Dairy_name': dairyName,
      'Mobile_no': mobile,
      'a': a,
      'b': b,
      'password': password,
    };
  }
}
