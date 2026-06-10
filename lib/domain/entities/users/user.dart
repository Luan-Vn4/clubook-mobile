import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {

  final String id;

  final String username;

  final String email;

  final String firstName;

  final String lastName;

  final String? imageUrl;

  @JsonKey(defaultValue: 0)
  final int totalClubs;

  String get fullName => '$firstName $lastName';

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
    this.totalClubs = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

}