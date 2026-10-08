import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String planCode;
  final bool isGuest;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.planCode,
    this.isGuest = false,
  });

  bool get isPro => planCode.toLowerCase().contains('pro');

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl, planCode, isGuest];
}
