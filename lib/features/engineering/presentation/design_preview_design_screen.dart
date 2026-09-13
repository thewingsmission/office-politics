import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../domain/design_screen_definition.dart';
import 'design_back_button.dart';

class DesignPreviewDesignScreen extends StatelessWidget {
  const DesignPreviewDesignScreen({super.key, required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DesignBackButton(onPressed: () => context.go('/engineering')),
              const SizedBox(height: 12),
              Expanded(child: _DesignCanvas(definition: definition)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesignCanvas extends StatelessWidget {
  const _DesignCanvas({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: _PreviewBody(definition: definition),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    if (definition.id == 'language-setup') {
      return const _LanguageSetupPreview();
    }
    return switch (definition.kind) {
      DesignPreviewKind.dashboard => _DashboardPreview(definition: definition),
      DesignPreviewKind.form => _FormPreview(definition: definition),
      DesignPreviewKind.list => _ListPreview(definition: definition),
      DesignPreviewKind.detail => _DetailPreview(definition: definition),
      DesignPreviewKind.conversation => _ConversationPreview(
        definition: definition,
      ),
      DesignPreviewKind.canvas => _CanvasPreview(definition: definition),
      DesignPreviewKind.game => _GamePreview(definition: definition),
      DesignPreviewKind.settings => _SettingsPreview(definition: definition),
    };
  }
}

class _LanguageSetupPreview extends StatefulWidget {
  const _LanguageSetupPreview();

  @override
  State<_LanguageSetupPreview> createState() => _LanguageSetupPreviewState();
}

class _LanguageSetupPreviewState extends State<_LanguageSetupPreview> {
  int selectedLanguageDesignScreen = 0;

  @override
  Widget build(BuildContext context) {
    const languages = ['English', '简体中文', '繁體中文'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Choose your language',
          style: TextStyle(
            color: Color(0xFF173F5D),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            for (var index = 0; index < languages.length; index++) ...[
              if (index > 0) const SizedBox(width: 22),
              Expanded(
                child: AppButton(
                  label: languages[index],
                  selected: index == selectedLanguageDesignScreen,
                  onPressed: () {
                    setState(() => selectedLanguageDesignScreen = index);
                  },
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 230,
          child: AppButton(label: 'Continue', onPressed: () {}),
        ),
      ],
    );
  }
}

class _DashboardPreview extends StatelessWidget {
  const _DashboardPreview({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 76,
          child: Row(
            children: definition.primaryItems.take(3).map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 9),
                  child: _MetricCard(label: item),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        _InsightStrip(
          icon: Icons.auto_graph_rounded,
          title: definition.secondaryItems.isEmpty
              ? 'Current status'
              : definition.secondaryItems.first,
          text:
              'A clear signal with supporting context and a visible next step.',
        ),
        const Spacer(),
        _ActionRow(actions: definition.actions),
      ],
    );
  }
}

class _FormPreview extends StatelessWidget {
  const _FormPreview({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    final fields = [
      ...definition.primaryItems,
      ...definition.secondaryItems,
    ].take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 54,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: fields.length,
            itemBuilder: (context, index) =>
                _FixtureField(label: fields[index], index: index),
          ),
        ),
        _ActionRow(actions: definition.actions),
      ],
    );
  }
}

class _ListPreview extends StatelessWidget {
  const _ListPreview({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 138,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: Color(0xFF6390AC),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Search',
                    style: TextStyle(color: Color(0xFF7893A5), fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        ...definition.primaryItems
            .take(3)
            .toList()
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ListTileCard(
                  title: entry.value,
                  detail: definition.secondaryItems.isEmpty
                      ? 'Updated recently'
                      : definition.secondaryItems[entry.key %
                            definition.secondaryItems.length],
                  icon: definition.icon,
                ),
              ),
            ),
        const Spacer(),
        _ActionRow(actions: definition.actions),
      ],
    );
  }
}

class _DetailPreview extends StatelessWidget {
  const _DetailPreview({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    final items = [
      ...definition.primaryItems,
      ...definition.secondaryItems,
    ].take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        definition.icon,
                        color: const Color(0xFF2E97D3),
                        size: 28,
                      ),
                      const Spacer(),
                      Text(
                        definition.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF244F6B),
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  children: items.skip(1).take(4).map((item) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: _CompactInfoRow(label: item),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ActionRow(actions: definition.actions),
      ],
    );
  }
}

class _ConversationPreview extends StatelessWidget {
  const _ConversationPreview({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _SpeechBubble(
                text: definition.primaryItems.first,
                incoming: true,
              ),
              const SizedBox(height: 8),
              _SpeechBubble(
                text: definition.primaryItems.length > 1
                    ? definition.primaryItems[1]
                    : 'Your response appears here.',
                incoming: false,
              ),
              const Spacer(),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FC),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mic_none_rounded,
                      color: Color(0xFF399CD4),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        definition.secondaryItems.isEmpty
                            ? 'Type or speak your response'
                            : definition.secondaryItems.first,
                        style: const TextStyle(
                          color: Color(0xFF6E8B9E),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xFF399CD4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ActionRow(actions: definition.actions),
      ],
    );
  }
}

class _CanvasPreview extends StatelessWidget {
  const _CanvasPreview({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: definition.primaryItems
                  .take(4)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _ToolChip(label: item),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 11),
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FD),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFB9DFF6), width: 2),
            ),
            child: CustomPaint(
              painter: _BlueprintPainter(),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Color(0x245A91BA), blurRadius: 16),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(definition.icon, color: const Color(0xFF3298D2)),
                      const SizedBox(width: 8),
                      Text(
                        definition.primaryItems.first,
                        style: const TextStyle(
                          color: Color(0xFF2A5874),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ActionRow(actions: definition.actions),
      ],
    );
  }
}

class _GamePreview extends StatelessWidget {
  const _GamePreview({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const _ScorePill(label: 'SCORE', value: '08,420'),
            const SizedBox(width: 8),
            const _ScorePill(label: 'TIME', value: '00:42'),
          ],
        ),
        const SizedBox(height: 11),
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD9F3FF), Color(0xFFE6E5FF)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFAEDAF3), width: 2),
                ),
              ),
              const Positioned(left: 18, bottom: 15, child: _JoystickFixture()),
              Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6BBCE7),
                      width: 4,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x304E8FBB), blurRadius: 16),
                    ],
                  ),
                  child: Icon(
                    definition.icon,
                    size: 38,
                    color: const Color(0xFF468FD0),
                  ),
                ),
              ),
              Positioned(
                right: 18,
                bottom: 15,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF57C6EF), Color(0xFF8A8EF3)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ActionRow(actions: definition.actions),
      ],
    );
  }
}

class _SettingsPreview extends StatelessWidget {
  const _SettingsPreview({required this.definition});

  final DesignScreenDefinition definition;

  @override
  Widget build(BuildContext context) {
    final items = [
      ...definition.primaryItems,
      ...definition.secondaryItems,
    ].take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 56,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    index.isEven
                        ? Icons.toggle_on_rounded
                        : Icons.chevron_right_rounded,
                    color: const Color(0xFF49A5DA),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(
                        color: Color(0xFF315A74),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _ActionRow(actions: definition.actions),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFC9E5F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF53768D),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Row(
            children: [
              Text(
                'Ready',
                style: TextStyle(
                  color: Color(0xFF214E6A),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Icon(
                Icons.north_east_rounded,
                color: Color(0xFF48A8DA),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightStrip extends StatelessWidget {
  const _InsightStrip({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F4FF), Color(0xFFEAEAFF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF478FD0), size: 23),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF315E79),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF708C9E), fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FixtureField extends StatelessWidget {
  const _FixtureField({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8FC),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFD0E7F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF7A96A8),
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            index.isEven ? 'Sample value' : 'Choose an option',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF345E77),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTileCard extends StatelessWidget {
  const _ListTileCard({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 51,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDDF2FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: const Color(0xFF3D9BD1), size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2C5670),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF7893A4), fontSize: 8),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF72A3C1),
            size: 19,
          ),
        ],
      ),
    );
  }
}

class _CompactInfoRow extends StatelessWidget {
  const _CompactInfoRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Color(0xFF5DB3E0), size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF426A82),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, required this.incoming});

  final String text;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: incoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: incoming ? const Color(0xFFE8F4FC) : const Color(0xFF77BDE7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(incoming ? 4 : 15),
            bottomRight: Radius.circular(incoming ? 15 : 4),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: incoming ? const Color(0xFF345E77) : Colors.white,
            fontSize: 10,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F4FC),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4A7894),
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F5FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF78A0B8),
              fontSize: 6,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2F6280),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _JoystickFixture extends StatelessWidget {
  const _JoystickFixture();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF87C7E8), width: 2),
      ),
      child: Center(
        child: Container(
          width: 27,
          height: 27,
          decoration: const BoxDecoration(
            color: Color(0xFF65AFDD),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.actions});

  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    final visibleActions = (actions.isEmpty ? ['Continue'] : actions.take(2))
        .toList();
    if (visibleActions.length == 1) {
      return Align(
        alignment: Alignment.centerRight,
        child: _GradientOutlineAction(label: visibleActions.first),
      );
    }
    return Row(
      children: visibleActions.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: entry.key == 0 ? 0 : 8),
            child: _GradientOutlineAction(label: entry.value),
          ),
        );
      }).toList(),
    );
  }
}

class _GradientOutlineAction extends StatelessWidget {
  const _GradientOutlineAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppButton(label: label, onPressed: () {});
  }
}

class _BlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFCAE6F5)
      ..strokeWidth = 1;
    for (double x = 16; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 16; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final objectPaint = Paint()
      ..color = const Color(0xFF8BC9E9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(28, 24, 92, 56),
        const Radius.circular(10),
      ),
      objectPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 134, size.height - 78, 104, 48),
        const Radius.circular(10),
      ),
      objectPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
