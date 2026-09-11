enum AccessSource {
  none,
  subscription,
  contest;

  static AccessSource fromId(String value) {
    return AccessSource.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AccessSource.none,
    );
  }
}

class AccountException implements Exception {
  const AccountException(this.code);

  final String code;

  @override
  String toString() => 'AccountException($code)';
}

class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.email,
    this.accessSource = AccessSource.none,
    this.premiumUntil,
  });

  final String id;
  final String email;
  final AccessSource accessSource;
  final DateTime? premiumUntil;

  bool get hasPremiumAccess {
    if (accessSource == AccessSource.none) return false;
    if (premiumUntil == null) {
      return accessSource == AccessSource.subscription;
    }
    return premiumUntil!.isAfter(DateTime.now());
  }

  AccountProfile copyWith({
    String? id,
    String? email,
    AccessSource? accessSource,
    DateTime? premiumUntil,
    bool clearPremiumUntil = false,
  }) {
    return AccountProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      accessSource: accessSource ?? this.accessSource,
      premiumUntil: clearPremiumUntil ? null : premiumUntil ?? this.premiumUntil,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'access_source': accessSource.name,
      'premium_until': premiumUntil?.toIso8601String(),
    };
  }

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    final until = json['premium_until'];
    return AccountProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      accessSource: AccessSource.fromId(
        json['access_source'] as String? ?? 'none',
      ),
      premiumUntil: until is String && until.isNotEmpty
          ? DateTime.parse(until)
          : null,
    );
  }
}
