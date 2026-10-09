import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';

/// Legacy color names kept for call-site compatibility.
///
/// Every value now resolves to [PalEyesTokens] (editorial ivory / deep green /
/// warm gold). Historical names such as `sovereignBlue` or `approvedNavy` no
/// longer denote navy; the August 2026 navy candidate is superseded and is
/// not a visual identity authority.
abstract final class AppColors {
  static const Color sovereignBlue = PalEyesTokens.green800;
  static const Color deepBlue = PalEyesTokens.green700;
  static const Color midnight = PalEyesTokens.green900;
  static const Color heritageGold = PalEyesTokens.gold;
  static const Color softGold = PalEyesTokens.goldSoft;
  static const Color royalRed = PalEyesTokens.alert;
  static const Color olive = PalEyesTokens.green600;
  static const Color oliveLight = PalEyesTokens.green500;
  static const Color warmCanvas = PalEyesTokens.ivory;
  static const Color warmCanvasAlt = PalEyesTokens.cream;
  static const Color stone = PalEyesTokens.line;
  static const Color sandstone = PalEyesTokens.lineStrong;
  static const Color ink = PalEyesTokens.ink;
  static const Color inkSoft = PalEyesTokens.inkMuted;
  static const Color sea = PalEyesTokens.sea;
  static const Color dusk = PalEyesTokens.terracotta;
  static const Color success = PalEyesTokens.success;

  static const Color approvedNavy = PalEyesTokens.green800;
  static const Color approvedNavyDeep = PalEyesTokens.green900;
  static const Color approvedIvory = PalEyesTokens.ivory;
  static const Color approvedCream = PalEyesTokens.cream;
  static const Color approvedGold = PalEyesTokens.gold;
  static const Color approvedGoldSoft = PalEyesTokens.goldSoft;
  static const Color approvedOutline = PalEyesTokens.line;

  static const LinearGradient approvedHeroGradient =
      PalEyesTokens.structureGradient;

  static const LinearGradient sovereignGradient =
      PalEyesTokens.structureGradient;

  static const LinearGradient heritageGradient = PalEyesTokens.goldGradient;

  static const LinearGradient earthGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[PalEyesTokens.green600, PalEyesTokens.green800],
  );
}
