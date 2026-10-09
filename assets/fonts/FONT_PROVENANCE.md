# Font provenance

All fonts come from github.com/google/fonts at commit
2eb0b48d5f760f62e286216f0859a8c540dbc1bd, under the SIL Open Font License 1.1
(license text shipped next to each family). Subsets are produced
reproducibly by `tools/fonts/build_font_subsets.py`.

| Family | Shipped as | Modification | Why |
|---|---|---|---|
| IBM Plex Sans Arabic | `assets/fonts/ibm_plex_sans_arabic/*.ttf` (400/500/600/700) | **None** — the license reserves the name "Plex", so the files are byte-identical to upstream | Body text |
| Amiri | `assets/fonts/amiri/Amiri-{Regular,Bold}.ttf` | Subset to Arabic + Latin + punctuation | Display headings |
| Roboto | `web/fonts/fallback/roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2` | Pinned to wght 400 / wdth 100, Latin subset (TrueType bytes; the engine parses content, not the extension) | Flutter engine default fallback |
| Noto Sans Arabic | `web/fonts/fallback/notosansarabic/v28/nwpxtLGrOAZMl5nJ_wfgRg3DrWFZWsnVBJ_sS6tlqHHFlhQ5l3sQWIHPqzCfyGyvvnCBFQLaig.woff2` | Pinned to wght 400 / wdth 100, Arabic subset | Engine fallback for text outside the theme font |

`web/flutter_bootstrap.js` sets `fontFallbackBaseUrl: "/fonts/fallback/"`, so
the web build makes **no** request to fonts.gstatic.com. The browser E2E
network-policy check fails the build if one appears, and it also fails on any
same-origin 404 (a missing local fallback).

SHA-256

```
691e0c891a38637ae6bbdb69700f8042cb0724a137bee615068ffdb92244f61f  ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf
b8363ab9f733dfa4f8e96b8b2102c24b5cf4110fb96d1d3d9a9412f6fb49cf74  ibm_plex_sans_arabic/IBMPlexSansArabic-Medium.ttf
6f611412270a132bbac838da9259d4c68569b4175f3b3b8fa3fa36a30b56dab9  ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf
597bd5502e5997be4414e4c9c88834b30ff3784250c84f20bce2b20e53ebd467  ibm_plex_sans_arabic/IBMPlexSansArabic-SemiBold.ttf
e220fc67141c27d43c7532a3b03666382f5364a0fa0b109c32f7ad7631f652f9  amiri/Amiri-Regular.ttf (subset)
9fe2207e7366a0e0907ab38cdeb3d02966b976625d9fc52a7837bcd71014ba1c  amiri/Amiri-Bold.ttf (subset)
4272763c7a01db4bd9cfc4b81536f40b52e6983173772e2c011d3ee43f1349c8  web/fonts/fallback/roboto/... (subset)
1aafe78978a2b104dee3e3b5c75f66c57e5fc06e8a3cc4b7c1c3da99ca51a718  web/fonts/fallback/notosansarabic/... (subset)
```
