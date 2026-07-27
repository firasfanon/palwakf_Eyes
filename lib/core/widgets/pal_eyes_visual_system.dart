import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';

class PalEyesBrandMark extends StatelessWidget {
  const PalEyesBrandMark({
    this.compact = false,
    this.foregroundColor,
    super.key,
  });

  final bool compact;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: compact ? 38 : 46,
          height: compact ? 38 : 46,
          decoration: BoxDecoration(
            gradient: AppColors.heritageGradient,
            borderRadius: BorderRadius.circular(compact ? 13 : 16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.heritageGold.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                Icons.visibility_rounded,
                color: AppColors.sovereignBlue,
                size: 25,
              ),
              Positioned(
                bottom: 7,
                child: SizedBox(
                  width: 18,
                  child: Divider(
                    height: 1,
                    thickness: 2,
                    color: AppColors.royalRed,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 11),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'بعيون فلسطينية',
              style: TextStyle(
                color: color,
                fontSize: compact ? 17 : 20,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            if (!compact)
              Text(
                'المكان • الرواية • الدليل',
                style: TextStyle(
                  color: color.withValues(alpha: 0.68),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class PalEyesPattern extends StatelessWidget {
  const PalEyesPattern({
    this.color = Colors.white,
    this.opacity = 0.08,
    super.key,
  });

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _HeritagePatternPainter(color.withValues(alpha: opacity)),
        size: Size.infinite,
      ),
    );
  }
}

class PalestineMapArtwork extends StatelessWidget {
  const PalestineMapArtwork({
    this.compact = false,
    this.showMarkers = true,
    this.foregroundColor = AppColors.softGold,
    super.key,
  });

  final bool compact;
  final bool showMarkers;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: compact ? 0.82 : 0.78,
      child: CustomPaint(
        painter: _PalestineMapPainter(
          foregroundColor: foregroundColor,
          showMarkers: showMarkers,
        ),
      ),
    );
  }
}

class PalEyesPageHero extends StatelessWidget {
  const PalEyesPageHero({
    required this.title,
    required this.subtitle,
    this.actions = const <Widget>[],
    this.header,
    this.icon = Icons.explore_outlined,
    this.eyebrow = 'بعيون فلسطينية',
    this.maxWidth = 1240,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget? header;
  final IconData icon;
  final String eyebrow;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 600 ? 16.0 : 28.0;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.sovereignGradient),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: PalEyesPattern()),
          PositionedDirectional(
            end: width < 720 ? -40 : 42,
            top: width < 720 ? 10 : -36,
            bottom: -70,
            child: Opacity(
              opacity: 0.16,
              child: SizedBox(
                width: width < 720 ? 210 : 320,
                child: const PalestineMapArtwork(showMarkers: false),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  width < 600 ? 30 : 44,
                  horizontal,
                  width < 600 ? 28 : 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 18,
                      runSpacing: 18,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _Eyebrow(icon: icon, label: eyebrow),
                              const SizedBox(height: 14),
                              Text(
                                title,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.76,
                                      ),
                                      height: 1.65,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (actions.isNotEmpty)
                          Wrap(spacing: 9, runSpacing: 9, children: actions),
                      ],
                    ),
                    if (header != null) ...<Widget>[
                      const SizedBox(height: 24),
                      header!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PalEyesSectionHeader extends StatelessWidget {
  const PalEyesSectionHeader({
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.actionLabel,
    this.onAction,
    this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 18,
      runSpacing: 12,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (eyebrow != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _Eyebrow(
                    icon: icon ?? Icons.auto_awesome_outlined,
                    label: eyebrow!,
                    dark: false,
                  ),
                ),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(actionLabel!),
          ),
      ],
    );
  }
}

class PalEyesMetricTile extends StatelessWidget {
  const PalEyesMetricTile({
    required this.icon,
    required this.value,
    required this.label,
    this.note,
    this.emphasis = false,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? note;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: emphasis
            ? const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: <Color>[AppColors.sovereignBlue, AppColors.deepBlue],
              )
            : null,
        color: emphasis ? null : scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: emphasis
              ? Colors.white.withValues(alpha: 0.10)
              : scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: emphasis
                  ? Colors.white.withValues(alpha: 0.11)
                  : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: emphasis ? AppColors.softGold : scheme.primary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: emphasis ? Colors.white : null,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: emphasis
                        ? Colors.white.withValues(alpha: 0.84)
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (note != null)
                  Text(
                    note!,
                    style: TextStyle(
                      color: emphasis
                          ? Colors.white.withValues(alpha: 0.60)
                          : scheme.onSurfaceVariant.withValues(alpha: 0.76),
                      fontSize: 11,
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

class PalEyesVisualCard extends StatelessWidget {
  const PalEyesVisualCard({
    required this.icon,
    required this.title,
    required this.description,
    this.label,
    this.onTap,
    this.gradient,
    this.footer,
    this.dark = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? label;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Widget? footer;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = dark ? Colors.white : scheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? scheme.surface : null,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.10)
                  : scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Stack(
            children: <Widget>[
              if (gradient != null)
                const Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(26)),
                    child: PalEyesPattern(opacity: 0.06),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 220;
                    final iconExtent = compact ? 44.0 : 48.0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: iconExtent,
                              height: iconExtent,
                              decoration: BoxDecoration(
                                color: dark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  compact ? 14 : 16,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: dark
                                    ? AppColors.softGold
                                    : scheme.primary,
                              ),
                            ),
                            const Spacer(),
                            if (label != null)
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 9 : 11,
                                    vertical: compact ? 5 : 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: dark
                                        ? Colors.white.withValues(alpha: 0.11)
                                        : scheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    label!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: dark
                                          ? Colors.white
                                          : scheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w900,
                                      fontSize: compact ? 11 : 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: compact ? 12 : 18),
                        Text(
                          title,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        SizedBox(height: compact ? 6 : 8),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              description,
                              maxLines: compact ? 3 : 5,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: foreground.withValues(alpha: 0.75),
                                height: compact ? 1.45 : 1.65,
                              ),
                            ),
                          ),
                        ),
                        if (footer != null) ...<Widget>[
                          SizedBox(height: compact ? 10 : 14),
                          footer!,
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PalEyesGlassPanel extends StatelessWidget {
  const PalEyesGlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.dark = true,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.09)
            : scheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.14)
              : scheme.outlineVariant.withValues(alpha: 0.50),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.16 : 0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PalEyesTimelineBand extends StatelessWidget {
  const PalEyesTimelineBand({
    required this.periods,
    this.selectedIndex = 0,
    this.onSelected,
    super.key,
  });

  final List<String> periods;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: periods.length,
        separatorBuilder: (_, _) => SizedBox(
          width: 38,
          child: Center(
            child: Container(height: 2, color: scheme.outlineVariant),
          ),
        ),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onSelected == null ? null : () => onSelected!(index),
            child: SizedBox(
              width: 126,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: selected ? 20 : 13,
                    height: selected ? 20 : 13,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.heritageGold
                          : scheme.primary.withValues(alpha: 0.24),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? scheme.primary : scheme.outline,
                        width: selected ? 4 : 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    periods[index],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                      color: selected ? scheme.primary : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.icon, required this.label, this.dark = true});

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = dark ? AppColors.softGold : scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.09)
            : scheme.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.12)
              : scheme.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: foreground),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: dark ? Colors.white : scheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeritagePatternPainter extends CustomPainter {
  const _HeritagePatternPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const cell = 42.0;
    for (double y = -cell; y < size.height + cell; y += cell) {
      for (double x = -cell; x < size.width + cell; x += cell) {
        final center = Offset(x, y);
        final path = Path()
          ..moveTo(center.dx, center.dy - 12)
          ..lineTo(center.dx + 12, center.dy)
          ..lineTo(center.dx, center.dy + 12)
          ..lineTo(center.dx - 12, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawCircle(center, 3.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeritagePatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PalestineMapPainter extends CustomPainter {
  const _PalestineMapPainter({
    required this.foregroundColor,
    required this.showMarkers,
  });

  final Color foregroundColor;
  final bool showMarkers;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 250;
    final sy = size.height / 420;

    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final path = Path()
      ..moveTo(p(106, 12).dx, p(106, 12).dy)
      ..cubicTo(
        p(137, 28).dx,
        p(137, 28).dy,
        p(150, 53).dx,
        p(150, 53).dy,
        p(143, 82).dx,
        p(143, 82).dy,
      )
      ..cubicTo(
        p(133, 114).dx,
        p(133, 114).dy,
        p(154, 144).dx,
        p(154, 144).dy,
        p(145, 178).dx,
        p(145, 178).dy,
      )
      ..cubicTo(
        p(136, 212).dx,
        p(136, 212).dy,
        p(160, 240).dx,
        p(160, 240).dy,
        p(151, 275).dx,
        p(151, 275).dy,
      )
      ..cubicTo(
        p(143, 307).dx,
        p(143, 307).dy,
        p(168, 340).dx,
        p(168, 340).dy,
        p(155, 375).dx,
        p(155, 375).dy,
      )
      ..cubicTo(
        p(144, 400).dx,
        p(144, 400).dy,
        p(124, 414).dx,
        p(124, 414).dy,
        p(110, 397).dx,
        p(110, 397).dy,
      )
      ..cubicTo(
        p(97, 378).dx,
        p(97, 378).dy,
        p(99, 351).dx,
        p(99, 351).dy,
        p(87, 328).dx,
        p(87, 328).dy,
      )
      ..cubicTo(
        p(77, 307).dx,
        p(77, 307).dy,
        p(91, 282).dx,
        p(91, 282).dy,
        p(78, 259).dx,
        p(78, 259).dy,
      )
      ..cubicTo(
        p(66, 237).dx,
        p(66, 237).dy,
        p(78, 209).dx,
        p(78, 209).dy,
        p(66, 185).dx,
        p(66, 185).dy,
      )
      ..cubicTo(
        p(54, 160).dx,
        p(54, 160).dy,
        p(72, 134).dx,
        p(72, 134).dy,
        p(66, 108).dx,
        p(66, 108).dy,
      )
      ..cubicTo(
        p(61, 78).dx,
        p(61, 78).dy,
        p(74, 51).dx,
        p(74, 51).dy,
        p(106, 12).dx,
        p(106, 12).dy,
      )
      ..close();

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.save();
    canvas.translate(8, 10);
    canvas.drawPath(path, shadow);
    canvas.restore();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          foregroundColor,
          foregroundColor.withValues(alpha: 0.55),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);

    final outline = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(path, outline);

    final contour = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 8; i++) {
      final y = 65.0 + i * 39;
      canvas.drawArc(
        Rect.fromCenter(
          center: p(110 + math.sin(i.toDouble()) * 8, y),
          width: 72 * sx,
          height: 26 * sy,
        ),
        0.2,
        math.pi * 0.72,
        false,
        contour,
      );
    }

    if (showMarkers) {
      final markerPaint = Paint()..color = AppColors.royalRed;
      final halo = Paint()
        ..color = Colors.white.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      for (final point in <Offset>[
        p(116, 108),
        p(105, 196),
        p(118, 266),
        p(109, 330),
      ]) {
        canvas.drawCircle(point, 7, halo);
        canvas.drawCircle(point, 4.2, markerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PalestineMapPainter oldDelegate) =>
      oldDelegate.foregroundColor != foregroundColor ||
      oldDelegate.showMarkers != showMarkers;
}
