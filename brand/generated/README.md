# brand/generated

These files are **generated from `brand/tokens.json`** by `scripts/brand/generate-tokens.mjs`.

Do not hand-edit. Edit `tokens.json`, then run:

```bash
node scripts/brand/generate-tokens.mjs
```

Generated outputs:

- `tokens.css` — CSS custom properties, consumed by Chrome + Safari extensions.
- `BrandTokens.swift` — Swift struct with `Color` fields, consumed by iOS + macOS + Safari macOS app.
- `BrandTokens.kt` — Kotlin object with `Color.fromHex` fields, consumed by Android Compose theme.

The generator is deterministic — running it twice on the same input produces byte-identical output.

CI runs the generator and diffs the result against checked-in files. A non-empty diff fails the build (SF-24 introduces this check).
