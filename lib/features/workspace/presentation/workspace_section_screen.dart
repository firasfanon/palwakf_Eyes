import 'package:flutter/material.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class WorkspaceSectionScreen extends StatelessWidget {
  const WorkspaceSectionScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return PalEyesPage(
      title: title,
      subtitle: subtitle,
      icon: icon,
      eyebrow: 'مساحة العمل',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 820
                  ? (constraints.maxWidth - 32) / 3
                  : constraints.maxWidth >= 560
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: items
                    .asMap()
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: width,
                        height: 220,
                        child: PalEyesVisualCard(
                          icon: icon,
                          title: entry.value,
                          description:
                              'سطح تشغيلي منظم للقراءة والمراجعة والتطوير ضمن حدود المسودة الحالية.',
                          label: 'مسار تشغيلي',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('فتح: ${entry.value}')),
                              ),
                          footer: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 15,
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_back_rounded),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}
