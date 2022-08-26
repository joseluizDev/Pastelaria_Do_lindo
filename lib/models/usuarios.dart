class Usuarios {
  final String user;
  final String pass;
  final bool admin;
  Usuarios({
    required this.user,
    required this.pass,
    required this.admin,
  });

  factory Usuarios.fromJson(Map<String, dynamic> json) {
    return Usuarios(
      user: json['user'] as String,
      pass: json['pass'] as String,
      admin: json['admin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'pass': pass,
      'admin': admin,
    };
  }
}
