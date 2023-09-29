class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'],
        firstName = map['firstName'],
        lastName = map['lastName'],
        createdAt = DateTime.parse(map['created_at']);
}
