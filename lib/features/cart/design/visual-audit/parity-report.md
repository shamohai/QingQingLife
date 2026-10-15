# Cart Parity Report

## Reference

- Lanhu page: `image_id=093b1383-e2f5-4f5a-ae03-37cba8e9ce4e`
- Canonical width: 440 logical pixels
- Verification build: Flutter Web at `/cart`

## Audit Pack

- `output/cart-440-final-initial.png`
- `output/cart-440-final-scrolled.png`
- `output/cart-440-final-metrics.json`
- `output/cart-390-final-initial.png`
- `output/cart-390-final-scrolled.png`
- `output/cart-390-final-metrics.json`

Both runs reported `documentScrollWidth == innerWidth`, so neither viewport has horizontal overflow. The 390px first-screen repair also removed the initial one-pixel cart-row overflow.

## Result

Approximate parity: Level D.

- Structure: fixed SafeArea-aware header, single cart panel, recommendation heading, two-column grid, fixed purchase bar.
- Proportion: canonical 440px panel and grid margins follow the design; 390px uses constrained image and button widths.
- Assets: exact supplied product bitmaps are embedded inside the cart feature to avoid CanvasKit cross-origin failures.
- Interaction: item selection, select-all, quantity, management deletion, address selection, recommendation add and checkout preview use local state.

## Accepted Deviations

- Flutter SafeArea replaces the simulated iOS status bar and home indicator.
- Source item totals conflict with the displayed total. The implementation calculates CNY 3,160 payable from four CNY 800 items and a CNY 10 per-unit local promotion, instead of hardcoding CNY 3,600.
- The 10px specification tags are slightly enlarged for readable touch-device rendering.
- Material icons replace three tiny source icons while preserving their meaning and relative weight.
