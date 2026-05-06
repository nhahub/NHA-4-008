class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'client' or 'provider'
  final String? address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id:      map['id'] ?? '',
    name:    map['name'] ?? '',
    email:   map['email'] ?? '',
    phone:   map['phone'] ?? '',
    role:    map['role'] ?? 'client',
    address: map['address'],
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'email': email,
    'phone': phone, 'role': role, 'address': address,
  };
}
