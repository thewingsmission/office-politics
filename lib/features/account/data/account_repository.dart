import '../domain/account_profile.dart';

abstract class AccountRepository {
  Future<AccountProfile?> current();

  Future<AccountProfile> signIn({
    required String email,
    required String password,
  });

  Future<AccountProfile> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<AccountProfile> subscribeMonthly();

  Future<AccountProfile> grantContestPass(Duration duration);

  Future<Map<String, dynamic>> exportAccount();

  Future<void> deleteAccount();
}
