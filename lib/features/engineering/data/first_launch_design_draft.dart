enum AvatarSexDesignScreen { female, male, unspecified }

abstract final class FirstLaunchDesignDraft {
  static String selfSex = '';
  static String selfAgeRange = '';
  static String colleagueSex = '';
  static String colleagueAgeRange = '';

  static AvatarSexDesignScreen parseSex(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('female') ||
        normalized.contains('woman') ||
        normalized.contains('girl')) {
      return AvatarSexDesignScreen.female;
    }
    if (normalized.contains('male') ||
        normalized.contains('man') ||
        normalized.contains('boy')) {
      return AvatarSexDesignScreen.male;
    }
    return AvatarSexDesignScreen.unspecified;
  }
}
