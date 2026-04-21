import 'dart:math';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../theme/weather_theme.dart';

class WeatherIllustration extends StatefulWidget {
  final WeatherCondition condition;
  final WeatherTheme theme;

  const WeatherIllustration({
    super.key,
    required this.condition,
    required this.theme,
  });

  @override
  State<WeatherIllustration> createState() => _WeatherIllustrationState();
}

class _WeatherIllustrationState extends State<WeatherIllustration>
    with TickerProviderStateMixin {
  late AnimationController _sunController;
  late AnimationController _cloudController;
  late AnimationController _rainController;
  late AnimationController _lightningController;
  late AnimationController _snowController;
  late Animation<double> _sunPulse;
  late Animation<double> _cloudFloat;
  late Animation<double> _rainDrop;
  late Animation<double> _lightning;
  late Animation<double> _snowFall;

  @override
  void initState() {
    super.initState();

    _sunController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _sunPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _sunController, curve: Curves.easeInOut),
    );

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _cloudFloat = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut),
    );

    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    _rainDrop = Tween<double>(begin: 0, end: 1).animate(_rainController);

    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _lightning = Tween<double>(begin: 0, end: 1).animate(_lightningController);
    _scheduleLightning();

    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _snowFall = Tween<double>(begin: 0, end: 1).animate(_snowController);
  }

  void _scheduleLightning() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 2 + Random().nextInt(4)));
      if (mounted &&
          widget.condition == WeatherCondition.thunderstorm) {
        await _lightningController.forward();
        await _lightningController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _sunController.dispose();
    _cloudController.dispose();
    _rainController.dispose();
    _lightningController.dispose();
    _snowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _WeatherPainter(
          condition: widget.condition,
          theme: widget.theme,
          sunScale: _sunPulse,
          cloudOffset: _cloudFloat,
          rainProgress: _rainDrop,
          lightningOpacity: _lightning,
          snowProgress: _snowFall,
        ),
        size: Size(MediaQuery.of(context).size.width, 220),
      ),
    );
  }
}

class _WeatherPainter extends CustomPainter {
  final WeatherCondition condition;
  final WeatherTheme theme;
  final Animation<double> sunScale;
  final Animation<double> cloudOffset;
  final Animation<double> rainProgress;
  final Animation<double> lightningOpacity;
  final Animation<double> snowProgress;

  _WeatherPainter({
    required this.condition,
    required this.theme,
    required this.sunScale,
    required this.cloudOffset,
    required this.rainProgress,
    required this.lightningOpacity,
    required this.snowProgress,
  }) : super(
            repaint: Listenable.merge([
          sunScale,
          cloudOffset,
          rainProgress,
          lightningOpacity,
          snowProgress,
        ]));

  @override
  void paint(Canvas canvas, Size size) {
    switch (condition) {
      case WeatherCondition.clear:
        _drawSunny(canvas, size);
        break;
      case WeatherCondition.cloudy:
        _drawSunny(canvas, size);
        _drawClouds(canvas, size, opacity: 0.9);
        break;
      case WeatherCondition.overcast:
        _drawClouds(canvas, size, opacity: 1.0, dense: true);
        break;
      case WeatherCondition.rain:
        _drawClouds(canvas, size, opacity: 1.0, dense: true);
        _drawRain(canvas, size);
        break;
      case WeatherCondition.thunderstorm:
        _drawClouds(canvas, size, opacity: 1.0, dense: true, dark: true);
        _drawRain(canvas, size, heavy: true);
        _drawLightning(canvas, size);
        break;
      case WeatherCondition.snow:
        _drawClouds(canvas, size, opacity: 0.8, light: true);
        _drawSnow(canvas, size);
        break;
      case WeatherCondition.foggy:
        _drawFog(canvas, size);
        break;
    }
  }

  void _drawSunny(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.45;
    final scale = sunScale.value;

    // Outer glow
    final glowPaint = Paint()
      ..color = theme.primaryColor.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(cx, cy), 65 * scale, glowPaint);

    // Sun rays
    final rayPaint = Paint()
      ..color = theme.secondaryColor.withOpacity(0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final inner = 48 * scale;
      final outer = 62 * scale;
      canvas.drawLine(
        Offset(cx + cos(angle) * inner, cy + sin(angle) * inner),
        Offset(cx + cos(angle) * outer, cy + sin(angle) * outer),
        rayPaint,
      );
    }

    // Sun body
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [theme.secondaryColor, theme.primaryColor],
      ).createShader(Rect.fromCircle(
          center: Offset(cx, cy), radius: 45 * scale));
    canvas.drawCircle(Offset(cx, cy), 45 * scale, sunPaint);
  }

  void _drawClouds(Canvas canvas, Size size,
      {double opacity = 1.0,
      bool dense = false,
      bool dark = false,
      bool light = false}) {
    final offset = cloudOffset.value;
    final baseColor = dark
        ? const Color(0xFF37474F)
        : light
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFB0BEC5);

    _drawCloud(canvas, size.width * 0.35 + offset, size.height * 0.4, 80, 40,
        baseColor.withOpacity(opacity));
    if (dense) {
      _drawCloud(canvas, size.width * 0.65 - offset * 0.7,
          size.height * 0.3, 90, 45, baseColor.withOpacity(opacity * 0.9));
      _drawCloud(canvas, size.width * 0.2 + offset * 0.5, size.height * 0.55,
          70, 35, baseColor.withOpacity(opacity * 0.8));
    } else {
      _drawCloud(canvas, size.width * 0.7 - offset * 0.5, size.height * 0.3,
          60, 30, baseColor.withOpacity(opacity * 0.75));
    }
  }

  void _drawCloud(Canvas canvas, double cx, double cy, double w, double h,
      Color color) {
    final paint = Paint()..color = color;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
      Radius.circular(h / 2),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawCircle(Offset(cx - w * 0.22, cy - h * 0.1), h * 0.6, paint);
    canvas.drawCircle(Offset(cx + w * 0.1, cy - h * 0.25), h * 0.7, paint);
  }

  void _drawRain(Canvas canvas, Size size, {bool heavy = false}) {
    final progress = rainProgress.value;
    final count = heavy ? 30 : 18;
    final paint = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(0.7)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final rng = Random(42);
    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final y = ((baseY + progress * size.height * 1.2) % (size.height * 1.2)) -
          size.height * 0.1;
      canvas.drawLine(
        Offset(x - 3, y - 8),
        Offset(x + 3, y + 8),
        paint,
      );
    }
  }

  void _drawLightning(Canvas canvas, Size size) {
    final opacity = lightningOpacity.value;
    if (opacity < 0.01) return;

    final flashPaint = Paint()
      ..color = Colors.yellow.withOpacity(opacity * 0.3);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);

    final boltPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(opacity)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.55, size.height * 0.15);
    path.lineTo(size.width * 0.45, size.height * 0.5);
    path.lineTo(size.width * 0.52, size.height * 0.5);
    path.lineTo(size.width * 0.42, size.height * 0.85);
    canvas.drawPath(path, boltPaint);
  }

  void _drawSnow(Canvas canvas, Size size) {
    final progress = snowProgress.value;
    final paint = Paint()..color = Colors.white.withOpacity(0.85);
    final rng = Random(99);
    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final y = ((baseY + progress * size.height) % size.height);
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 3 + 2, paint);
    }
  }

  void _drawFog(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0BEC5).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.2 + i * 0.22) + cloudOffset.value * (i % 2 == 0 ? 1 : -1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-20, y, size.width + 40, 28),
          const Radius.circular(14),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WeatherPainter oldDelegate) => true;
}