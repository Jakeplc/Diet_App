# Animation Guidelines (Diet App)

These recommendations tailor your animation best practices to the current app’s screens and components. Use this as a single source of truth for consistent motion design.

## Global Motion Defaults
- Duration: 200–400ms for most UI transitions.
- Curves: `Curves.easeInOut` for layout changes, `Curves.easeOut` for entrances.
- Respect reduced motion: if `MediaQuery.of(context).disableAnimations` is true, simplify or skip motion.
- Prefer GPU‑friendly transforms (scale/translate/rotate) over layout changes (width/height/top/left).

## Dashboard (home)
**Targets:** calorie ring, water ring, macros cards, bottom nav selection.
- Use `AnimatedSwitcher` for the daily summary header (date/goal changes).
- Wrap rings in `RepaintBoundary` and animate progress with `TweenAnimationBuilder<double>`.
- Bottom nav: use `AnimatedScale` or `AnimatedOpacity` on the active icon only.

## Onboarding
**Targets:** page transitions, CTA buttons, cards.
- Use `AnimatedSwitcher` for step content; keep durations ~300ms.
- Use `Hero` for any shared imagery (e.g., meal photo or avatar) between onboarding and dashboard.
- Use `AnimatedOpacity` for helper text and validation feedback.

## Meal Planning
**Targets:** day tabs, meal cards, “Generate Plan” panel.
- Use `AnimatedContainer` for active tab background/underline.
- For adding/removing meals, use `AnimatedSwitcher` with a slide+fade transition.
- If a list is long, use `TickerMode` to pause offscreen item animations.

## Food Logging
**Targets:** search bar, recent items, popular foods list.
- Use `AnimatedContainer` to expand the search field when focused.
- Use `AnimatedOpacity` to show/hide filters.
- Use `AnimatedSwitcher` to swap “empty state” vs. results.

## Progress / Analytics
**Targets:** charts, stat tiles, filters.
- Use `TweenAnimationBuilder` for chart reveal (line opacity + scale).
- Animate stat tiles with `AnimatedScale` on first load only.
- Avoid animating heavy charts on every rebuild; trigger once per tab entry.

## Settings
**Targets:** toggles, theme selection, sections.
- Use `AnimatedContainer` on selection chips.
- Use `AnimatedSwitcher` for showing advanced options.
- Avoid global `Opacity` on large sections; prefer `AnimatedOpacity` on the exact widgets.

## Performance Checklist
- Use `RepaintBoundary` on animated rings and charts.
- Prefer `AnimatedOpacity` or `FadeTransition` over `Opacity`.
- Wrap only the animated subtree in `AnimatedBuilder`.
- Keep `const` constructors and avoid `setState` on every tick.
- Profile in **profile mode** and check DevTools for jank or shader compilation.

## Optional Enhancements
- Use `flutter_animate` for declarative chains on simple elements.
- Add a “warm‑up” animation on app start for chart shaders.
- For advanced physics, consider `SpringSimulation` or `flutter_physics`.

---
If you want, I can implement a starter set of these animations on the dashboard and onboarding screens next.