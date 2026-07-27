import 'dart:convert';

enum OperationalBackendMode { localFallback, supabase }

extension OperationalBackendModeX on OperationalBackendMode {
  String get labelAr => switch (this) {
    OperationalBackendMode.localFallback => 'تشغيل محلي مؤقت',
    OperationalBackendMode.supabase => 'Supabase محكوم',
  };
}

class OperationalActor {
  const OperationalActor({
    required this.id,
    required this.displayName,
    required this.roles,
  });

  final String id;
  final String displayName;
  final Set<String> roles;

  bool hasAnyRole(Iterable<String> allowed) => allowed.any(roles.contains);
}

class OperationalSiteRecord {
  const OperationalSiteRecord({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.governorateAr,
    required this.localityAr,
    required this.siteTypeAr,
    required this.pageCategory,
    required this.workflowStatus,
    required this.publicationStatus,
    required this.coordinateStatus,
    required this.originalDraftProfile,
    required this.editorialDraft,
    required this.sourceCount,
    required this.heldClaimCount,
    required this.versionNumber,
    required this.updatedAt,
  });

  factory OperationalSiteRecord.fromJson(Map<String, Object?> json) {
    return OperationalSiteRecord(
      id: json['id']! as String,
      slug: json['slug']! as String,
      nameAr: json['name_ar']! as String,
      governorateAr: (json['governorate_ar'] ?? '') as String,
      localityAr: (json['locality_ar'] ?? '') as String,
      siteTypeAr: (json['site_type_ar'] ?? '') as String,
      pageCategory:
          (json['page_category'] ?? 'LIMITED_RESEARCH_PAGE') as String,
      workflowStatus: (json['workflow_status'] ?? 'DRAFT') as String,
      publicationStatus: (json['publication_status'] ?? 'BLOCKED') as String,
      coordinateStatus: (json['coordinate_status'] ?? 'MISSING') as String,
      originalDraftProfile:
          (json['original_draft_profile'] ?? 'catalogSummary') as String,
      editorialDraft: (json['editorial_draft'] ?? '') as String,
      sourceCount: (json['source_count'] as num?)?.toInt() ?? 0,
      heldClaimCount: (json['held_claim_count'] as num?)?.toInt() ?? 0,
      versionNumber: (json['version_number'] as num?)?.toInt() ?? 1,
      updatedAt:
          DateTime.tryParse((json['updated_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String id;
  final String slug;
  final String nameAr;
  final String governorateAr;
  final String localityAr;
  final String siteTypeAr;
  final String pageCategory;
  final String workflowStatus;
  final String publicationStatus;
  final String coordinateStatus;
  final String originalDraftProfile;
  final String editorialDraft;
  final int sourceCount;
  final int heldClaimCount;
  final int versionNumber;
  final DateTime updatedAt;

  bool get publicCoordinatesApproved => coordinateStatus == 'PUBLIC_APPROVED';

  OperationalSiteRecord copyWith({
    String? workflowStatus,
    String? publicationStatus,
    String? coordinateStatus,
    String? editorialDraft,
    int? sourceCount,
    int? heldClaimCount,
    int? versionNumber,
    DateTime? updatedAt,
  }) {
    return OperationalSiteRecord(
      id: id,
      slug: slug,
      nameAr: nameAr,
      governorateAr: governorateAr,
      localityAr: localityAr,
      siteTypeAr: siteTypeAr,
      pageCategory: pageCategory,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      coordinateStatus: coordinateStatus ?? this.coordinateStatus,
      originalDraftProfile: originalDraftProfile,
      editorialDraft: editorialDraft ?? this.editorialDraft,
      sourceCount: sourceCount ?? this.sourceCount,
      heldClaimCount: heldClaimCount ?? this.heldClaimCount,
      versionNumber: versionNumber ?? this.versionNumber,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'slug': slug,
    'name_ar': nameAr,
    'governorate_ar': governorateAr,
    'locality_ar': localityAr,
    'site_type_ar': siteTypeAr,
    'page_category': pageCategory,
    'workflow_status': workflowStatus,
    'publication_status': publicationStatus,
    'coordinate_status': coordinateStatus,
    'original_draft_profile': originalDraftProfile,
    'editorial_draft': editorialDraft,
    'source_count': sourceCount,
    'held_claim_count': heldClaimCount,
    'version_number': versionNumber,
    'updated_at': updatedAt.toIso8601String(),
  };
}

class OperationalSourceRecord {
  const OperationalSourceRecord({
    required this.id,
    required this.title,
    required this.attribution,
    required this.sourceType,
    required this.url,
    required this.workflowStatus,
    required this.rightsStatus,
    required this.publicReleaseStatus,
    required this.linkedSiteCount,
    required this.linkedClaimCount,
    required this.updatedAt,
  });

  factory OperationalSourceRecord.fromJson(Map<String, Object?> json) {
    return OperationalSourceRecord(
      id: json['id']! as String,
      title: json['title']! as String,
      attribution: (json['attribution'] ?? '') as String,
      sourceType: (json['source_type'] ?? 'reference') as String,
      url: (json['url'] ?? '') as String,
      workflowStatus: (json['workflow_status'] ?? 'METADATA_REVIEW') as String,
      rightsStatus: (json['rights_status'] ?? 'PENDING') as String,
      publicReleaseStatus:
          (json['public_release_status'] ?? 'BLOCKED') as String,
      linkedSiteCount: (json['linked_site_count'] as num?)?.toInt() ?? 0,
      linkedClaimCount: (json['linked_claim_count'] as num?)?.toInt() ?? 0,
      updatedAt:
          DateTime.tryParse((json['updated_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String id;
  final String title;
  final String attribution;
  final String sourceType;
  final String url;
  final String workflowStatus;
  final String rightsStatus;
  final String publicReleaseStatus;
  final int linkedSiteCount;
  final int linkedClaimCount;
  final DateTime updatedAt;

  OperationalSourceRecord copyWith({
    String? workflowStatus,
    String? rightsStatus,
    String? publicReleaseStatus,
    int? linkedSiteCount,
    int? linkedClaimCount,
    DateTime? updatedAt,
  }) {
    return OperationalSourceRecord(
      id: id,
      title: title,
      attribution: attribution,
      sourceType: sourceType,
      url: url,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      rightsStatus: rightsStatus ?? this.rightsStatus,
      publicReleaseStatus: publicReleaseStatus ?? this.publicReleaseStatus,
      linkedSiteCount: linkedSiteCount ?? this.linkedSiteCount,
      linkedClaimCount: linkedClaimCount ?? this.linkedClaimCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'attribution': attribution,
    'source_type': sourceType,
    'url': url,
    'workflow_status': workflowStatus,
    'rights_status': rightsStatus,
    'public_release_status': publicReleaseStatus,
    'linked_site_count': linkedSiteCount,
    'linked_claim_count': linkedClaimCount,
    'updated_at': updatedAt.toIso8601String(),
  };
}

class OperationalClaimRecord {
  const OperationalClaimRecord({
    required this.id,
    required this.siteId,
    required this.siteNameAr,
    required this.claimText,
    required this.priorityTier,
    required this.priorityScore,
    required this.workflowStatus,
    required this.evidenceStatus,
    required this.publicationUse,
    required this.categories,
    required this.updatedAt,
  });

  factory OperationalClaimRecord.fromJson(Map<String, Object?> json) {
    return OperationalClaimRecord(
      id: json['id']! as String,
      siteId: json['site_id']! as String,
      siteNameAr: (json['site_name_ar'] ?? '') as String,
      claimText: json['claim_text']! as String,
      priorityTier: (json['priority_tier'] ?? 'P2_NORMAL') as String,
      priorityScore: (json['priority_score'] as num?)?.toInt() ?? 0,
      workflowStatus: (json['workflow_status'] ?? 'NEW') as String,
      evidenceStatus: (json['evidence_status'] ?? 'MISSING') as String,
      publicationUse: (json['publication_use'] ?? 'BLOCKED') as String,
      categories: List<String>.from(json['categories'] as List? ?? const []),
      updatedAt:
          DateTime.tryParse((json['updated_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String id;
  final String siteId;
  final String siteNameAr;
  final String claimText;
  final String priorityTier;
  final int priorityScore;
  final String workflowStatus;
  final String evidenceStatus;
  final String publicationUse;
  final List<String> categories;
  final DateTime updatedAt;

  OperationalClaimRecord copyWith({
    String? workflowStatus,
    String? evidenceStatus,
    String? publicationUse,
    DateTime? updatedAt,
  }) {
    return OperationalClaimRecord(
      id: id,
      siteId: siteId,
      siteNameAr: siteNameAr,
      claimText: claimText,
      priorityTier: priorityTier,
      priorityScore: priorityScore,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      evidenceStatus: evidenceStatus ?? this.evidenceStatus,
      publicationUse: publicationUse ?? this.publicationUse,
      categories: categories,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'site_id': siteId,
    'site_name_ar': siteNameAr,
    'claim_text': claimText,
    'priority_tier': priorityTier,
    'priority_score': priorityScore,
    'workflow_status': workflowStatus,
    'evidence_status': evidenceStatus,
    'publication_use': publicationUse,
    'categories': categories,
    'updated_at': updatedAt.toIso8601String(),
  };
}

class OperationalReviewTask {
  const OperationalReviewTask({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.title,
    required this.reviewType,
    required this.priority,
    required this.status,
    required this.assigneeLabel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OperationalReviewTask.fromJson(Map<String, Object?> json) {
    return OperationalReviewTask(
      id: json['id']! as String,
      entityType: (json['entity_type'] ?? 'site') as String,
      entityId: json['entity_id']! as String,
      title: json['title']! as String,
      reviewType: (json['review_type'] ?? 'EDITORIAL') as String,
      priority: (json['priority'] ?? 'NORMAL') as String,
      status: (json['status'] ?? 'OPEN') as String,
      assigneeLabel: (json['assignee_label'] ?? 'غير مسند') as String,
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt:
          DateTime.tryParse((json['updated_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String id;
  final String entityType;
  final String entityId;
  final String title;
  final String reviewType;
  final String priority;
  final String status;
  final String assigneeLabel;
  final DateTime createdAt;
  final DateTime updatedAt;

  OperationalReviewTask copyWith({
    String? status,
    String? assigneeLabel,
    DateTime? updatedAt,
  }) {
    return OperationalReviewTask(
      id: id,
      entityType: entityType,
      entityId: entityId,
      title: title,
      reviewType: reviewType,
      priority: priority,
      status: status ?? this.status,
      assigneeLabel: assigneeLabel ?? this.assigneeLabel,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'entity_type': entityType,
    'entity_id': entityId,
    'title': title,
    'review_type': reviewType,
    'priority': priority,
    'status': status,
    'assignee_label': assigneeLabel,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class OperationalCoordinateCandidate {
  const OperationalCoordinateCandidate({
    required this.id,
    required this.siteId,
    required this.siteNameAr,
    required this.latitude,
    required this.longitude,
    required this.sourceId,
    required this.verificationStatus,
    required this.promotionStatus,
    required this.publicMapUse,
    required this.updatedAt,
  });

  factory OperationalCoordinateCandidate.fromJson(Map<String, Object?> json) {
    return OperationalCoordinateCandidate(
      id: json['id']! as String,
      siteId: json['site_id']! as String,
      siteNameAr: (json['site_name_ar'] ?? '') as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      sourceId: (json['source_id'] ?? '') as String,
      verificationStatus: (json['verification_status'] ?? 'PENDING') as String,
      promotionStatus: (json['promotion_status'] ?? 'NOT_PROMOTED') as String,
      publicMapUse: (json['public_map_use'] ?? 'BLOCKED') as String,
      updatedAt:
          DateTime.tryParse((json['updated_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String id;
  final String siteId;
  final String siteNameAr;
  final double latitude;
  final double longitude;
  final String sourceId;
  final String verificationStatus;
  final String promotionStatus;
  final String publicMapUse;
  final DateTime updatedAt;

  OperationalCoordinateCandidate copyWith({
    String? verificationStatus,
    String? promotionStatus,
    String? publicMapUse,
    DateTime? updatedAt,
  }) {
    return OperationalCoordinateCandidate(
      id: id,
      siteId: siteId,
      siteNameAr: siteNameAr,
      latitude: latitude,
      longitude: longitude,
      sourceId: sourceId,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      promotionStatus: promotionStatus ?? this.promotionStatus,
      publicMapUse: publicMapUse ?? this.publicMapUse,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'site_id': siteId,
    'site_name_ar': siteNameAr,
    'latitude': latitude,
    'longitude': longitude,
    'source_id': sourceId,
    'verification_status': verificationStatus,
    'promotion_status': promotionStatus,
    'public_map_use': publicMapUse,
    'updated_at': updatedAt.toIso8601String(),
  };
}

class OperationalMediaAsset {
  const OperationalMediaAsset({
    required this.id,
    required this.siteId,
    required this.title,
    required this.assetType,
    required this.ownerLabel,
    required this.rightsStatus,
    required this.internalUseStatus,
    required this.publicUseStatus,
    required this.updatedAt,
  });

  factory OperationalMediaAsset.fromJson(Map<String, Object?> json) {
    return OperationalMediaAsset(
      id: json['id']! as String,
      siteId: (json['site_id'] ?? '') as String,
      title: json['title']! as String,
      assetType: (json['asset_type'] ?? 'image') as String,
      ownerLabel: (json['owner_label'] ?? 'غير محدد') as String,
      rightsStatus: (json['rights_status'] ?? 'PENDING') as String,
      internalUseStatus: (json['internal_use_status'] ?? 'BLOCKED') as String,
      publicUseStatus: (json['public_use_status'] ?? 'BLOCKED') as String,
      updatedAt:
          DateTime.tryParse((json['updated_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String id;
  final String siteId;
  final String title;
  final String assetType;
  final String ownerLabel;
  final String rightsStatus;
  final String internalUseStatus;
  final String publicUseStatus;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'site_id': siteId,
    'title': title,
    'asset_type': assetType,
    'owner_label': ownerLabel,
    'rights_status': rightsStatus,
    'internal_use_status': internalUseStatus,
    'public_use_status': publicUseStatus,
    'updated_at': updatedAt.toIso8601String(),
  };
}

class OperationalReleaseCandidate {
  const OperationalReleaseCandidate({
    required this.id,
    required this.title,
    required this.status,
    required this.siteIds,
    required this.gates,
    required this.createdAt,
    required this.createdBy,
  });

  factory OperationalReleaseCandidate.fromJson(Map<String, Object?> json) {
    return OperationalReleaseCandidate(
      id: json['id']! as String,
      title: json['title']! as String,
      status: (json['status'] ?? 'CANDIDATE') as String,
      siteIds: List<String>.from(json['site_ids'] as List? ?? const []),
      gates: Map<String, bool>.from(
        (json['gates'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value == true),
            ) ??
            const <String, bool>{},
      ),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      createdBy: (json['created_by_label'] ?? 'غير محدد') as String,
    );
  }

  final String id;
  final String title;
  final String status;
  final List<String> siteIds;
  final Map<String, bool> gates;
  final DateTime createdAt;
  final String createdBy;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'status': status,
    'site_ids': siteIds,
    'gates': gates,
    'created_at': createdAt.toIso8601String(),
    'created_by_label': createdBy,
  };
}

class OperationalAuditEvent {
  const OperationalAuditEvent({
    required this.id,
    required this.actorLabel,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.summary,
    required this.metadata,
    required this.createdAt,
  });

  factory OperationalAuditEvent.fromJson(Map<String, Object?> json) {
    return OperationalAuditEvent(
      id: json['id']! as String,
      actorLabel: (json['actor_label'] ?? 'غير محدد') as String,
      action: json['action']! as String,
      entityType: json['entity_type']! as String,
      entityId: json['entity_id']! as String,
      summary: (json['summary'] ?? '') as String,
      metadata: Map<String, Object?>.from(
        json['metadata'] as Map? ?? const <String, Object?>{},
      ),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String id;
  final String actorLabel;
  final String action;
  final String entityType;
  final String entityId;
  final String summary;
  final Map<String, Object?> metadata;
  final DateTime createdAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'actor_label': actorLabel,
    'action': action,
    'entity_type': entityType,
    'entity_id': entityId,
    'summary': summary,
    'metadata': metadata,
    'created_at': createdAt.toIso8601String(),
  };
}

class OperationalSnapshot {
  const OperationalSnapshot({
    required this.backendMode,
    required this.sites,
    required this.sources,
    required this.claims,
    required this.reviewTasks,
    required this.coordinateCandidates,
    required this.mediaAssets,
    required this.releaseCandidates,
    required this.auditEvents,
    required this.loadedAt,
  });

  final OperationalBackendMode backendMode;
  final List<OperationalSiteRecord> sites;
  final List<OperationalSourceRecord> sources;
  final List<OperationalClaimRecord> claims;
  final List<OperationalReviewTask> reviewTasks;
  final List<OperationalCoordinateCandidate> coordinateCandidates;
  final List<OperationalMediaAsset> mediaAssets;
  final List<OperationalReleaseCandidate> releaseCandidates;
  final List<OperationalAuditEvent> auditEvents;
  final DateTime loadedAt;

  int get openReviewCount => reviewTasks
      .where((task) => task.status == 'OPEN' || task.status == 'IN_REVIEW')
      .length;

  int get missingSourceMetadataCount =>
      sources.where((source) => source.workflowStatus != 'VERIFIED').length;

  int get coordinateGapCount =>
      sites.where((site) => !site.publicCoordinatesApproved).length;

  int get pendingRightsCount =>
      mediaAssets.where((asset) => asset.publicUseStatus != 'APPROVED').length;

  OperationalSnapshot copyWith({
    OperationalBackendMode? backendMode,
    List<OperationalSiteRecord>? sites,
    List<OperationalSourceRecord>? sources,
    List<OperationalClaimRecord>? claims,
    List<OperationalReviewTask>? reviewTasks,
    List<OperationalCoordinateCandidate>? coordinateCandidates,
    List<OperationalMediaAsset>? mediaAssets,
    List<OperationalReleaseCandidate>? releaseCandidates,
    List<OperationalAuditEvent>? auditEvents,
    DateTime? loadedAt,
  }) {
    return OperationalSnapshot(
      backendMode: backendMode ?? this.backendMode,
      sites: sites ?? this.sites,
      sources: sources ?? this.sources,
      claims: claims ?? this.claims,
      reviewTasks: reviewTasks ?? this.reviewTasks,
      coordinateCandidates: coordinateCandidates ?? this.coordinateCandidates,
      mediaAssets: mediaAssets ?? this.mediaAssets,
      releaseCandidates: releaseCandidates ?? this.releaseCandidates,
      auditEvents: auditEvents ?? this.auditEvents,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }

  String toCompactJson() => jsonEncode(<String, Object?>{
    'backend_mode': backendMode.name,
    'counts': <String, int>{
      'sites': sites.length,
      'sources': sources.length,
      'claims': claims.length,
      'review_tasks': reviewTasks.length,
      'coordinate_candidates': coordinateCandidates.length,
      'media_assets': mediaAssets.length,
      'release_candidates': releaseCandidates.length,
      'audit_events': auditEvents.length,
    },
    'loaded_at': loadedAt.toIso8601String(),
  });
}
