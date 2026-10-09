# Bundled font provenance

| Family | Files | License | Upstream |
|---|---|---|---|
| IBM Plex Sans Arabic | Regular, Medium, SemiBold, Bold (.ttf) | SIL Open Font License 1.1 (`ibm_plex_sans_arabic/OFL.txt`) | github.com/google/fonts `ofl/ibmplexsansarabic` @ 2eb0b48d5f760f62e286216f0859a8c540dbc1bd |
| Amiri | Regular, Bold (.ttf) | SIL Open Font License 1.1 (`amiri/OFL.txt`) | github.com/google/fonts `ofl/amiri` @ 2eb0b48d5f760f62e286216f0859a8c540dbc1bd |

SHA-256

```
691e0c891a38637ae6bbdb69700f8042cb0724a137bee615068ffdb92244f61f  ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf
b8363ab9f733dfa4f8e96b8b2102c24b5cf4110fb96d1d3d9a9412f6fb49cf74  ibm_plex_sans_arabic/IBMPlexSansArabic-Medium.ttf
6f611412270a132bbac838da9259d4c68569b4175f3b3b8fa3fa36a30b56dab9  ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf
597bd5502e5997be4414e4c9c88834b30ff3784250c84f20bce2b20e53ebd467  ibm_plex_sans_arabic/IBMPlexSansArabic-SemiBold.ttf
cfccb794268e7d573d857e6d6a67f89cf8a053e8ffd85dfa0c8ec1bb36fc4827  amiri/Amiri-Bold.ttf
ab391c4147d054c48976e98322ad0eefe1427aa0e0502a12a4c75d80a70cfcd7  amiri/Amiri-Regular.ttf
```

Reason: Flutter web otherwise resolves Arabic glyphs through runtime downloads
from fonts.gstatic.com (Roboto + Noto Sans Arabic). On restricted or offline
networks those downloads fail and Arabic text renders as tofu or not at all.
