import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/statistics.dart';
import '../../theme.dart';

/// Courbe annuelle avec grille, graduation et années repères.
///
/// Contrairement à une vignette, elle donne l'échelle : sans elle, une courbe
/// qui monte de 2 % ressemble à une explosion démographique.
class YearLineChart extends StatelessWidget {
  const YearLineChart({
    required this.points,
    this.height = 150,
    this.unit = '',
    this.color = IvoireColors.green,
    this.decimals = 0,
    super.key,
  });

  final List<StatisticPoint> points;
  final double height;
  final String unit;
  final Color color;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _YearChartPainter(
          points: points,
          color: color,
          unit: unit,
          decimals: decimals,
        ),
      ),
    );
  }
}

class _YearChartPainter extends CustomPainter {
  _YearChartPainter({
    required this.points,
    required this.color,
    required this.unit,
    required this.decimals,
  });

  final List<StatisticPoint> points;
  final Color color;
  final String unit;
  final int decimals;

  static const double _left = 58;
  static const double _bottom = 18;
  static const double _top = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final values = points.map((point) => point.value).toList(growable: false);
    var min = values.reduce(math.min);
    var max = values.reduce(math.max);

    if (max == min) {
      max = min + 1;
    }

    // Une marge de 8 % évite que la courbe touche les bords.
    final span = max - min;
    final low = min - span * 0.08;
    final high = max + span * 0.08;

    final chart = Rect.fromLTRB(_left, _top, size.width - 4, size.height - _bottom);

    double yFor(double value) =>
        chart.bottom - (value - low) / (high - low) * chart.height;

    double xFor(int index) =>
        chart.left + chart.width * (index / (points.length - 1));

    // Grille et graduations : quatre niveaux, valeurs arrondies vers le bas.
    final gridPaint = Paint()
      ..color = IvoireColors.lineSoft
      ..strokeWidth = 1;

    // Une seule unité pour toute l'échelle : mélanger « 996,8 M » et « 36,4 Md »
    // sur le même axe rend la lecture fausse.
    final magnitude = math.max(high.abs(), low.abs());
    final unit = magnitude >= 1e9
        ? (factor: 1e9, suffix: ' Md', decimals: 1)
        : magnitude >= 1e6
            ? (factor: 1e6, suffix: ' M', decimals: 1)
            : magnitude >= 1e4
                ? (factor: 1e3, suffix: ' k', decimals: 0)
                : (factor: 1.0, suffix: '', decimals: decimals);

    for (var step = 0; step <= 3; step++) {
      final value = low + (high - low) * step / 3;
      final y = yFor(value);

      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      _text(
        canvas,
        '${(value / unit.factor).toStringAsFixed(unit.decimals).replaceAll('.', ',')}${unit.suffix}',
        Offset(chart.left - 8, y),
        align: _Align.rightCenter,
        color: IvoireColors.faint,
        size: 9.5,
      );
    }

    // Axe des années : début, milieu, fin — jamais plus, pour rester lisible.
    final first = points.first.year;
    final middle = points[points.length ~/ 2].year;
    final last = points.last.year;

    _text(canvas, '$first', Offset(chart.left, chart.bottom + 3), size: 9.5);
    _text(
      canvas,
      '$middle',
      Offset(chart.center.dx, chart.bottom + 3),
      align: _Align.center,
      size: 9.5,
    );
    _text(
      canvas,
      '$last',
      Offset(chart.right, chart.bottom + 3),
      align: _Align.right,
      size: 9.5,
    );

    // Aire + courbe.
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final point = Offset(xFor(index), yFor(values[index]));
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final fill = Path.from(path)
      ..lineTo(chart.right, chart.bottom)
      ..lineTo(chart.left, chart.bottom)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.20),
            color.withValues(alpha: 0.01),
          ],
        ).createShader(chart),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );

    // Dernier point : la valeur courante, mise en évidence.
    final lastPoint = Offset(xFor(points.length - 1), yFor(values.last));
    canvas.drawCircle(lastPoint, 3.2, Paint()..color = Colors.white);
    canvas.drawCircle(
      lastPoint,
      3.2,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(_YearChartPainter old) =>
      old.points != points || old.color != color;
}

/// Pluviométrie d'une ville : barres mensuelles et courbe de température.
///
/// Le régime des pluies ne se lit pas sur une moyenne annuelle : deux villes à
/// 1 400 mm n'ont pas la même saison. Les barres montrent les mois, la ligne
/// orange la température moyenne de chaque mois.
class MonthlyRainChart extends StatelessWidget {
  const MonthlyRainChart({
    required this.months,
    this.height = 190,
    super.key,
  });

  final List<ClimateMonth> months;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _MonthlyRainPainter(months: months)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _Legend(color: IvoireColors.green, label: 'Pluie (mm)'),
            const SizedBox(width: 16),
            _Legend(color: IvoireColors.orange, label: 'Température (°C)', line: true),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, this.line = false});

  final Color color;
  final String label;
  final bool line;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: line ? 14 : 9,
          height: line ? 2 : 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: IvoireColors.faint),
        ),
      ],
    );
  }
}

class _MonthlyRainPainter extends CustomPainter {
  _MonthlyRainPainter({required this.months});

  final List<ClimateMonth> months;

  static const double _left = 34;
  static const double _bottom = 16;
  static const double _top = 8;

  static const List<String> _initials = [
    'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(_left, _top, size.width - 24, size.height - _bottom);
    final maxRain = months.map((month) => month.rainMm).reduce(math.max);
    final niceMax = (maxRain / 100).ceil() * 100.0;

    // Grille (pluie).
    final grid = Paint()
      ..color = IvoireColors.lineSoft
      ..strokeWidth = 1;

    for (var step = 0; step <= 2; step++) {
      final value = niceMax * step / 2;
      final y = chart.bottom - chart.height * (value / niceMax);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      _text(
        canvas,
        '${value.round()}',
        Offset(chart.left - 6, y),
        align: _Align.rightCenter,
        size: 9,
      );
    }

    final slot = chart.width / months.length;
    final barWidth = slot * 0.52;

    for (var index = 0; index < months.length; index++) {
      final month = months[index];
      final heightRatio = month.rainMm / niceMax;
      final barHeight = chart.height * heightRatio;
      final x = chart.left + slot * index + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, chart.bottom - barHeight, barWidth, barHeight),
        topLeft: const Radius.circular(2.5),
        topRight: const Radius.circular(2.5),
      );

      final isWettest = month.rainMm == maxRain;
      canvas.drawRRect(
        rect,
        Paint()..color = isWettest ? IvoireColors.green : IvoireColors.green.withValues(alpha: 0.55),
      );

      _text(
        canvas,
        _initials[month.month - 1],
        Offset(chart.left + slot * index + slot / 2, chart.bottom + 2),
        align: _Align.center,
        size: 9.5,
      );

      // Étiqette du mois le plus arrosé : le repère utile de la saison.
      if (isWettest) {
        _text(
          canvas,
          '${month.rainMm.round()} mm',
          Offset(chart.left + slot * index + slot / 2, chart.bottom - barHeight - 4),
          align: _Align.center,
          size: 9.5,
          color: IvoireColors.greenDeep,
          bold: true,
        );
      }
    }

    // Température : échelle propre à droite (min/max du mois), ligne orange.
    final temps = months
        .map((month) => month.temperatureC)
        .whereType<double>()
        .toList(growable: false);

    if (temps.length > 1) {
      final minTemp = temps.reduce(math.min);
      final maxTemp = temps.reduce(math.max);
      final tempSpan = math.max(maxTemp - minTemp, 1.0);

      Offset pointFor(int index) {
        final month = months[index];
        final temp = month.temperatureC ?? minTemp;
        final ratio = (temp - minTemp) / tempSpan;
        final y = chart.bottom - chart.height * (0.12 + ratio * 0.5);
        return Offset(chart.left + slot * index + slot / 2, y);
      }

      final path = Path();
      for (var index = 0; index < months.length; index++) {
        final point = pointFor(index);
        if (index == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = IvoireColors.orange.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round,
      );

      for (var index = 0; index < months.length; index++) {
        canvas.drawCircle(pointFor(index), 1.8, Paint()..color = IvoireColors.orange);
      }
    }
  }

  @override
  bool shouldRepaint(_MonthlyRainPainter old) => old.months != months;
}

enum _Align { left, center, right, rightCenter }

void _text(
  Canvas canvas,
  String value,
  Offset anchor, {
  _Align align = _Align.left,
  double size = 10,
  Color color = IvoireColors.faint,
  bool bold = false,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: value,
      style: TextStyle(
        fontFamily: kFont,
        fontSize: size,
        color: color,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final offset = switch (align) {
    _Align.left => anchor,
    _Align.center => anchor - Offset(painter.width / 2, 0),
    _Align.right => anchor - Offset(painter.width, 0),
    _Align.rightCenter => anchor - Offset(painter.width, painter.height / 2),
  };

  painter.paint(canvas, offset);
}
