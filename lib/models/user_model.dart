class UserModel {
  final String id;
  final String email;
  final String firstname;
  final String lastname;
  final double? height;
  final double? weight;
  final String? goal;

  UserModel({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.height,
    this.weight,
    this.goal,
  });

  // Convert UserModel to JSON (for Firebase storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'height': height,
      'weight': weight,
      'goal': goal,
    };
  }

  // Create UserModel from JSON (from Firebase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      goal: json['goal'],
    );
  }
}
