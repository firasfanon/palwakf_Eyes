{{flutter_js}}
{{flutter_build_config}}

// Fallback glyph fonts are served from this origin (web/fonts/fallback/),
// never from fonts.gstatic.com. See assets/fonts/FONT_PROVENANCE.md.
_flutter.loader.load({
  config: {
    fontFallbackBaseUrl: "/fonts/fallback/",
  },
});
