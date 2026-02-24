class Contact {
  final String id;
  final String userId; // The owner of this contact entry
  final String firstName;
  final String? lastName;
  final String? displayName;

  Contact({
    required this.id,
    required this.userId,
    required this.firstName,
    this.lastName,
    this.displayName,
  });

  String get fullName => '$firstName ${lastName ?? ''}'.trim();

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      displayName: json['display_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'display_name': displayName,
      'user_id': userId,
    };
  }
}
