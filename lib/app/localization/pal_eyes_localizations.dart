import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PalEyesLocalizations {
  const PalEyesLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<PalEyesLocalizations> delegate =
      _PalEyesLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  static PalEyesLocalizations of(BuildContext context) {
    return Localizations.of<PalEyesLocalizations>(
      context,
      PalEyesLocalizations,
    )!;
  }

  String text(String key) {
    return _values[locale.languageCode]?[key] ?? _values['ar']![key] ?? key;
  }

  bool get isArabic => locale.languageCode == 'ar';

  static const Map<String, Map<String, String>> _values = {
    'ar': {
      'appName': 'بعيون فلسطينية',
      'home': 'الرئيسية',
      'discover': 'استكشف',
      'places': 'المواقع',
      'map': 'الخريطة',
      'timeline': 'الخط الزمني',
      'governorates': 'المحافظات',
      'stories': 'القصص',
      'sources': 'المصادر',
      'contribute': 'ساهم معنا',
      'methodology': 'المنهجية',
      'workspace': 'مساحة العمل',
      'governance': 'الحوكمة والنظام',
      'switchLanguage': 'English',
    },
    'en': {
      'appName': 'Palestinian Eyes',
      'home': 'Home',
      'discover': 'Discover',
      'places': 'Places',
      'map': 'Map',
      'timeline': 'Timeline',
      'governorates': 'Governorates',
      'stories': 'Stories',
      'sources': 'Sources',
      'contribute': 'Contribute',
      'methodology': 'Methodology',
      'workspace': 'Workspace',
      'governance': 'Governance and System',
      'switchLanguage': 'العربية',
    },
  };
}

class _PalEyesLocalizationsDelegate
    extends LocalizationsDelegate<PalEyesLocalizations> {
  const _PalEyesLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => PalEyesLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<PalEyesLocalizations> load(Locale locale) {
    return SynchronousFuture<PalEyesLocalizations>(
      PalEyesLocalizations(locale),
    );
  }

  @override
  bool shouldReload(_PalEyesLocalizationsDelegate old) => false;
}

/// Translates a fixed Arabic UI label into English when the active locale is
/// English. Arabic stays the source of truth (literals remain in the widget
/// source); unknown labels fall back to Arabic rather than inventing text.
/// Content (narratives, site names) is not machine-translated.
String tr(BuildContext context, String arabic) {
  final code = Localizations.maybeLocaleOf(context)?.languageCode;
  if (code != 'en') {
    return arabic;
  }
  return palEyesArabicToEnglish[arabic] ?? arabic;
}

const Map<String, String> palEyesArabicToEnglish = <String, String>{
  'بعيون فلسطينية': 'Palestinian Eyes',
  'المكان · الذاكرة · الحكاية': 'Place · Memory · Story',
  'الرئيسية': 'Home',
  'استكشف': 'Discover',
  'الأماكن': 'Places',
  'البحوث': 'Research',
  'الخريطة': 'Map',
  'الحكايات': 'Stories',
  'المزيد': 'More',
  'عبر الزمن': 'Through time',
  'المحافظات': 'Governorates',
  'المصادر': 'Sources',
  'المنهجية': 'Methodology',
  'ساهم في الذاكرة': 'Contribute to memory',
  'ابحث عن مكان، حكاية أو موضوع...': 'Search a place, story or topic...',
  'تبديل المظهر': 'Toggle theme',
  'القائمة': 'Menu',
  'مساحة العمل': 'Workspace',
  'الحوكمة والإدارة': 'Governance and administration',
  'فتح مساحة العمل': 'Open workspace',
  'لوحة الحوكمة والإدارة': 'Governance and administration board',
  'الوضع الفاتح': 'Light mode',
  'الوضع الداكن': 'Dark mode',
  'تبديل اللغة': 'Switch language',
  'تسجيل الدخول': 'Sign in',
  'خروج': 'Sign out',
  'أمان الحساب': 'Account security',
  'المستخدمون والأدوار': 'Users and roles',
};
