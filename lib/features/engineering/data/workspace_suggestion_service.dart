import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';

enum WorkspaceSetupSection {
  workplace('workplace'),
  yourself('yourself'),
  colleague('colleague'),
  relationship('relationship'),
  event('event'),
  advice('advice');

  const WorkspaceSetupSection(this.apiName);

  final String apiName;
}

class WorkspaceFieldSuggestion {
  const WorkspaceFieldSuggestion({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class WorkspaceSuggestionResult {
  const WorkspaceSuggestionResult({required this.fields, required this.isLive});

  final List<WorkspaceFieldSuggestion> fields;
  final bool isLive;
}

class WorkspaceSuggestionException implements Exception {
  const WorkspaceSuggestionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WorkspaceSuggestionService {
  const WorkspaceSuggestionService({this.client});

  final SupabaseClient? client;

  Future<WorkspaceSuggestionResult> suggest({
    required WorkspaceSetupSection section,
    required String prompt,
  }) async {
    if (!AppConfig.useSupabase) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      return WorkspaceSuggestionResult(
        fields: _previewSuggestions(section),
        isLive: false,
      );
    }

    final supabaseClient = client ?? Supabase.instance.client;
    final FunctionResponse response;
    try {
      response = await supabaseClient.functions.invoke(
        'workspace-suggestions',
        headers: {
          'Authorization':
              'Bearer ${supabaseClient.auth.currentSession?.accessToken ?? AppConfig.supabasePublishableKey}',
        },
        body: {'section': section.apiName, 'prompt': prompt},
      );
    } on FunctionException catch (error) {
      throw WorkspaceSuggestionException(_functionErrorMessage(error.status));
    }
    final data = response.data;
    final rawFields = data is Map ? data['fields'] : null;
    final expectedFieldCount = switch (section) {
      WorkspaceSetupSection.workplace => 6,
      WorkspaceSetupSection.yourself => 6,
      WorkspaceSetupSection.colleague => 6,
      WorkspaceSetupSection.relationship => 5,
      WorkspaceSetupSection.event => 9,
      WorkspaceSetupSection.advice => 5,
    };
    if (rawFields is! List || rawFields.length != expectedFieldCount) {
      throw const FormatException('Suggestion service returned invalid data');
    }

    final fields = rawFields.map((value) {
      final field = value is Map ? value : const <String, Object?>{};
      return WorkspaceFieldSuggestion(
        title: field['title']?.toString().trim() ?? '',
        description: field['description']?.toString().trim() ?? '',
      );
    }).toList();

    return WorkspaceSuggestionResult(fields: fields, isLive: true);
  }
}

List<WorkspaceFieldSuggestion> workspacePreviewSuggestions(
  WorkspaceSetupSection section,
) => _previewSuggestions(section);

String _functionErrorMessage(int status) {
  return switch (status) {
    0 =>
      'The politics consultant could not connect. Check your internet connection and try again.',
    401 || 403 =>
      'The politics consultant could not verify access. Restart the app and try again.',
    429 =>
      'The politics consultant is receiving too many requests. Wait a moment and try again.',
    >= 500 =>
      'The politics consultant service is temporarily unavailable. Try again shortly.',
    _ => 'The politics consultant could not analyze this text. Try again.',
  };
}

List<WorkspaceFieldSuggestion> _previewSuggestions(
  WorkspaceSetupSection section,
) {
  return switch (section) {
    WorkspaceSetupSection.workplace => const [
      WorkspaceFieldSuggestion(title: 'Financial services', description: ''),
      WorkspaceFieldSuggestion(title: 'Operations', description: ''),
      WorkspaceFieldSuggestion(title: 'Regional office', description: ''),
      WorkspaceFieldSuggestion(
        title: 'Fast, top-down decisions',
        description:
            '• Decision style\n  ◦ Leaders decide quickly\n  ◦ Disagreement is handled privately',
      ),
      WorkspaceFieldSuggestion(
        title: 'Cost pressure',
        description:
            '• Business pressure\n  ◦ Costs are being reduced\n  ◦ Priorities continue to change',
      ),
      WorkspaceFieldSuggestion(
        title: 'Matrix reporting',
        description:
            '• Organizational context\n  ◦ Several departments influence project decisions',
      ),
    ],
    WorkspaceSetupSection.yourself => const [
      WorkspaceFieldSuggestion(
        title: 'Product analyst',
        description:
            '• Main responsibilities\n  ◦ Analyze product data\n  ◦ Coordinate findings across teams',
      ),
      WorkspaceFieldSuggestion(title: 'Female', description: ''),
      WorkspaceFieldSuggestion(title: '25–34', description: ''),
      WorkspaceFieldSuggestion(title: 'Two years', description: ''),
      WorkspaceFieldSuggestion(
        title: 'Protect credibility',
        description:
            '• Professional goals\n  ◦ Protect credibility\n  ◦ Remain eligible for promotion',
      ),
      WorkspaceFieldSuggestion(
        title: 'New to senior meetings',
        description:
            '• Work context\n  ◦ Cannot make final decisions independently\n  ◦ Recently began attending senior planning meetings',
      ),
    ],
    WorkspaceSetupSection.colleague => const [
      WorkspaceFieldSuggestion(title: 'Alex', description: ''),
      WorkspaceFieldSuggestion(
        title: 'Project manager',
        description:
            '• Main responsibilities\n  ◦ Coordinate plans and deadlines\n  ◦ Report progress to stakeholders',
      ),
      WorkspaceFieldSuggestion(title: 'Male', description: ''),
      WorkspaceFieldSuggestion(title: '35–44', description: ''),
      WorkspaceFieldSuggestion(
        title: 'Direct and deadline-focused',
        description:
            '• Observed communication\n  ◦ Communicates directly\n  ◦ Focuses strongly on delivery deadlines',
      ),
      WorkspaceFieldSuggestion(
        title: 'Strong executive access',
        description:
            '• Informal influence\n  ◦ Regularly briefs a senior executive',
      ),
    ],
    WorkspaceSetupSection.relationship => const [
      WorkspaceFieldSuggestion(
        title: 'Frequent collaborator',
        description:
            '• Work connection\n  ◦ Peers in different teams\n  ◦ Share responsibility for product initiatives',
      ),
      WorkspaceFieldSuggestion(
        title: 'Deadline disagreement',
        description:
            '• Recent disagreement\n  ◦ Disputed ownership of a missed deadline\n  ◦ Escalated the discussion by email',
      ),
      WorkspaceFieldSuggestion(
        title: 'Tense but workable',
        description:
            '• Current dynamic\n  ◦ Communication is formal\n  ◦ Cooperation continues on required work',
      ),
      WorkspaceFieldSuggestion(title: 'Bad', description: ''),
      WorkspaceFieldSuggestion(
        title: 'Needs careful documentation',
        description:
            '• Practical context\n  ◦ Important decisions are best confirmed in writing',
      ),
    ],
    WorkspaceSetupSection.event => const [
      WorkspaceFieldSuggestion(
        title: 'Deadline ownership escalation',
        description: '',
      ),
      WorkspaceFieldSuggestion(
        title: '12 September 2026, 3:30 PM',
        description: '',
      ),
      WorkspaceFieldSuggestion(
        title: 'You, Alex, Director Lee',
        description: '',
      ),
      WorkspaceFieldSuggestion(
        title: 'Ownership challenged by email',
        description:
            '• What Happened\n  ◦ Alex disputed ownership of the missed deadline\n  ◦ The director was copied into the reply\n• Immediate Outcome\n  ◦ A clarification meeting was requested',
      ),
      WorkspaceFieldSuggestion(
        title: 'Worried and frustrated',
        description:
            '• Personal Feeling\n  ◦ Worried about reputation\n  ◦ Frustrated by the public escalation',
      ),
      WorkspaceFieldSuggestion(title: '78', description: ''),
      WorkspaceFieldSuggestion(title: '68', description: ''),
      WorkspaceFieldSuggestion(title: '72', description: ''),
      WorkspaceFieldSuggestion(title: '84', description: ''),
    ],
    WorkspaceSetupSection.advice => const [
      WorkspaceFieldSuggestion(
        title: 'Deadline ownership dispute',
        description:
            '• Situation\n  ◦ A colleague disputed ownership of a missed deadline\n  ◦ A director was copied into the email exchange',
      ),
      WorkspaceFieldSuggestion(
        title: 'Protect credibility',
        description:
            '• Desired Outcome\n  ◦ Correct the record without escalating conflict',
      ),
      WorkspaceFieldSuggestion(
        title: 'You, Alex, Director Lee',
        description: '',
      ),
      WorkspaceFieldSuggestion(
        title: 'Email escalation',
        description:
            '• Observable Evidence\n  ◦ The deadline ownership was challenged in writing\n  ◦ The director received the message',
      ),
      WorkspaceFieldSuggestion(
        title: 'Timeline and prior agreement',
        description:
            '• Missing Information\n  ◦ Who accepted ownership before the deadline\n  ◦ Whether a written project plan records that decision',
      ),
    ],
  };
}
