import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'design_back_button.dart';

class OfficeMapEditorDesignScreen extends StatefulWidget {
  const OfficeMapEditorDesignScreen({super.key});

  @override
  State<OfficeMapEditorDesignScreen> createState() =>
      _OfficeMapEditorDesignScreenState();
}

class _OfficeMapEditorDesignScreenState
    extends State<OfficeMapEditorDesignScreen> {
  final GlobalKey canvasKeyDesignScreen = GlobalKey();
  int nextItemIdDesignScreen = 8;
  int? selectedItemIdDesignScreen = 1;

  List<_OfficeBuilderItem> itemsDesignScreen = const [
    _OfficeBuilderItem(1, _BuilderKind.desk, Offset(0.23, 0.23)),
    _OfficeBuilderItem(2, _BuilderKind.chair, Offset(0.29, 0.29)),
    _OfficeBuilderItem(3, _BuilderKind.partition, Offset(0.53, 0.23)),
    _OfficeBuilderItem(4, _BuilderKind.desk, Offset(0.67, 0.61)),
    _OfficeBuilderItem(5, _BuilderKind.chair, Offset(0.73, 0.67)),
    _OfficeBuilderItem(6, _BuilderKind.plant, Offset(0.16, 0.73)),
    _OfficeBuilderItem(7, _BuilderKind.person, Offset(0.58, 0.47)),
  ];

  void acceptDropDesignScreen(DragTargetDetails<_DragPayload> details) {
    final box =
        canvasKeyDesignScreen.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.offset + const Offset(18, 18));
    final position = _inverseProjectDesignScreen(local, box.size);

    setState(() {
      if (details.data.itemId == null) {
        final id = nextItemIdDesignScreen++;
        itemsDesignScreen = [
          ...itemsDesignScreen,
          _OfficeBuilderItem(id, details.data.kind, position),
        ];
        selectedItemIdDesignScreen = id;
      } else {
        itemsDesignScreen = [
          for (final item in itemsDesignScreen)
            if (item.id == details.data.itemId)
              item.copyWith(position: position)
            else
              item,
        ];
        selectedItemIdDesignScreen = details.data.itemId;
      }
    });
  }

  Offset _inverseProjectDesignScreen(Offset point, Size size) {
    final difference = (point.dx - size.width * 0.5) / (size.width * 0.40);
    final sum = (point.dy - size.height * 0.08) / (size.height * 0.42);
    return Offset(
      ((sum + difference) / 2).clamp(0.07, 0.93),
      ((sum - difference) / 2).clamp(0.07, 0.93),
    );
  }

  void rotateSelectedDesignScreen() {
    setState(() {
      itemsDesignScreen = [
        for (final item in itemsDesignScreen)
          if (item.id == selectedItemIdDesignScreen)
            item.copyWith(rotation: (item.rotation + 1) % 4)
          else
            item,
      ];
    });
  }

  void deleteSelectedDesignScreen() {
    setState(() {
      itemsDesignScreen = itemsDesignScreen
          .where((item) => item.id != selectedItemIdDesignScreen)
          .toList();
      selectedItemIdDesignScreen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = itemsDesignScreen.cast<_OfficeBuilderItem?>().firstWhere(
      (item) => item?.id == selectedItemIdDesignScreen,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _EditorHeader(onBack: () => context.go('/engineering')),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 154, child: _BuilderPalette()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DragTarget<_DragPayload>(
                        onAcceptWithDetails: acceptDropDesignScreen,
                        builder: (context, candidates, rejected) {
                          return Container(
                            key: canvasKeyDesignScreen,
                            decoration: BoxDecoration(
                              color: candidates.isEmpty
                                  ? const Color(0xFFF5FBFD)
                                  : const Color(0xFFE2F7FB),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: candidates.isEmpty
                                    ? const Color(0xFFAECBD7)
                                    : const Color(0xFF35AFC4),
                                width: candidates.isEmpty ? 2 : 3,
                              ),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Positioned.fill(
                                      child: CustomPaint(
                                        painter: _BuilderFloorPainter(),
                                      ),
                                    ),
                                    for (final item in itemsDesignScreen)
                                      _positionedItemDesignScreen(
                                        item,
                                        constraints.biggest,
                                      ),
                                    if (candidates.isNotEmpty)
                                      const Positioned(
                                        left: 12,
                                        bottom: 10,
                                        child: Text(
                                          'Release to place item',
                                          style: TextStyle(
                                            color: Color(0xFF2788A8),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 166,
                      child: _ItemInspector(
                        item: selected,
                        onRotate: rotateSelectedDesignScreen,
                        onDelete: deleteSelectedDesignScreen,
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

  Widget _positionedItemDesignScreen(_OfficeBuilderItem item, Size size) {
    final point = _projectDesignScreen(item.position, size);
    return Positioned(
      left: point.dx - 21,
      top: point.dy - 24,
      child: Draggable<_DragPayload>(
        data: _DragPayload(item.kind, itemId: item.id),
        feedback: Material(
          color: Colors.transparent,
          child: _BuilderObject(
            kind: item.kind,
            rotation: item.rotation,
            selected: true,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.25,
          child: _BuilderObject(kind: item.kind, rotation: item.rotation),
        ),
        child: GestureDetector(
          onTap: () => setState(() => selectedItemIdDesignScreen = item.id),
          child: _BuilderObject(
            kind: item.kind,
            rotation: item.rotation,
            selected: item.id == selectedItemIdDesignScreen,
          ),
        ),
      ),
    );
  }
}

Offset _projectDesignScreen(Offset point, Size size) {
  return Offset(
    size.width * 0.50 + (point.dx - point.dy) * size.width * 0.40,
    size.height * 0.08 + (point.dx + point.dy) * size.height * 0.42,
  );
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          DesignBackButton(onPressed: onBack),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Isometric Office Builder',
                  style: TextStyle(
                    color: Color(0xFF285366),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Drag items onto the floor. Drag placed items to move them.',
                  style: TextStyle(
                    color: Color(0xFF6B8B99),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Undo',
            onPressed: () {},
            icon: const Icon(Icons.undo_rounded, color: Color(0xFF4089A5)),
          ),
          IconButton(
            tooltip: 'Redo',
            onPressed: () {},
            icon: const Icon(Icons.redo_rounded, color: Color(0xFF4089A5)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 112,
            child: AppButton(label: 'Preview', onPressed: () {}),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 112,
            child: AppButton(label: 'Save Layout', onPressed: () {}),
          ),
        ],
      ),
    );
  }
}

class _BuilderPalette extends StatelessWidget {
  const _BuilderPalette();

  @override
  Widget build(BuildContext context) {
    return _EditorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BUILD ITEMS', style: _editorHeadingStyle),
          const SizedBox(height: 4),
          const Text(
            'Drag into the office',
            style: TextStyle(
              color: Color(0xFF718F9C),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.05,
              children: [
                for (final kind in _BuilderKind.values)
                  LongPressDraggable<_DragPayload>(
                    data: _DragPayload(kind),
                    feedback: Material(
                      color: Colors.transparent,
                      child: _BuilderObject(kind: kind, selected: true),
                    ),
                    child: _PaletteItem(kind: kind),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteItem extends StatelessWidget {
  const _PaletteItem({required this.kind});

  final _BuilderKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F9),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFB9D5DF)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(kind.icon, color: const Color(0xFF328DAE), size: 22),
          const SizedBox(height: 3),
          Text(
            kind.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF426B7D),
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemInspector extends StatelessWidget {
  const _ItemInspector({
    required this.item,
    required this.onRotate,
    required this.onDelete,
  });

  final _OfficeBuilderItem? item;
  final VoidCallback onRotate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _EditorPanel(
      child: item == null
          ? const Center(
              child: Text(
                'Select an item\nto edit it',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF718F9C),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ITEM INSPECTOR', style: _editorHeadingStyle),
                const Spacer(),
                Center(
                  child: _BuilderObject(
                    kind: item!.kind,
                    rotation: item!.rotation,
                    selected: true,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    item!.kind.label,
                    style: const TextStyle(
                      color: Color(0xFF315F73),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Floor position\nX ${item!.position.dx.toStringAsFixed(2)}  ·  Y ${item!.position.dy.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF718F9C),
                    fontSize: 8,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                AppButton(label: 'Rotate', onPressed: onRotate),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Delete Item',
                  destructive: true,
                  onPressed: onDelete,
                ),
              ],
            ),
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFE),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB5D1DC), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x262A5D71),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BuilderObject extends StatelessWidget {
  const _BuilderObject({
    required this.kind,
    this.rotation = 0,
    this.selected = false,
  });

  final _BuilderKind kind;
  final int rotation;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * math.pi / 2,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDDF7FA) : Colors.transparent,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: const Color(0xFF2EABC0), width: 2)
              : null,
        ),
        child: kind == _BuilderKind.partition
            ? const CustomPaint(painter: _PartitionObjectPainter())
            : kind == _BuilderKind.desk
            ? const CustomPaint(painter: _DeskObjectPainter())
            : Icon(kind.icon, color: kind.color, size: 27),
      ),
    );
  }
}

class _BuilderFloorPainter extends CustomPainter {
  const _BuilderFloorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    Offset project(Offset point) => _projectDesignScreen(point, size);
    final floor = Path()
      ..moveTo(project(Offset.zero).dx, project(Offset.zero).dy)
      ..lineTo(project(const Offset(1, 0)).dx, project(const Offset(1, 0)).dy)
      ..lineTo(project(const Offset(1, 1)).dx, project(const Offset(1, 1)).dy)
      ..lineTo(project(const Offset(0, 1)).dx, project(const Offset(0, 1)).dy)
      ..close();
    canvas.drawPath(
      floor.shift(const Offset(0, 9)),
      Paint()..color = const Color(0x30345F70),
    );
    canvas.drawPath(floor, Paint()..color = const Color(0xFFDCECF1));

    final grid = Paint()
      ..color = const Color(0x403BA7BE)
      ..strokeWidth = 1;
    for (var index = 1; index < 10; index++) {
      final value = index / 10;
      canvas
        ..drawLine(project(Offset(value, 0)), project(Offset(value, 1)), grid)
        ..drawLine(project(Offset(0, value)), project(Offset(1, value)), grid);
    }

    _drawWall(canvas, project(Offset.zero), project(const Offset(1, 0)), 18);
    _drawWall(canvas, project(Offset.zero), project(const Offset(0, 1)), 18);
    _drawWall(
      canvas,
      project(const Offset(1, 0)),
      project(const Offset(1, 1)),
      8,
    );
    _drawWall(
      canvas,
      project(const Offset(0, 1)),
      project(const Offset(1, 1)),
      8,
    );
  }

  void _drawWall(Canvas canvas, Offset start, Offset end, double height) {
    final direction = end - start;
    final normal = Offset(-direction.dy, direction.dx) / direction.distance * 5;
    final rise = Offset(0, -height);
    final front = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy)
      ..lineTo((end + rise).dx, (end + rise).dy)
      ..lineTo((start + rise).dx, (start + rise).dy)
      ..close();
    final top = Path()
      ..moveTo((start + rise).dx, (start + rise).dy)
      ..lineTo((end + rise).dx, (end + rise).dy)
      ..lineTo((end + rise + normal).dx, (end + rise + normal).dy)
      ..lineTo((start + rise + normal).dx, (start + rise + normal).dy)
      ..close();
    canvas
      ..drawPath(front, Paint()..color = const Color(0xFF8DB2C0))
      ..drawPath(top, Paint()..color = const Color(0xFFD5E9EF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PartitionObjectPainter extends CustomPainter {
  const _PartitionObjectPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final face = Path()
      ..moveTo(5, 26)
      ..lineTo(36, 34)
      ..lineTo(36, 17)
      ..lineTo(5, 9)
      ..close();
    final top = Path()
      ..moveTo(5, 9)
      ..lineTo(36, 17)
      ..lineTo(39, 14)
      ..lineTo(8, 6)
      ..close();
    canvas
      ..drawPath(face, Paint()..color = const Color(0xFF83AEBE))
      ..drawPath(top, Paint()..color = const Color(0xFFD6EAF0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DeskObjectPainter extends CustomPainter {
  const _DeskObjectPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final top = Path()
      ..moveTo(4, 18)
      ..lineTo(21, 8)
      ..lineTo(38, 18)
      ..lineTo(21, 28)
      ..close();
    final side = Path()
      ..moveTo(4, 18)
      ..lineTo(21, 28)
      ..lineTo(21, 34)
      ..lineTo(4, 24)
      ..close();
    canvas
      ..drawPath(top, Paint()..color = const Color(0xFFB8D4DE))
      ..drawPath(side, Paint()..color = const Color(0xFF769EAD));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _BuilderKind {
  desk('Desk', Icons.desk_rounded, Color(0xFF4C879C)),
  chair('Chair', Icons.event_seat_rounded, Color(0xFF527A9D)),
  partition('Partition', Icons.view_week_rounded, Color(0xFF5599AA)),
  plant('Plant', Icons.local_florist_rounded, Color(0xFF4C9D7D)),
  meetingTable(
    'Meeting table',
    Icons.table_restaurant_rounded,
    Color(0xFF7A83AD),
  ),
  person('Colleague', Icons.person_rounded, Color(0xFFB76D72));

  const _BuilderKind(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

class _OfficeBuilderItem {
  const _OfficeBuilderItem(
    this.id,
    this.kind,
    this.position, {
    this.rotation = 0,
  });

  final int id;
  final _BuilderKind kind;
  final Offset position;
  final int rotation;

  _OfficeBuilderItem copyWith({Offset? position, int? rotation}) {
    return _OfficeBuilderItem(
      id,
      kind,
      position ?? this.position,
      rotation: rotation ?? this.rotation,
    );
  }
}

class _DragPayload {
  const _DragPayload(this.kind, {this.itemId});

  final _BuilderKind kind;
  final int? itemId;
}

const _editorHeadingStyle = TextStyle(
  color: Color(0xFF315F73),
  fontSize: 9,
  fontWeight: FontWeight.w900,
  letterSpacing: 0.4,
);
