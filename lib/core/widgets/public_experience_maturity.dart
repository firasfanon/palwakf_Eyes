import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

enum PublicContentStateKind { loading, empty, error }

class PalEyesPublicDisclosure extends StatelessWidget {
  const PalEyesPublicDisclosure({
    required this.summary,
    this.title = 'مسودة خاضعة للتدقيق',
    this.details = const <String>[],
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String summary;
  final List<String> details;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title. $summary',
      child: Material(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: const Icon(Icons.info_outline_rounded),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(summary),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          children: <Widget>[
            if (details.isNotEmpty)
              ...details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(Icons.circle, size: 6),
                      ),
                      const SizedBox(width: 9),
                      Expanded(child: Text(detail)),
                    ],
                  ),
                ),
              ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 14),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PalEyesPublicSearchPanel extends StatelessWidget {
  const PalEyesPublicSearchPanel({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.activeFilterCount = 0,
    this.filters,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int activeFilterCount;
  final Widget? filters;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'البحث في المحتوى',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: hintText,
                  labelText: 'ما الذي تريد اكتشافه؟',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'مسح عبارة البحث',
                          onPressed: onClear,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              if (filters != null) ...<Widget>[
                const SizedBox(height: 14),
                filters!,
              ],
              if (activeFilterCount > 0) ...<Widget>[
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Chip(
                    avatar: const Icon(Icons.tune_rounded, size: 17),
                    label: Text('$activeFilterCount فلاتر نشطة'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PalEyesPublicStatePanel extends StatelessWidget {
  const PalEyesPublicStatePanel({
    required this.kind,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final PublicContentStateKind kind;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final icon = switch (kind) {
      PublicContentStateKind.loading => Icons.hourglass_top_rounded,
      PublicContentStateKind.empty => Icons.travel_explore_rounded,
      PublicContentStateKind.error => Icons.error_outline_rounded,
    };
    final color = switch (kind) {
      PublicContentStateKind.loading => Theme.of(context).colorScheme.primary,
      PublicContentStateKind.empty => Theme.of(context).colorScheme.secondary,
      PublicContentStateKind.error => Theme.of(context).colorScheme.error,
    };

    return Semantics(
      liveRegion: true,
      container: true,
      label: '$title. $message',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.65),
                ),
              ),
              if (kind == PublicContentStateKind.loading) ...<Widget>[
                const SizedBox(height: 18),
                const LinearProgressIndicator(),
              ],
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PalEyesMediaStage extends StatelessWidget {
  const PalEyesMediaStage({
    required this.title,
    required this.subtitle,
    required this.semanticLabel,
    this.icon = Icons.account_balance_outlined,
    this.height = 300,
    this.gradient = AppColors.sovereignGradient,
    this.footer,
    super.key,
  });

  final String title;
  final String subtitle;
  final String semanticLabel;
  final IconData icon;
  final double height;
  final Gradient gradient;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Container(
        constraints: BoxConstraints(minHeight: height),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: PalEyesPattern(opacity: 0.07)),
            PositionedDirectional(
              end: 26,
              top: 28,
              child: Icon(
                icon,
                size: 120,
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            PositionedDirectional(
              start: 24,
              end: 24,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, height: 1.55),
                  ),
                  if (footer != null) ...<Widget>[
                    const SizedBox(height: 16),
                    footer!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PalEyesReadingProgress extends StatelessWidget {
  const PalEyesReadingProgress({
    required this.readingMinutes,
    required this.chapterCount,
    this.progress = 0,
    super.key,
  });

  final int readingMinutes;
  final int chapterCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'زمن القراءة $readingMinutes دقيقة. عدد الفصول $chapterCount.',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.schedule_rounded),
                  const SizedBox(width: 8),
                  Text('$readingMinutes دقيقة قراءة'),
                  const Spacer(),
                  const Icon(Icons.menu_book_rounded),
                  const SizedBox(width: 8),
                  Text('$chapterCount فصول'),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0).toDouble(),
                minHeight: 5,
                borderRadius: BorderRadius.circular(99),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PublicJourneyAction {
  const PublicJourneyAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

class PalEyesQuickPathBar extends StatelessWidget {
  const PalEyesQuickPathBar({
    required this.title,
    required this.actions,
    super.key,
  });

  final String title;
  final List<PublicJourneyAction> actions;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: title,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              ...actions.map(
                (action) => ActionChip(
                  avatar: Icon(action.icon, size: 18),
                  label: Text(action.label),
                  onPressed: action.onPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
