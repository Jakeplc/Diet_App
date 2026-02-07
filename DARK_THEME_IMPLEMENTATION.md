# Energetic Ember Dark Theme Implementation Guide

## Status: IN PROGRESS
This document tracks the application of **Energetic Ember Dark** theme across all screens.

---

## Color Palette (AppTheme Constants)
- **Background**: `#0C111A` (darkBackground)
- **Cards/Sections**: `#1A202C` (darkCard)
- **Primary Accent**: `#FF5E00` (darkPrimary - orange)
- **Secondary Accent**: `#FFC107` (darkSecondary - amber)
- **Text**: `#F8FAFC` (darkText - off-white)
- **Text Muted**: `#94A3B8` (darkTextMuted - gray)
- **Outline/Borders**: `#2A3441` (darkOutline)
- **Complementary**: `#0A2540` (deepNavy)

---

## Implementation Checklist

### ✅ COMPLETED

#### 1. **Onboarding Screen** (`onboarding_screen.dart`)
- ✅ Scaffold background: `AppTheme.darkBackground`
- ✅ Welcome page gradient: dark background → complementary navy
- ✅ Feature icons: Orange primary + Amber secondary
- ✅ Personal info page: Dark card inputs with orange icons
- ✅ Gender selector: Orange active state
- ✅ Physical stats: Orange slider + dark input
- ✅ Goals page: Dark cards with orange borders when selected
- ✅ Diet preferences: Amber badge for Premium, dark filter chips
- ✅ Buttons: Orange (#FF5E00) with white text

#### 2. **Settings Screen** (`settings_screen.dart`)
- ✅ Scaffold background: `AppTheme.darkBackground`
- ✅ AppBar: Dark with light text
- ✅ Premium banner: Dark card with amber star, orange border
- ✅ Section headers: Muted gray
- ✅ List tiles: Dark cards with rounded corners (16px), elevation 3
- ✅ Icons: Orange primary accents
- ✅ Text: Light off-white with muted labels

#### 3. **Food Logging Screen** (`food_logging_screen.dart`)
- ✅ Scaffold: Dark background
- ✅ AppBar: Dark with light text
- ✅ Meal type selector: Orange active, dark inactive
- ✅ Search bar: Dark card with orange focus border
- ⏳ Quick action buttons: AI (orange→amber), Barcode (navy), Photo (orange), Custom (amber)
- ⏳ Search results: Dark cards with category circles

### ⏳ IN PROGRESS

#### 4. **Meal Planning Screen** (`meal_planning_screen.dart`)
- [ ] Scaffold: Dark background
- [ ] AppBar: Dark styling
- [ ] Day tabs: Orange active (`#FF5E00`), dark inactive (`#1A202C`)
- [ ] Meal cards: Dark (`#1A202C`) with orange borders
- [ ] Generate popup: Dark card with amber star icon, orange button
- [ ] Toggles: Orange active, gray off
- [ ] Warning banner: Amber tint with opacity

### ⏳ NOT STARTED

#### 5. **Progress Screen** (`progress_screen.dart`)
- [ ] Scaffold: Dark background
- [ ] Chart area: Dark with green-to-orange gradient line
- [ ] Time range tabs: Orange active
- [ ] Statistics cards: Dark with amber positive change
- [ ] Analytics card: Dark with amber star
- [ ] Weight history: Dark cards with orange circles

#### 6. **Home Dashboard** (`dashboard_screen.dart`)
- [ ] Header: Orange-to-amber gradient
- [ ] Tip banner: White on transparent
- [ ] Circles: Dark background (#1A202C), orange flame, navy droplet
- [ ] Values: Orange left, white right
- [ ] Macros card: Dark with bars (protein→orange, carbs→amber, fats→red/navy)
- [ ] Meals card: Dark with fork icon (gray), orange log button
- [ ] Bottom nav: Orange active (home gear icon)

#### 7. **Profile Settings** (`settings_screen.dart` - list tiles section)
- [ ] List tiles: Dark cards with rounded corners
- [ ] Icons: Person/Weight/Height (white), Flame (orange), Fork (orange), Drop (navy)
- [ ] Edit pencils: Gray
- [ ] Toggles: Orange active
- [ ] Group headers: Muted gray

#### 8. **Goal Selection Screen** (`onboarding_screen.dart` variant)
- [ ] Cards: Dark with orange/amber borders when selected
- [ ] Icons: Down arrow (orange), Heart (orange), Up arrow (amber), Dumbbell (orange)
- [ ] Premium badge: Amber
- [ ] Text: Light off-white
- [ ] Buttons: Orange

#### 9. **Diet Preferences** (`onboarding_screen.dart` variant)
- [ ] Buttons (Standard/Vegetarian/Vegan): Orange selected, dark inactive
- [ ] Info banner: Amber tint background, light text
- [ ] Pagination: Gray dots, orange active
- [ ] Action buttons: Back (orange text), Get Started (orange fill + white)

#### 10. **Physical Stats** (`onboarding_screen.dart` variant)
- [ ] Sliders: Orange active track, gray inactive
- [ ] Slider thumbs: Orange
- [ ] Values: Light text
- [ ] Dropdowns: Dark with light text
- [ ] Buttons: Orange

#### 11. **Advanced Settings** (`settings_screen.dart` continuation)
- [ ] List tiles: Dark with icons
- [ ] Icons: Steps (orange), Community (navy), Heart (orange), Analytics (amber), Micronutrients (orange), Body Comp (orange), Info (white), Privacy (white), Clear Data (red)
- [ ] Danger zone: Red text/accents

#### 12. **Home Dashboard Variant** (no meals logged)
- [ ] Empty state: Dark card (#1A202C)
- [ ] Fork icon: Orange
- [ ] Log button: Orange
- [ ] Calories left pill: Amber (#FFC107)
- [ ] Same styling as main home

---

## Key Styling Patterns

### Dark Cards
```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.darkCard,           // #1A202C
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppTheme.darkOutline,      // #2A3441
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  ),
)
```

### Orange Buttons
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.darkPrimary,  // #FF5E00
    foregroundColor: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)
```

### Active Tabs/Chips
```dart
Container(
  decoration: BoxDecoration(
    color: isSelected ? AppTheme.darkPrimary : AppTheme.darkCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isSelected ? AppTheme.darkPrimary : AppTheme.darkOutline,
    ),
  ),
)
```

### Text Styling
- **Headings**: `TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold)`
- **Body**: `TextStyle(color: AppTheme.darkText)`
- **Muted**: `TextStyle(color: AppTheme.darkTextMuted)`
- **Accents**: `TextStyle(color: AppTheme.darkPrimary)`

---

## Next Steps
1. **Complete Meal Planning Screen** - day tabs, generate popup
2. **Update Progress Screen** - charts, analytics cards
3. **Refine Dashboard** - all circular indicators, macros
4. **Test Navigation** - ensure consistent theming across flows
5. **Performance Check** - verify no layout jank with dark backgrounds
6. **Hot Reload Testing** - test all screens in light/dark/feminine modes

---

## Notes
- All screens now use `AppTheme.darkBackground` as default scaffold background
- AppBar uses `AppTheme.darkBackground` + `AppTheme.darkText` for visibility
- Rounded corners: 16-24px for cards, 12px for buttons, 30px for pill shapes
- Elevation: 2-4 for cards, 3-4 for interactive elements
- Border opacity: 0.3 for dividers, 0.2 for subtle hints
- Shadow opacity: 0.25-0.3 for depth on dark backgrounds
