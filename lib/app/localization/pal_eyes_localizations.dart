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
  bool isSupported(Locale locale) =>
      PalEyesLocalizations.supportedLocales.any(
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
