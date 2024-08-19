class User {
  final int userId;
  final String username;
  final String firstName;
  final String lastName;
  final String roleName;
  final String lastLoginAt;

  User(
    {
      required this.userId,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.roleName,
      required this.lastLoginAt
    }
  );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['user_name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      roleName: json['role_name'],
      lastLoginAt: json['last_login_at']
    );
  }
}
