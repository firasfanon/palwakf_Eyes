# PAL_EYES governed research normalization

This offline-only utility converts the canonical 79-site and 79-source seed files into an **unpublished review graph**:
47 narratives, their sections and paragraphs, 79 draft research-package references, and source–site mention links.

Run (from the repository root):

```powershell
python tools/research_normalization/test_normalize.py
python tools/research_normalization/normalize.py --out "<authorized local runtime cache>/normalized_review_only.json"
```

The output is **not** publication data and must not be deployed to the anonymous public site or committed as bulk research text. Its links are explicitly `UNVERIFIED_SOURCE_MENTION` with `PENDING_HUMAN_REVIEW` status, not proof of historical attribution. Sources lacking a site slug are recorded under `sources_pending_site_linkage`, with no invented assignments. Each narrative retains the canonical source Git blob and source path. Fingerprints of the exact two input files appear in the output. All publication controls remain blocked.

This tool does not connect to Supabase, change shared schema, apply SQL migrations, alter release gates, or complete live acceptance. Its counts describe the current seed snapshot only, not verified research or staging database state. Any future database insertion requires a separate approved migration/ingestion decision and a transactionally auditable readback.
