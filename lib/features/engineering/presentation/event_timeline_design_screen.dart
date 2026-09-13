import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'first_launch_hero_panel.dart';

class EventTimelineDesignScreen extends StatefulWidget {
  const EventTimelineDesignScreen({super.key});

  @override
  State<EventTimelineDesignScreen> createState() =>
      _EventTimelineDesignScreenState();
}

class _EventTimelineDesignScreenState extends State<EventTimelineDesignScreen> {
  int selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final visibleEvents = selectedFilter == 0
        ? timelineEventsDesignScreen
        : timelineEventsDesignScreen
              .where((event) => event.people.contains('You'))
              .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: FirstLaunchHeroPanel(
                  onBack: () => context.go('/design/home'),
                  child: const _TimelineSummary(),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Event Timeline',
                                style: TextStyle(
                                  color: Color(0xFF173F5D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Review observable workplace events in chronological order',
                                style: TextStyle(
                                  color: Color(0xFF5E8196),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _TimelineFilter(
                          label: 'All Events',
                          selected: selectedFilter == 0,
                          onTap: () => setState(() => selectedFilter = 0),
                        ),
                        const SizedBox(width: 6),
                        _TimelineFilter(
                          label: 'Involving You',
                          selected: selectedFilter == 1,
                          onTap: () => setState(() => selectedFilter = 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Expanded(
                      child: ListView.builder(
                        key: const ValueKey('event-timeline-list'),
                        padding: const EdgeInsets.only(right: 4),
                        itemCount: visibleEvents.length,
                        itemBuilder: (context, index) {
                          final event = visibleEvents[index];
                          return _TimelineEventCard(
                            event: event,
                            last: index == visibleEvents.length - 1,
                            onTap: () => context.go(
                              '/design/event-editor?mode=inspect&id=${event.id}',
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 155,
                        child: FirstLaunchBottomAction(
                          child: AppButton(
                            label: 'Add Event',
                            leading: const Icon(Icons.add_rounded),
                            onPressed: () =>
                                context.go('/design/event-editor?mode=create'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineSummary extends StatelessWidget {
  const _TimelineSummary();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        Icon(Icons.timeline_rounded, color: Color(0xFF3299D0), size: 55),
        SizedBox(height: 8),
        Text(
          'Your office story,\nin order',
          style: TextStyle(
            color: Color(0xFF174765),
            fontSize: 24,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Events connect people, evidence, feelings, and later outcomes. Record what happened before asking the politics consultant to interpret patterns.',
          style: TextStyle(
            color: Color(0xFF56819A),
            fontSize: 9,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10),
        _TimelineStat(label: 'Recorded Events', value: '8'),
        _TimelineStat(label: 'This Month', value: '5'),
        _TimelineStat(label: 'Need Follow-up', value: '2'),
      ],
    );
  }
}

class _TimelineStat extends StatelessWidget {
  const _TimelineStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4E7890),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF725ED2),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineFilter extends StatelessWidget {
  const _TimelineFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFDDF5FF) : Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? const Color(0xFF806DE2)
                  : const Color(0xFF9EDCF5),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF356A84),
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  const _TimelineEventCard({
    required this.event,
    required this.last,
    required this.onTap,
  });

  final _TimelineEvent event;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 35,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: event.color.withValues(alpha: 0.35),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFB7DFF1)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF9EDCF5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F4FF),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Column(
                            children: [
                              Text(
                                event.day,
                                style: const TextStyle(
                                  color: Color(0xFF245672),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                event.monthTime,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF56819A),
                                  fontSize: 6.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  color: Color(0xFF245672),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                event.people,
                                style: const TextStyle(
                                  color: Color(0xFF318DB6),
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                event.summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF56798B),
                                  fontSize: 7.5,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF806DE2),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.id,
    required this.day,
    required this.monthTime,
    required this.title,
    required this.people,
    required this.summary,
    required this.color,
  });

  final String id;
  final String day;
  final String monthTime;
  final String title;
  final String people;
  final String summary;
  final Color color;
}

const timelineEventsDesignScreen = [
  _TimelineEvent(
    id: 'deadline-escalation',
    day: '12',
    monthTime: 'SEP\n3:30 PM',
    title: 'Deadline Ownership Escalation',
    people: 'You · Alex · Director Lee',
    summary:
        'Alex disputed ownership of the missed deadline and copied the director.',
    color: Color(0xFF806DE2),
  ),
  _TimelineEvent(
    id: 'planning-support',
    day: '08',
    monthTime: 'SEP\n10:00 AM',
    title: 'Planning Review Support',
    people: 'You · Maya',
    summary:
        'Maya supported the revised delivery sequence using operational evidence.',
    color: Color(0xFF3299D0),
  ),
  _TimelineEvent(
    id: 'budget-review',
    day: '06',
    monthTime: 'SEP\n2:15 PM',
    title: 'Budget Evidence Requested',
    people: 'You · Jordan',
    summary:
        'Jordan requested stronger evidence for the projected financial benefit.',
    color: Color(0xFF5FC5B1),
  ),
  _TimelineEvent(
    id: 'cost-negotiation',
    day: '29',
    monthTime: 'AUG\n4:00 PM',
    title: 'Cost Target Negotiation',
    people: 'Maya · Jordan',
    summary:
        'Operations and Finance negotiated the latest cost-reduction target.',
    color: Color(0xFF65A9D6),
  ),
];
