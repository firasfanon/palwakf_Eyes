import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class PalEyesVisualV1 {
  static const double maxWidth = 1320;
  static const double radiusLarge = 28;
  static const double radiusMedium = 18;
  static const Color parchment = Color(0xFFF6F0E4);
  static const Color parchmentDeep = Color(0xFFE9DFC9);
  static const Color paper = Color(0xFFFCF9F2);
  static const Color olive = Color(0xFF5E6336);
  static const Color oliveDark = Color(0xFF3D4327);
  static const Color warmInk = Color(0xFF2A2923);
  static const Color warmMuted = Color(0xFF756B5E);
  static const Color warmLine = Color(0xFFD9CEB8);
  static const Color mapSea = Color(0xFFB8D2CF);
  static const Color mapLand = Color(0xFFE7D8B5);
  static const Color terracotta = Color(0xFFA96E43);
  static const Color sandGold = Color(0xFFC6A361);
}

class PalEyesParchmentPanel extends StatelessWidget {
  const PalEyesParchmentPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = PalEyesVisualV1.radiusLarge,
    this.color = PalEyesVisualV1.paper,
    this.borderColor = PalEyesVisualV1.warmLine,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor.withValues(alpha: 0.72)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: PalEyesVisualV1.warmInk.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return body;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: body,
    );
  }
}

class PalEyesHeritageScene extends StatelessWidget {
  const PalEyesHeritageScene({
    this.height = 360,
    this.title,
    this.subtitle,
    this.eyebrow,
    this.child,
    this.darkOverlay = true,
    this.compact = false,
    super.key,
  });

  final double height;
  final String? title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? child;
  final bool darkOverlay;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 20 : 28),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFFB6C4C5),
                    Color(0xFFD8C7A5),
                    Color(0xFF9B8263),
                  ],
                ),
              ),
            ),
            const CustomPaint(painter: _HeritageScenePainter()),
            if (darkOverlay)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.16),
                      Colors.black.withValues(alpha: 0.64),
                    ],
                  ),
                ),
              ),
            if (child != null)
              Padding(padding: EdgeInsets.all(compact ? 18 : 28), child: child!)
            else if (title != null)
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Padding(
                  padding: EdgeInsets.all(compact ? 18 : 30),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (eyebrow != null) ...<Widget>[
                          _Eyebrow(label: eyebrow!),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          title!,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                height: 1.08,
                              ),
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PalEyesMediaPlaceholder extends StatelessWidget {
  const PalEyesMediaPlaceholder({
    required this.label,
    this.icon = Icons.image_outlined,
    this.height = 180,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = PalEyesHeritageScene(
      height: height,
      compact: true,
      darkOverlay: true,
      child: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PalEyesVisualV1.paper.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: PalEyesVisualV1.oliveDark, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return body;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: body,
    );
  }
}

class PalEyesSectionTitleV1 extends StatelessWidget {
  const PalEyesSectionTitleV1({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 16,
      runSpacing: 10,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: PalEyesVisualV1.warmInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 7),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PalEyesVisualV1.warmMuted,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(actionLabel!),
          ),
      ],
    );
  }
}

class PalEyesTabStripV1 extends StatelessWidget {
  const PalEyesTabStripV1({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: TextButton(
                onPressed: () => onSelected(i),
                style: TextButton.styleFrom(
                  foregroundColor: i == selectedIndex
                      ? PalEyesVisualV1.oliveDark
                      : PalEyesVisualV1.warmMuted,
                  backgroundColor: i == selectedIndex
                      ? PalEyesVisualV1.olive.withValues(alpha: 0.10)
                      : Colors.transparent,
                  shape: const RoundedRectangleBorder(),
                  side: BorderSide(
                    color: i == selectedIndex
                        ? PalEyesVisualV1.olive
                        : Colors.transparent,
                    width: 0,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      labels[i],
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: i == selectedIndex ? 34 : 0,
                      height: 2,
                      color: PalEyesVisualV1.olive,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PalEyesFactRowV1 extends StatelessWidget {
  const PalEyesFactRowV1({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 19, color: PalEyesVisualV1.olive),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: PalEyesVisualV1.warmMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: PalEyesVisualV1.paper.withValues(alpha: 0.16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _HeritageScenePainter extends CustomPainter {
  const _HeritageScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final far = Paint()
      ..color = const Color(0xFF78856E).withValues(alpha: 0.55);
    final mid = Paint()
      ..color = const Color(0xFF716953).withValues(alpha: 0.62);
    final near = Paint()
      ..color = const Color(0xFF493F32).withValues(alpha: 0.70);
    final stone = Paint()
      ..color = const Color(0xFFCEB98E).withValues(alpha: 0.92);
    final olive = Paint()
      ..color = const Color(0xFF465239).withValues(alpha: 0.86);

    Path ridge(double base, double a, double b) => Path()
      ..moveTo(0, size.height * base)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * a,
        size.width * 0.46,
        size.height * base,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * b,
        size.width,
        size.height * (base - .04),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(ridge(.56, .42, .50), far);
    canvas.drawPath(ridge(.70, .58, .64), mid);
    canvas.drawPath(ridge(.83, .74, .78), near);

    final baseY = size.height * .76;
    final unit = math.max(18.0, size.width / 20);
    for (var i = 0; i < 22; i++) {
      final w = unit * (.55 + (i % 4) * .08);
      final h = size.height * (.04 + (i % 5) * .012);
      final x = (i * unit * .86) - unit;
      final y = baseY - h - ((i % 3) * 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          const Radius.circular(2),
        ),
        stone,
      );
      if (i % 4 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(x + w * .42, y - h * .55, w * .16, h * .55),
          stone,
        );
      }
    }

    for (var i = 0; i < 12; i++) {
      final x = size.width * (.04 + i * .085);
      final y = size.height * (.72 + (i % 3) * .035);
      canvas.drawCircle(Offset(x, y), size.shortestSide * .012, olive);
      canvas.drawRect(Rect.fromLTWH(x - 1, y, 2, size.height * .035), olive);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
