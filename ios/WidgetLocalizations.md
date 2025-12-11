# Widget Localization Setup

The widget needs localized strings for the widget name and description in the widget gallery.

## Required Localization Files

### English (en)
Create: `ios/VerseWidget/en.lproj/Localizable.strings`

```strings
/* Verse of the Day widget title */
"verseOfTheDay" = "Verse of the Day";

/* Widget description in widget gallery */
"widgetDescription" = "Daily inspirational Bible verse on your home screen.";
```

### Spanish (es)
Create: `ios/VerseWidget/es.lproj/Localizable.strings`

```strings
/* Versículo del Día widget title */
"verseOfTheDay" = "Versículo del Día";

/* Widget description in widget gallery */
"widgetDescription" = "Versículo bíblico inspirador diario en tu pantalla de inicio.";
```

## How to Add in Xcode

### Step 1: Add English Localization

1. In Xcode, **right-click** on `VerseWidget` folder
2. Select **New File...**
3. Choose **Strings File**
4. Name it: `Localizable.strings`
5. Click **Create**
6. In File Inspector (right panel), click **Localize...**
7. Select **English**, click **Localize**

### Step 2: Add Spanish Localization

1. Select `Localizable.strings` file
2. In File Inspector, under **Localization**, click **+**
3. Select **Spanish (es)**, click **Finish**

### Step 3: Add Content

#### English (en):
```strings
"verseOfTheDay" = "Verse of the Day";
"widgetDescription" = "Daily inspirational Bible verse on your home screen.";
```

#### Spanish (es):
```strings
"verseOfTheDay" = "Versículo del Día";
"widgetDescription" = "Versículo bíblico inspirador diario en tu pantalla de inicio.";
```

## Verification

After adding localizations:

1. **Build** the widget extension (⌘B)
2. Change **simulator language** to Spanish:
   - Settings → General → Language & Region → iPhone Language → Español
3. **Restart** simulator
4. Widget gallery should show:
   - English: "Verse of the Day"
   - Spanish: "Versículo del Día"

## File Structure

```
ios/
└── VerseWidget/
    ├── VerseWidget.swift
    ├── Assets.xcassets/
    ├── Info.plist
    ├── en.lproj/
    │   └── Localizable.strings (English)
    └── es.lproj/
        └── Localizable.strings (Spanish)
```

## Translation Badge

The widget automatically shows the correct translation badge:
- **English users**: "WEB" badge
- **Spanish users**: "RVR1909" badge

This is determined by the Flutter app based on user's language preference and passed via App Groups UserDefaults.
