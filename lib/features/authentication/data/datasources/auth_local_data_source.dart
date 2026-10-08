import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:removeit_app/core/constants/storage_keys.dart';
import 'package:removeit_app/features/authentication/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<String> getOrCreateDeviceUuid();
  Future<void> clearAuthSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await secureStorage.write(key: StorageKeys.accessToken, value: accessToken);
    await secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await sharedPreferences.setString(StorageKeys.userId, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = sharedPreferences.getString(StorageKeys.userId);
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> getOrCreateDeviceUuid() async {
    var uuid = await secureStorage.read(key: StorageKeys.deviceUuid);
    if (uuid == null || uuid.isEmpty) {
      // Generate hardware-session identifier
      uuid = 'device_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecondsSinceEpoch % 100000)}';
      await secureStorage.write(key: StorageKeys.deviceUuid, value: uuid);
    }
    return uuid;
  }

  @override
  Future<void> clearAuthSession() async {
    await secureStorage.delete(key: StorageKeys.accessToken);
    await secureStorage.delete(key: StorageKeys.refreshToken);
    await sharedPreferences.remove(StorageKeys.userId);
  }
}
