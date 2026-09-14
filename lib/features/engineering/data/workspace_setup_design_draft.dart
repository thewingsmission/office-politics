class WorkspaceFieldDesignDraft {
  String title = '';
  String description = '';
  bool reviewed = false;
  double? relationshipScore;
}

abstract final class WorkspaceSetupDesignDraft {
  static final sections = <List<WorkspaceFieldDesignDraft>>[
    List.generate(6, (_) => WorkspaceFieldDesignDraft()),
    List.generate(6, (_) => WorkspaceFieldDesignDraft()),
    List.generate(6, (_) => WorkspaceFieldDesignDraft()),
    List.generate(5, (_) => WorkspaceFieldDesignDraft()),
  ];

  static void clear() {
    for (final section in sections) {
      for (final field in section) {
        field
          ..title = ''
          ..description = ''
          ..reviewed = false
          ..relationshipScore = null;
      }
    }
  }
}
