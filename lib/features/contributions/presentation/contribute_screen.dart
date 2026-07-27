import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class ContributeScreen extends StatefulWidget {
  const ContributeScreen({super.key});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  String _type = 'تصحيح معلومة';

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PalEyesPage(
      title: 'ساهم في توثيق المكان',
      subtitle:
          'شارك وثيقة أو صورة أو تصحيحاً أو رواية شفوية. تحفظ المساهمة كمسودة ولا تنشر مباشرة.',
      icon: Icons.volunteer_activism_outlined,
      eyebrow: 'المعرفة من أهل المكان',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final guide = const _ContributionGuide();
          final form = Form(
            key: _formKey,
            child: _ContributionForm(
              type: _type,
              titleController: _titleController,
              detailsController: _detailsController,
              onTypeChanged: (value) => setState(() {
                _type = value;
              }),
              onSubmit: _submit,
            ),
          );

          if (constraints.maxWidth >= 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Expanded(flex: 4, child: _ContributionGuide()),
                const SizedBox(width: 22),
                Expanded(flex: 6, child: form),
              ],
            );
          }

          return Column(
            children: <Widget>[guide, const SizedBox(height: 22), form],
          );
        },
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تجهيز المساهمة كمسودة محلية للمعاينة فقط؛ لا توجد كتابة حية في هذه المرحلة.',
        ),
      ),
    );
  }
}

class _ContributionGuide extends StatelessWidget {
  const _ContributionGuide();

  @override
  Widget build(BuildContext context) {
    const options = <(IconData, String, String)>[
      (
        Icons.description_outlined,
        'وثيقة أو مصدر',
        'قاشان، خريطة، سجل، كتاب، بحث أو رابط إلى أصل رقمي.',
      ),
      (
        Icons.photo_outlined,
        'صورة أو مادة بصرية',
        'صورة تاريخية أو معاصرة مع تاريخ ومالك وحقوق واضحة.',
      ),
      (
        Icons.edit_location_alt_outlined,
        'تصحيح مكان أو اسم',
        'اسم محلي، موقع جغرافي، حدود، أو علاقة بين موقع وبلدة.',
      ),
      (
        Icons.record_voice_over_outlined,
        'رواية شفوية',
        'مقابلة أو شهادة مع موافقة الراوي وسياق التسجيل.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.sovereignGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: PalEyesPattern(opacity: 0.04)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.diversity_3_outlined,
                size: 44,
                color: AppColors.softGold,
              ),
              const SizedBox(height: 16),
              Text(
                'المساهمة تبدأ من المعرفة المحلية',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'كل مادة تصل إلى المشروع تمر بمراجعة المصدر والحقوق والدقة قبل أن تصبح قابلة للاعتماد.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 22),
              ...options.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.10),
                        foregroundColor: AppColors.softGold,
                        child: Icon(item.$1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.$2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              item.$3,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.66),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContributionForm extends StatelessWidget {
  const _ContributionForm({
    required this.type,
    required this.titleController,
    required this.detailsController,
    required this.onTypeChanged,
    required this.onSubmit,
  });

  final String type;
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'بيانات المساهمة',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'أدخل الحد الأدنى من المعلومات التي تساعد فريق المراجعة على فهم المادة.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(
                labelText: 'نوع المساهمة',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items:
                  const <String>[
                        'تصحيح معلومة',
                        'اقتراح موقع جديد',
                        'مصدر أو مرجع',
                        'صورة أو وثيقة',
                        'رواية شفوية',
                        'بلاغ ضرر',
                      ]
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  onTypeChanged(value);
                }
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان مختصر',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) => value == null || value.trim().length < 3
                  ? 'اكتب عنواناً واضحاً للمساهمة.'
                  : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: detailsController,
              minLines: 7,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'التفاصيل والسياق',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 128),
                  child: Icon(Icons.notes_rounded),
                ),
                hintText:
                    'ما المادة؟ إلى أي موقع ترتبط؟ ما مصدرها؟ ومن يملك حقوقها؟',
              ),
              validator: (value) => value == null || value.trim().length < 12
                  ? 'أضف تفاصيل كافية لفهم المساهمة.'
                  : null,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.tertiaryContainer.withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'تُحفظ المساهمة كمسودة وتخضع لمراجعة الدقة والمصدر والحقوق قبل أي اعتماد.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.send_rounded),
              label: const Text('حفظ المساهمة كمسودة'),
            ),
          ],
        ),
      ),
    );
  }
}
