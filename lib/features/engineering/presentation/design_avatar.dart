import 'dart:math';

import 'package:flutter/material.dart';

@immutable
class DesignAvatarData {
  const DesignAvatarData({
    required this.skinColor,
    required this.hairColor,
    required this.outfitColor,
    this.face = 0,
    this.hair = 0,
    this.eyes = 0,
    this.mouth = 0,
    this.accessory = 0,
  });

  final Color skinColor;
  final Color hairColor;
  final Color outfitColor;
  final int face;
  final int hair;
  final int eyes;
  final int mouth;
  final int accessory;
}

abstract final class DesignAvatarDraft {
  static DesignAvatarData self = const DesignAvatarData(
    skinColor: Color(0xFFFFD9BE),
    hairColor: Color(0xFF263D4D),
    outfitColor: Color(0xFF3299D0),
  );

  static DesignAvatarData firstColleague = const DesignAvatarData(
    skinColor: Color(0xFFFBD0AF),
    hairColor: Color(0xFF342B2B),
    outfitColor: Color(0xFFDD7D67),
    face: 1,
    hair: 2,
    eyes: 1,
    mouth: 1,
    accessory: 1,
  );
}

class DesignAvatarPainter extends CustomPainter {
  const DesignAvatarPainter(
    this.avatar, {
    this.showBackdrop = true,
    this.showBody = true,
  });

  final DesignAvatarData avatar;
  final bool showBackdrop;
  final bool showBody;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 200;
    final horizontalInset = (size.width / scale - 200) / 2;
    canvas
      ..save()
      ..scale(scale)
      ..translate(horizontalInset, 0);

    if (showBackdrop) {
      canvas.drawCircle(
        const Offset(100, 105),
        88,
        Paint()..color = const Color(0xFFE5F6FF),
      );
    }
    if (showBody) {
      canvas.drawOval(
        const Rect.fromLTWH(45, 154, 110, 35),
        Paint()..color = avatar.outfitColor,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(86, 128, 28, 35),
          const Radius.circular(9),
        ),
        Paint()..color = avatar.skinColor,
      );
    }

    final hairPaint = Paint()..color = avatar.hairColor;
    if (avatar.hair == 5 || avatar.hair == 16) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(50, 29, 100, 132),
          const Radius.circular(43),
        ),
        hairPaint,
      );
    } else if (avatar.hair == 10 || avatar.hair == 13) {
      final strands = Paint()
        ..color = hairPaint.color
        ..strokeWidth = avatar.hair == 10 ? 9 : 7
        ..strokeCap = StrokeCap.round;
      for (var index = 0; index < 4; index++) {
        canvas.drawLine(
          Offset(62 + index * 5, 71),
          Offset(54 + index * 5, 151 - index * 4),
          strands,
        );
        canvas.drawLine(
          Offset(138 - index * 5, 71),
          Offset(146 - index * 5, 151 - index * 4),
          strands,
        );
      }
    } else if (avatar.hair == 11) {
      canvas.drawCircle(const Offset(100, 27), 24, hairPaint);
    } else if (avatar.hair == 12) {
      canvas.drawOval(const Rect.fromLTWH(128, 48, 48, 105), hairPaint);
    }

    final faceVariant = avatar.face % 5;
    final faceRect = switch (faceVariant) {
      1 => const Rect.fromLTWH(61, 39, 78, 105),
      2 => const Rect.fromLTWH(58, 43, 84, 96),
      3 => const Rect.fromLTWH(60, 40, 80, 101),
      4 => const Rect.fromLTWH(56, 45, 88, 93),
      _ => const Rect.fromLTWH(58, 42, 84, 96),
    };
    final radius = faceVariant == 2
        ? 23.0
        : faceVariant == 3
        ? 34.0
        : 42.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(radius)),
      Paint()..color = avatar.skinColor,
    );

    if (avatar.hair != 19) {
      final hairPath = Path()
        ..moveTo(60, 78)
        ..quadraticBezierTo(58, 34, 101, 31)
        ..quadraticBezierTo(143, 35, 140, 79)
        ..quadraticBezierTo(
          118,
          61 - (avatar.hair % 5) * 3,
          60,
          78 + (avatar.hair % 5) * 2,
        )
        ..close();
      canvas.drawPath(hairPath, hairPaint);
    }
    if (avatar.hair == 17) {
      final bangs = Paint()
        ..color = hairPaint.color
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round;
      for (var index = 0; index < 5; index++) {
        canvas.drawLine(
          Offset(76 + index * 12, 55),
          Offset(73 + index * 12, 78 + (index.isEven ? 5 : 0)),
          bangs,
        );
      }
    }

    final eyePaint = Paint()
      ..color = const Color(0xFF27485A)
      ..strokeWidth = avatar.eyes % 3 == 1 ? 4 : 3
      ..strokeCap = StrokeCap.round;
    if (avatar.eyes % 3 == 2) {
      canvas.drawArc(
        const Rect.fromLTWH(75, 85, 16, 10),
        0,
        pi,
        false,
        eyePaint..style = PaintingStyle.stroke,
      );
      canvas.drawArc(
        const Rect.fromLTWH(109, 85, 16, 10),
        0,
        pi,
        false,
        eyePaint,
      );
    } else {
      canvas.drawCircle(const Offset(83, 91), 3.5, eyePaint);
      canvas.drawCircle(const Offset(117, 91), 3.5, eyePaint);
    }

    final mouthPaint = Paint()
      ..color = const Color(0xFFB65E67)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    if (avatar.mouth % 3 == 1) {
      canvas.drawLine(
        const Offset(92, 119),
        const Offset(108, 119),
        mouthPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromLTWH(89, avatar.mouth % 3 == 2 ? 108 : 111, 22, 16),
        0.15,
        pi - 0.3,
        false,
        mouthPaint,
      );
    }

    final accessoryVariant = avatar.accessory % 4;
    if (accessoryVariant == 1) {
      final glasses = Paint()
        ..color = const Color(0xFF4A7790)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(const Offset(83, 92), 10, glasses);
      canvas.drawCircle(const Offset(117, 92), 10, glasses);
      canvas.drawLine(const Offset(93, 92), const Offset(107, 92), glasses);
    } else if (accessoryVariant == 2) {
      final headset = Paint()
        ..color = const Color(0xFF6657B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawArc(
        const Rect.fromLTWH(54, 47, 92, 92),
        pi,
        pi,
        false,
        headset,
      );
      canvas.drawCircle(
        const Offset(143, 105),
        7,
        headset..style = PaintingStyle.fill,
      );
    } else if (accessoryVariant == 3) {
      canvas.drawCircle(
        const Offset(133, 65),
        7,
        Paint()..color = const Color(0xFFA184F0),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DesignAvatarPainter oldDelegate) =>
      avatar != oldDelegate.avatar ||
      showBackdrop != oldDelegate.showBackdrop ||
      showBody != oldDelegate.showBody;
}

class DesignAvatarHeadPainter extends CustomPainter {
  const DesignAvatarHeadPainter(this.avatar);

  final DesignAvatarData avatar;

  @override
  void paint(Canvas canvas, Size size) {
    const source = Rect.fromLTWH(45, 20, 110, 145);
    final scale = min(size.width / source.width, size.height / source.height);
    final renderedSize = Size(source.width * scale, source.height * scale);
    final offset = Offset(
      (size.width - renderedSize.width) / 2,
      (size.height - renderedSize.height) / 2,
    );
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..translate(offset.dx, offset.dy)
      ..scale(scale)
      ..translate(-source.left, -source.top);
    DesignAvatarPainter(
      avatar,
      showBackdrop: false,
      showBody: false,
    ).paint(canvas, const Size(200, 200));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DesignAvatarHeadPainter oldDelegate) =>
      avatar != oldDelegate.avatar;
}
