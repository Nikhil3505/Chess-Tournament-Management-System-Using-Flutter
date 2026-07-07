class Player {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? createdAt;

  Player({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
