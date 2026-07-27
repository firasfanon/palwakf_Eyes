# PAL_EYES_VISUAL_CARD_COMPACT_HEIGHT_OVERFLOW_HOTFIX_V1

Three compact `PalEyesVisualCard` instances overflowed vertically by
4px at an effective content height of 199px.

The shared component now measures its height, bounds the description
through Expanded space, limits compact text lines, and preserves the
footer. A focused 362x243 widget regression test was added.

```text
VISUAL_DESIGN_DIRECTION=UNCHANGED
CONTENT_DATA=UNCHANGED
DATABASE_MUTATION=NONE
```
