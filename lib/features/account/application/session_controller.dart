import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_repository.dart';
import '../domain/account_profile.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  throw StateError('accountRepositoryProvider must be overridden');
});

final sessionProvider =
    AsyncNotifierProvider<SessionController, AccountProfile?>(
      SessionController.new,
    );

class SessionController extends AsyncNotifier<AccountProfile?> {
  AccountRepository get _repo => ref.read(accountRepositoryProvider);

  @override
  Future<AccountProfile?> build() {
    return _repo.current();
  }

  Future<void> signIn({required String email, required String password}) {
    return _run(() => _repo.signIn(email: email, password: password));
  }

  Future<void> signUp({required String email, required String password}) {
    return _run(() => _repo.signUp(email: email, password: password));
  }

  Future<void> signOut() {
    return _run(() async {
      await _repo.signOut();
      return null;
    });
  }

  Future<void> subscribeMonthly() {
    return _run(_repo.subscribeMonthly);
  }

  Future<void> grantContestPass(Duration duration) {
    return _run(() => _repo.grantContestPass(duration));
  }

  Future<Map<String, dynamic>> exportAccount() {
    return _repo.exportAccount();
  }

  Future<void> deleteAccount() {
    return _run(() async {
      await _repo.deleteAccount();
      return null;
    });
  }

  Future<void> _run(Future<AccountProfile?> Function() action) async {
    try {
      state = AsyncData(await action());
    } catch (error, stackTrace) {
      if (state.value == null) {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }
}
