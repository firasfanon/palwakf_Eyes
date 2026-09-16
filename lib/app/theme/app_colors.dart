import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color sovereignBlue = Color(0xFF0B2742);
  static const Color deepBlue = Color(0xFF123B5D);
  static const Color midnight = Color(0xFF071A2B);
  static const Color heritageGold = Color(0xFFC89A4B);
  static const Color softGold = Color(0xFFE4C78A);
  static const Color royalRed = Color(0xFFA73535);
  static const Color olive = Color(0xFF596A45);
  static const Color oliveLight = Color(0xFF93A574);
  static const Color warmCanvas = Color(0xFFF6F2E9);
  static const Color warmCanvasAlt = Color(0xFFEFE8DA);
  static const Color stone = Color(0xFFE2D8C8);
  static const Color sandstone = Color(0xFFD4C1A1);
  static const Color ink = Color(0xFF17212B);
  static const Color inkSoft = Color(0xFF44505A);
  static const Color sea = Color(0xFF2F6E7E);
  static const Color dusk = Color(0xFF6A506B);
  static const Color success = Color(0xFF317A57);

  // Approved public visual direction - 2026-08-12.
  // Additive semantic tokens preserve legacy behavior during migration.
  static const Color approvedNavy = Color(0xFF08243D);
  static const Color approvedNavyDeep = Color(0xFF041A2D);
  static const Color approvedIvory = Color(0xFFFBF6ED);
  static const Color approvedCream = Color(0xFFF4EBDD);
  static const Color approvedGold = Color(0xFFD4A85B);
  static const Color approvedGoldSoft = Color(0xFFF0D9A7);
  static const Color approvedOutline = Color(0xFFE8DCC8);

  static const LinearGradient approvedHeroGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[approvedNavyDeep, approvedNavy, Color(0xFF123D5C)],
  );

  static const LinearGradient sovereignGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[midnight, sovereignBlue, deepBlue],
  );

  static const LinearGradient heritageGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[Color(0xFFE9D4A7), Color(0xFFC89A4B)],
  );

  static const LinearGradient earthGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[Color(0xFF6C7951), Color(0xFF3F5038)],
  );
}
