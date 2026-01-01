# Custom Icons Folder

This folder contains custom icon images for the app categories.

## Icon Naming Convention

Icons should be named using lowercase category names with underscores:
- `plumber.png*`
- `carpenter.png*`
- `welder.png*`
- `contractor.png*`
- `electrician.png*`
- `painter.png*`
- `laundry.png*`
- `mechanic.png*`
- `cleaner.png`

## Supported Formats

- PNG (recommended)
- SVG (if supported)
- JPG/JPEG

## Icon Specifications

- Recommended size: 512x512 pixels (or higher for @2x, @3x)
- Format: PNG with transparency
- Color: Icons will be colored by the app, so grayscale or colored icons work
- Background: Transparent

## How It Works

1. Add your icon files to this folder with the naming convention above
2. The app will automatically use custom icons if they exist
3. If a custom icon is not found, the app will fall back to Material Icons
4. Icons are automatically colored based on the category color scheme

## Adding New Icons

To add icons for new categories:
1. Add the icon file to this folder
2. Update `lib/app/utils/icon_helper.dart` to include the new category mapping

