import 'package:flutter_test/flutter_test.dart';
import 'package:office_politics/features/account/domain/account_profile.dart';

void main() {
  test('subscription without expiry is premium', () {
    const profile = AccountProfile(
      id: '1',
      email: 'user@example.com',
      accessSource: AccessSource.subscription,
    );
    expect(profile.hasPremiumAccess, isTrue);
  });

  test('expired contest pass is free', () {
    final profile = AccountProfile(
      id: '1',
      email: 'user@example.com',
      accessSource: AccessSource.contest,
      premiumUntil: DateTime.now().subtract(const Duration(hours: 1)),
    );
    expect(profile.hasPremiumAccess, isFalse);
  });
}
