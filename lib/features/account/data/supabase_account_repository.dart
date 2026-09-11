import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/account_profile.dart';
import 'account_repository.dart';

class SupabaseAccountRepository implements AccountRepository {
  SupabaseAccountRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AccountProfile?> current() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _profileFor(user);
  }

  @override
  Future<AccountProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;
      if (user == null) {
        throw const AccountException('invalidCredentials');
      }
      return _profileFor(user);
    } on AuthException catch (error) {
      throw _mapAuth(error);
    }
  }

  @override
  Future<AccountProfile> signUp({
    required String email,
    required String password,
  }) async {
    if (password.length < 8) {
      throw const AccountException('weakPassword');
    }
    try {
      final result = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = result.user;
      if (user == null || result.session == null) {
        throw const AccountException('confirmEmail');
      }
      return _profileFor(user);
    } on AuthException catch (error) {
      throw _mapAuth(error);
    }
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
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
      'storage': 'supabase',
      'profile': profile.toJson(),
    };
  }

  @override
  Future<void> deleteAccount() async {
    await _client.rpc<void>('delete_own_account');
    await _client.auth.signOut();
  }

  Future<AccountProfile> _updateAccess(
    AccessSource source,
    DateTime until,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AccountException('notSignedIn');
    }
    final data = await _client
        .from('profiles')
        .update({
          'access_source': source.name,
          'premium_until': until.toIso8601String(),
        })
        .eq('id', user.id)
        .select()
        .single();
    return AccountProfile.fromJson(data);
  }

  Future<AccountProfile> _requireProfile() async {
    final profile = await current();
    if (profile == null) {
      throw const AccountException('notSignedIn');
    }
    return profile;
  }

  Future<AccountProfile> _profileFor(User user) async {
    final existing = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (existing != null) {
      return AccountProfile.fromJson(existing);
    }
    final inserted = await _client
        .from('profiles')
        .insert({'id': user.id, 'email': user.email ?? ''})
        .select()
        .single();
    return AccountProfile.fromJson(inserted);
  }

  AccountException _mapAuth(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login') ||
        message.contains('invalid credentials')) {
      return const AccountException('invalidCredentials');
    }
    if (message.contains('already registered')) {
      return const AccountException('emailTaken');
    }
    if (message.contains('password')) {
      return const AccountException('weakPassword');
    }
    return const AccountException('genericError');
  }
}
