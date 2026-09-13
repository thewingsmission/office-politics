import 'package:flutter_test/flutter_test.dart';
import 'package:office_politics/features/engineering/data/workspace_suggestion_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

void main() {
  test(
    'live workplace suggestion returns six privacy-safe fields',
    () async {
      final service = WorkspaceSuggestionService(
        client: SupabaseClient(supabaseUrl, supabasePublishableKey),
      );

      final result = await service.suggest(
        section: WorkspaceSetupSection.workplace,
        prompt:
            'I work at a mid-sized regional travel technology company in Hong Kong. '
            'I am part of the product department.',
      );

      expect(result.isLive, isTrue);
      expect(result.fields, hasLength(6));
      expect(result.fields.first.title, isNotEmpty);
      expect(result.fields.first.description, isEmpty);
      expect(result.fields[1].title, isNotEmpty);
      expect(result.fields[2].title, isNotEmpty);
    },
    skip: supabaseUrl.isEmpty || supabasePublishableKey.isEmpty,
  );
}
