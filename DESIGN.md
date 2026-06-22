# Design Brief

**Aesthetic**: Brutalist minimalism + premium tech. Dark-first chess-like discipline. Zero decoration, pure function elevated through craft.

**Tone**: Intentional restraint. Strategic focus. Every pixel serves gameplay clarity.

## Palette

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| Background | 0.98 0 0 (off-white) | 0.145 0 0 (charcoal) | Base surface, dark-first default |
| Foreground | 0.1 0 0 (near-black) | 0.92 0 0 (off-white) | Text, primary content |
| Card | 0.96 0 0 | 0.19 0 0 | Board cells, elevated surfaces |
| Accent | 0.6 0.15 262 (cool blue) | 0.68 0.18 262 (bright blue) | Active board highlight, playable state, win pulse |
| Border | 0.88 0 0 | 0.26 0 0 | Subtle cell dividers, structure |
| Muted | 0.9 0 0 | 0.22 0 0 | Disabled, neutral, drawn boards |

## Typography

| Use | Font | Weight | Size | Tracking |
|-----|------|--------|------|----------|
| Display | General Sans (geometric, modern) | 600–700 | 24–32px | -0.01em |
| Body | Figtree (neutral, legible) | 400–500 | 14–16px | 0 |
| Mono | Geist Mono (technical) | 400–500 | 12–14px | 0 |

## Structural Zones

| Zone | Background | Border | Elevation | Usage |
|------|------------|--------|-----------|-------|
| Header | `bg-card` | `border-b border-border` | Subtle | Player turn, mode toggle (local/AI) |
| Board Container | `bg-background` | None | Base | Full-bleed game board |
| Game Board | `bg-card` | `border border-border` | Elevated | 3×3 macro-grid; cards contain 3×3 mini-boards |
| Mini Cells | `bg-card` | Inline dividers | Flat | Playable cells within mini-boards |
| Score Overlay | `bg-card/80 backdrop-blur-sm` | `border border-border` | Floating | Score, captures, game state |
| Footer | None (responsive) | None | Base | Mobile responsive hint (if needed) |

## Spacing & Rhythm

- **Grid base**: 4px (multiples: 4, 8, 12, 16, 24, 32)
- **Board gap**: 12px between macro-cells (visual separation without overload)
- **Mini-cell gap**: 2px internal dividers (subtle structure)
- **Padding**: Cards 16px, dense zones 12px, micro-interactions 4–8px
- **Density**: Compact, no wasted space; rhythm via alignment, not white space

## Component Patterns

**Game Board**: 3×3 macro-grid, each cell is a 3×3 mini-board. Macro-cells render as elevated cards with clear ownership marker (X/O or empty). Mini-cells are interactive, showing hover state (scale, opacity shift) on playable zones.

**Cell Selection**: On hover/focus over playable cell: scale 1.05, shadow lift, accent glow (optional). 12ms transition via `transition-cell`.

**Win State**: Winning mini-board or macro-cell: pulse-accent animation (1.5s) with subtle box-shadow expansion in accent color.

**Active Board Highlight**: When user must play in a specific mini-board, that board receives `ring ring-accent` and light `bg-accent/5` wash.

**Disabled/Drawn**: Completed drawn boards render at lower opacity (0.7) with `bg-muted`. No interaction allowed.

## Motion & Animation

| Effect | Duration | Easing | Trigger | Rule |
|--------|----------|--------|---------|------|
| Cell select | 120ms | `cubic-bezier(0.4, 0, 0.2, 1)` | Hover playable cell | `animate-cell-select` or `transition-cell` |
| Smooth transition | 300ms | cubic-bezier(0.4, 0, 0.2, 1) | Color/layout changes | `.transition-smooth` utility |
| Win pulse | 1500ms infinite | ease-in-out | Win detected | `animate-pulse-accent` on winning cell |
| Fast feedback | 150ms | cubic-bezier(0.4, 0, 0.2, 1) | Quick interactions | `.transition-fast` utility |
| **Reduced Motion** | Instant | none | User prefers-reduced-motion | All animations disabled, immediate state change |

## Constraints & Patterns

- **Contrast**: Dark mode foreground on dark card ≥0.5 L difference for legibility. Accent rings visible on dark background via saturation lift.
- **Responsive**: Mobile-first. Board scales to viewport. Portrait: full width minus 16px padding. Landscape: flexible grid or side-by-side layout if space permits.
- **Touch targets**: Minimum 44×44px for playable cells on mobile.
- **Accessibility**: All interactive elements keyboard-navigable. Focus rings use accent color. Motion respects `prefers-reduced-motion`.
- **Performance**: CSS transitions only (no JS animations except state choreography). Hardware acceleration via `transform` and `opacity`.

## Signature Detail

**Accent as strategic signal**: The cool blue accent (262° hue) lights up only when a board is playable or claimed. This creates a visual language where the game "tells" the player where to look next — a quiet guide rather than loud instruction. On win, the pulse-accent animation gives celebratory feedback without distraction. The dark neutral background makes the accent punch through without harshness.

## Mode Support

**Dark mode**: Primary. Light mode available but not emphasized. Toggle via class `dark` on `<html>`. Default: system preference detection.

