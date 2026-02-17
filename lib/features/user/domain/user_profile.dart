class UserProfileData {
  final String id;
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;

  UserProfileData({
    required this.id,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
  });

  factory UserProfileData.fromMap(Map<String, dynamic> m) {
    DateTime? dob;
    final dobRaw = m['date_of_birth'];
    if (dobRaw is String && dobRaw.isNotEmpty) {
      dob = DateTime.parse(dobRaw);
    } else {
      dob = null;
    }
    return UserProfileData(
      id: m['id'] as String,
      firstName: m['first_name'] as String?,
      lastName: m['last_name'] as String?,
      dateOfBirth: dob,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "first_name": firstName,
      "last_name": lastName,
      "date_of_birth": dateOfBirth?.toIso8601String(),
    };
  }

  bool isComplete() {
    return (firstName != null && firstName!.trim().isNotEmpty) &&
        (lastName != null && lastName!.trim().isNotEmpty) &&
        (dateOfBirth != null);
  }
}
