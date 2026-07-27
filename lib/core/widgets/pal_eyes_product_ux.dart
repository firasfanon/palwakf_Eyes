import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';

class PalEyesTaskPage extends StatelessWidget {
  const PalEyesTaskPage({
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon = Icons.workspaces_outline,
    this.actions = const <Widget>[],
    this.notice,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final IconData icon;
  final List<Widget> actions;
  final String? notice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              decoration: const BoxDecoration(
                gradient: AppColors.sovereignGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            child: Icon(icon),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.55,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (actions.isNotEmpty)
                      Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed(<Widget>[
                if (notice != null) ...<Widget>[
                  PalEyesNotice(text: notice!),
                  const SizedBox(height: 16),
                ],
                child,
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class PalEyesNotice extends StatelessWidget {
  const PalEyesNotice({
    required this.text,
    this.icon = Icons.info_outline_rounded,
    super.key,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(height: 1.55))),
          ],
        ),
      ),
    );
  }
}

class PalEyesKpiCard extends StatelessWidget {
  const PalEyesKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    this.helper,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            if (helper != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(helper!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class PalEyesActionCard extends StatelessWidget {
  const PalEyesActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badge,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (badge != null) Chip(label: Text(badge!)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(subtitle, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class PalEyesEmptyState extends StatelessWidget {
  const PalEyesEmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: <Widget>[
                Icon(icon, size: 44),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: onAction, child: Text(actionLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PalEyesWorkflowStatus extends StatelessWidget {
  const PalEyesWorkflowStatus({
    required this.label,
    required this.status,
    required this.icon,
    super.key,
  });

  final String label;
  final String status;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(status),
      trailing: const Icon(Icons.chevron_left_rounded),
    );
  }
}
