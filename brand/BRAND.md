# Leopard AI — Brand Guidelines

Version: 0.1.0 · Ticket: SF-23 · Parent: SF-22

## Identity

- **Company:** Leopard AI
- **Flagship product:** SonicFlow
- **Positioning:** Chakra-tuned audio layers that match the user's intended mind state — focus, flow, meditation, sleep.

The brand is dark, warm, and quietly premium. Leopard pattern is a texture, never a character. Chakra colors carry meaning (mode semantics); gold carries identity.

## Source of truth

All tokens live in `brand/tokens.json`. Everything else (CSS variables and Swift structs) is **generated** from that file — see `brand/generated/README.md`. No hex literal should appear outside of `brand/` after SF-24…SF-28 land.

If a new color is needed, add it to `tokens.json` first, regenerate, then use the generated token. Direct hex usage is reviewable as a blocker.

## Chakra palette

Seven tokens, four currently load-bearing as mode accents:

| Token      | Chakra              | Hex       | Used for                          |
|------------|---------------------|-----------|-----------------------------------|
| `root`     | Muladhara           | `#C73D3D` | Warnings, deep-bass visualization |
| `sacral`   | Svadhisthana        | `#E67E22` | Secondary brand surfaces          |
| `solar`    | Manipura            | `#F5C518` | Highlights, premium markers       |
| `heart`    | Anahata             | `#1D9E75` | **Meditation** mode               |
| `throat`   | Vishuddha           | `#378ADD` | **Focus** mode                    |
| `thirdEye` | Ajna                | `#7F77DD` | **Flow** mode                     |
| `crown`    | Sahasrara           | `#534AB7` | **Sleep** mode                    |

Rationale: the existing four shipped mode colors map cleanly to throat, third-eye, heart, and crown — the four chakras most associated with cognitive and rest bands. We keep them unchanged to avoid visual regression, and expose the remaining three for brand / non-mode surfaces.

## Mode ↔ chakra mapping

| Mode       | Beat | Band  | Chakra    | Color     |
|------------|------|-------|-----------|-----------|
| Focus      | 40Hz | gamma | throat    | `#378ADD` |
| Flow       | 10Hz | alpha | thirdEye  | `#7F77DD` |
| Meditation |  6Hz | theta | heart     | `#1D9E75` |
| Sleep      |  2Hz | delta | crown     | `#534AB7` |

## Accent

- `gold` `#D4A24C` — primary brand accent (logo, leopard spot highlights).
- `spotRing` `#6B4B1F` — leopard spot ring, darker accent.
- `success` `#3CCF91` — active/playing state only.
- `danger` `#E0484D` — stop/error state only.

## Neutral surfaces

Dark first. Light mode is out of scope for the Leopard Look — the brand's identity requires the warm-on-dark contrast.

| Token  | Value                           | Use                             |
|--------|---------------------------------|---------------------------------|
| `ink`  | `#0A0A0B`                       | deepest surface, pattern base   |
| `bg`   | `#0F0F12`                       | app canvas                      |
| `panel`| `rgba(18, 18, 22, 0.78)`        | blurred surface behind content  |
| `border`| `#2A2434`                      | panel/card borders              |
| `fg`   | `#F5F7FB`                       | primary text                    |
| `muted`| `#8E97A8`                       | secondary text                  |

## Typography

- **Display:** SF Pro Display / Inter → system fallback.
- **Body:** system stack (`-apple-system`, `Inter`, `Segoe UI`).
- **Mono:** JetBrains Mono → ui-monospace.

Scale: `caption 11pt`, `body 14pt`, `title 17pt`, `display 24pt`. Tracking is slightly negative at display sizes.

## Leopard pattern

The Leopard Look is built on a procedural leopard-print layer behind a blurred panel. Until SF-29 ships real photographic/illustrative assets, every platform uses a generated pattern with:

- Base: `ink` (#0A0A0B)
- Spot: `gold` (#D4A24C) with ~14% opacity
- Ring: `spotRing` (#6B4B1F)
- 2–4px blur on the pattern layer

**Rules:**

1. Pattern ALWAYS sits behind a blurred panel — never directly under body text.
2. Opacity stays between 10–18%; never above 25%.
3. No motion on the pattern (the user is listening, the eye is resting).
4. The pattern must be obviously a texture at glance distance — not readable as a photograph.

## Logo

- Clearspace: equal to the cap height of the mark on all sides.
- Minimum width: 24px (menu-bar icon), 16px (favicon).
- On dark: gold `#D4A24C`; subtle glow allowed on hero surfaces only.
- On light: ink `#0A0A0B`. Never gold on a light surface.

The SF-22 icon upload has a cropping issue ("der muss immer abgeschnitten werden") — SF-29 re-exports with added safe-area padding before slicing to platform sizes.

## Glow

Active mode cards glow with their chakra color:

```
shadow = 0 0 24px modeColor + 0 0 64px (modeColor @ 30% alpha)
```

On native platforms this compiles to layered shadows or blur effects. See `brand/generated/*` for the per-platform translation.

## Do / Don't

**Do**

- Use mode color only for that mode's surfaces (don't paint the Focus button in Heart green).
- Let the leopard pattern be quiet.
- Keep gold for identity, not for states.

**Don't**

- Don't mix chakra colors on a single card.
- Don't place gold on a light background.
- Don't animate the leopard pattern.
- Don't introduce a hex literal outside `brand/tokens.json`.
