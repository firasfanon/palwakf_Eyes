import 'package:flutter/material.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';

class NewPlaceDraftScreen extends StatefulWidget {
  const NewPlaceDraftScreen({super.key});

  @override
  State<NewPlaceDraftScreen> createState() => _NewPlaceDraftScreenState();
}

class _NewPlaceDraftScreenState extends State<NewPlaceDraftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _localityController = TextEditingController();
  final _summaryController = TextEditingController();
  int _step = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _localityController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PalEyesPage(
      title: 'إضافة موقع جديد',
      subtitle:
          'إنشاء مسودة تشغيلية محلية؛ لا تُنشر ولا تُرسل إلى قاعدة بيانات حالياً.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ChoiceChip(
                  selected: _step == 0,
                  onSelected: (_) => setState(() => _step = 0),
                  label: const Text('1. الهوية'),
                ),
                ChoiceChip(
                  selected: _step == 1,
                  onSelected: (_) => setState(() => _step = 1),
                  label: const Text('2. الموقع'),
                ),
                ChoiceChip(
                  selected: _step == 2,
                  onSelected: (_) => setState(() => _step = 2),
                  label: const Text('3. ملخص المسودة'),
                ),
                ChoiceChip(
                  selected: _step == 3,
                  onSelected: (_) => setState(() => _step = 3),
                  label: const Text('4. المراجعة'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: switch (_step) {
                    0 => TextFormField(
                      key: const ValueKey<String>('identity'),
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الموقع بالعربية',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'اسم الموقع مطلوب.'
                          : null,
                    ),
                    1 => TextFormField(
                      key: const ValueKey<String>('location'),
                      controller: _localityController,
                      decoration: const InputDecoration(
                        labelText: 'البلدة أو المدينة',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'حدد السياق المكاني.'
                          : null,
                    ),
                    2 => TextFormField(
                      key: const ValueKey<String>('summary'),
                      controller: _summaryController,
                      minLines: 5,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'ملخص تاريخي أولي',
                        helperText:
                            'يظهر كمسودة خاضعة للتدقيق، ولا تكتب ادعاءً قطعياً بلا مصدر.',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 30
                          ? 'أضف ملخصاً أولياً لا يقل عن 30 حرفاً.'
                          : null,
                    ),
                    _ => const _ReviewNotice(),
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                OutlinedButton(
                  onPressed: _step == 0
                      ? null
                      : () => setState(() => _step -= 1),
                  child: const Text('السابق'),
                ),
                const Spacer(),
                if (_step < 3)
                  FilledButton(
                    onPressed: () => setState(() => _step += 1),
                    child: const Text('التالي'),
                  )
                else
                  FilledButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('حفظ المسودة محلياً'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveDraft() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _step = 0);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت معاينة مسودة "${_nameController.text}" محلياً. '
          'الحفظ الدائم سيُفعّل بعد ربط Supabase.',
        ),
      ),
    );
  }
}

class _ReviewNotice extends StatelessWidget {
  const _ReviewNotice();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey<String>('review'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'قبل الحفظ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 10),
        Text('• سيُنشأ الموقع بحالة «مسودة خاضعة للتدقيق».'),
        Text('• لا يظهر بوصفه منشوراً أو معتمداً.'),
        Text('• المصادر والادعاءات تضاف في مساحة التوثيق.'),
        Text('• النشر يبقى محجوباً حتى اكتمال دورة المراجعة.'),
      ],
    );
  }
}
