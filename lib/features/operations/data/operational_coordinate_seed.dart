import 'package:pal_eyes/features/operations/domain/operational_models.dart';

class OperationalCoordinateSeedEntry {
  const OperationalCoordinateSeedEntry({
    required this.id,
    required this.siteId,
    required this.siteNameAr,
    required this.latitude,
    required this.longitude,
    required this.sourceId,
    required this.verificationStatus,
    required this.promotionStatus,
    required this.publicMapUse,
  });

  final String id;
  final String siteId;
  final String siteNameAr;
  final double latitude;
  final double longitude;
  final String sourceId;
  final String verificationStatus;
  final String promotionStatus;
  final String publicMapUse;

  OperationalCoordinateCandidate toCandidate({required DateTime updatedAt}) {
    return OperationalCoordinateCandidate(
      id: id,
      siteId: siteId,
      siteNameAr: siteNameAr,
      latitude: latitude,
      longitude: longitude,
      sourceId: sourceId,
      verificationStatus: verificationStatus,
      promotionStatus: promotionStatus,
      publicMapUse: publicMapUse,
      updatedAt: updatedAt,
    );
  }
}

const List<OperationalCoordinateSeedEntry> operationalCoordinateSeed =
    <OperationalCoordinateSeedEntry>[
      OperationalCoordinateSeedEntry(
        id: 'W4-COORD-GERIZIM-001',
        siteId: 'site-b6773e683274',
        siteNameAr: 'جبل جرزيم',
        latitude: 32.2122222222,
        longitude: 35.2688888889,
        sourceId: 'W4-AUTH-UNESCO-GERIZIM-2012',
        verificationStatus: 'SOURCE_TRACED_NOT_INDEPENDENTLY_VERIFIED',
        promotionStatus: 'NOT_PROMOTED',
        publicMapUse: 'BLOCKED',
      ),
      OperationalCoordinateSeedEntry(
        id: 'W3-COORD-OMARI-001',
        siteId: 'site-2e45744cdab4',
        siteNameAr: 'المسجد العمري الكبير',
        latitude: 31.5043333333,
        longitude: 34.4646388889,
        sourceId: 'W3-AUTH-UNESCO-GAZA-HISTORIC-CENTRE-2026',
        verificationStatus: 'SOURCE_TRACED_NOT_INDEPENDENTLY_VERIFIED',
        promotionStatus: 'NOT_PROMOTED',
        publicMapUse: 'BLOCKED',
      ),
      OperationalCoordinateSeedEntry(
        id: 'W3-COORD-PORPHYRIOS-001',
        siteId: 'site-e1e3de7b8519',
        siteNameAr: 'كنيسة القديس برفيريوس',
        latitude: 31.5033333333,
        longitude: 34.4622222222,
        sourceId: 'W3-AUTH-UNESCO-GAZA-HISTORIC-CENTRE-2026',
        verificationStatus: 'SOURCE_TRACED_NOT_INDEPENDENTLY_VERIFIED',
        promotionStatus: 'NOT_PROMOTED',
        publicMapUse: 'BLOCKED',
      ),
      OperationalCoordinateSeedEntry(
        id: 'W3-COORD-GAZA-HISTORIC-CENTRE-001',
        siteId: 'site-015f495c4236',
        siteNameAr: 'مدينة غزة القديمة',
        latitude: 31.5049611111,
        longitude: 34.4641,
        sourceId: 'W3-AUTH-UNESCO-GAZA-HISTORIC-CENTRE-2026',
        verificationStatus: 'SOURCE_TRACED_NOT_INDEPENDENTLY_VERIFIED',
        promotionStatus: 'NOT_PROMOTED',
        publicMapUse: 'BLOCKED',
      ),
    ];

const Set<String> operationalCoordinateSeedSiteIds = <String>{
  'site-b6773e683274',
  'site-2e45744cdab4',
  'site-e1e3de7b8519',
  'site-015f495c4236',
};
