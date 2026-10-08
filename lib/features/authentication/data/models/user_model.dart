import 'package:removeit_app/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    required super.planCode,
    super.isGuest = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] as String?,
      planCode: json['plan_code'] as String? ?? 'free',
      isGuest: json['is_guest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'plan_code': planCode,
      'is_guest': isGuest,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      planCode: entity.planCode,
      isGuest: entity.isGuest,
    );
  }
}
