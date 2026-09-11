import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/account_profile.dart';
import 'account_repository.dart';

class LocalAccountRepository implements AccountRepository {
  LocalAccountRepository({this._prefs});

  static const _accountsKey = 'account.password_hashes';
  static const _profilesKey = 'account.profiles';
  static const _sessionKey = 'account.session_id';

  final SharedPreferences? _prefs;
  final _uuid = const Uuid();
  final _passwordHashes = <String, String>{};
  final _profiles = <String, AccountProfile>{};
  String? _sessionId;

  Future<void> hydrate() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final accountsRaw = prefs.getString(_accountsKey);
    if (accountsRaw != null) {
      final decoded = jsonDecode(accountsRaw) as Map<String, dynamic>;
      _passwordHashes
        ..clear()
        ..addAll(decoded.map((key, value) => MapEntry(key, value as String)));
    }

    final profilesRaw = prefs.getString(_profilesKey);
    if (profilesRaw != null) {
      final decoded = jsonDecode(profilesRaw) as Map<String, dynamic>;
      _profiles
        ..clear()
        ..addAll(
          decoded.map(
            (key, value) => MapEntry(
              key,
              AccountProfile.fromJson(value as Map<String, dynamic>),
            ),
          ),
        );
    }

    _sessionId = prefs.getString(_sessionKey);
  }

  @override
  Future<AccountProfile?> current() async {
    final id = _sessionId;
    if (id == null) return null;
    return _profiles[id];
  }

  @override
  Future<AccountProfile> signIn({
    required String email,
    required String password,
  }) async {
    final normalized = _normalizeEmail(email);
    _validateCredentials(normalized, password);
    final hash = _passwordHashes[normalized];
    if (hash == null || hash != _hash(normalized, password)) {
      throw const AccountException('invalidCredentials');
    }
    final profile = _profiles.values.firstWhere(
      (item) => item.email == normalized,
    );
    _sessionId = profile.id;
    await _persist();
    return profile;
  }

  @override
  Future<AccountProfile> signUp({
    required String email,
    required String password,
  }) async {
    final normalized = _normalizeEmail(email);
    _validateCredentials(normalized, password);
    if (_passwordHashes.containsKey(normalized)) {
      throw const AccountException('emailTaken');
    }
    final profile = AccountProfile(id: _uuid.v4(), email: normalized);
    _passwordHashes[normalized] = _hash(normalized, password);
    _profiles[profile.id] = profile;
    _sessionId = profile.id;
    await _persist();
    return profile;
  }

  @override
  Future<void> signOut() async {
    _sessionId = null;
    await _persist();
  }

  @override
  Future<AccountProfile> subscribeMonthly() {
    return _updateAccess(
      AccessSource.subscription,
      DateTime.now().add(const Duration(days: 30)),
    );
  }

  @override
  Future<AccountProfile> grantContestPass(Duration duration) {
    return _updateAccess(AccessSource.contest, DateTime.now().add(duration));
  }

  @override
  Future<Map<String, dynamic>> exportAccount() async {
    final profile = await _requireProfile();
    return {
      'exported_at': DateTime.now().toIso8601String(),
      'storage': 'local',
      'profile': profile.toJson(),
    };
  }

  @override
  Future<void> deleteAccount() async {
    final profile = await _requireProfile();
    _profiles.remove(profile.id);
    _passwordHashes.remove(profile.email);
    _sessionId = null;
    await _persist();
  }

  Future<AccountProfile> _updateAccess(
    AccessSource source,
    DateTime until,
  ) async {
    final profile = await _requireProfile();
    final updated = profile.copyWith(accessSource: source, premiumUntil: until);
    _profiles[profile.id] = updated;
    await _persist();
    return updated;
  }

  Future<AccountProfile> _requireProfile() async {
    final profile = await current();
    if (profile == null) {
      throw const AccountException('notSignedIn');
    }
    return profile;
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_accountsKey, jsonEncode(_passwordHashes));
    await prefs.setString(
      _profilesKey,
      jsonEncode(_profiles.map((key, value) => MapEntry(key, value.toJson()))),
    );
    if (_sessionId == null) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, _sessionId!);
    }
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _hash(String email, String password) {
    return sha256.convert(utf8.encode('$email::$password')).toString();
  }

  void _validateCredentials(String email, String password) {
    if (!email.contains('@') || email.startsWith('@') || email.endsWith('@')) {
      throw const AccountException('invalidEmail');
    }
    if (password.length < 8) {
      throw const AccountException('weakPassword');
    }
  }
}
