# Testklockan - Garmin Connect IQ Watchface

## Project Overview

This is a Garmin Connect IQ watchface application that displays time in Swedish text format ("Klockan X och Y"). The project uses Monkey C programming language and targets multiple Garmin watch models including Fenix, Forerunner, Epix, and Venu series.

## Architecture & Key Components

### Core Structure

-  **Entry Point**: `testklockanApp.mc` - Main application class extending `Application.AppBase`
-  **View Logic**: `testklockanView.mc` - Watchface view extending `WatchUi.WatchFace`
-  **Resources**: XML-based resource system for layouts, strings, and drawables
-  **Build Output**: Generated code in `bin/gen/` directory (auto-generated, don't edit)

### Resource System

-  `manifest.xml` - Application metadata and target device configuration (auto-generated)
-  `monkey.jungle` - Project configuration file
-  `resources/` - Contains layouts, strings, and drawable definitions
-  Generated `Rez.mcgen` provides typed access to resources via `Rez.Layouts`, `Rez.Strings`, etc.

## Development Patterns

### Time Display Logic

The watchface uses a multi-line text approach with Swedish time formatting:

-  Minutes 0: "Klockan [hour]" (2 lines)
-  Minutes 1-29: "Klockan [hour] och [minutes]" (4 lines)
-  Minutes 30+: "Klockan [hour:minute]" format (2 lines)

### Resource Management

-  **Don't edit** `manifest.xml` directly - use VS Code Command Palette "Monkey C: Edit Application"
-  **Don't edit** generated files in `bin/gen/` - they're rebuilt automatically
-  Layout resources define 4 text zones (25% height each) for multi-line display

### UI Implementation Pattern

Current implementation creates text objects manually rather than using XML layout resources:

```monkeyc
// Creates array of Text objects for dynamic line display
_lines = new [4];
for (var i = 0; i < 4; i++) {
    _lines[i] = new Ui.Text({...});
}
```

### Font Scaling Strategy

The view implements adaptive font sizing:

1. Try `FONT_LARGE`, `FONT_MEDIUM`, `FONT_SMALL` in order
2. Check horizontal fit (95% of screen width)
3. Check vertical fit (95% of screen height)
4. Choose largest font that fits all text lines

### Device Targeting

Supports 40+ Garmin devices via product IDs in manifest. Use "Monkey C: Set Products by Product Category" or "Monkey C: Edit Products" commands to modify target devices.

## Key Development Commands

### VS Code Integration

-  **Build**: Use "Monkey C: Build for Device" from Command Palette
-  **Run**: "Monkey C: Run Without Debugging"
-  **Device Config**: "Monkey C: Edit Products" to change target devices
-  **Permissions**: "Monkey C: Edit Permissions" for app capabilities

### File Organization

-  Keep Monkey C source in `source/` directory
-  Resource definitions in `resources/` subdirectories
-  Never modify `bin/` contents directly
-  Use `.mc` extension for Monkey C files

## Code Conventions

### Imports & Namespaces

```monkeyc
using Toybox.WatchUi as Ui;        // Preferred alias pattern
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
```

### Class Structure

-  Extend appropriate base classes (`WatchUi.WatchFace`, `Application.AppBase`)
-  Implement required lifecycle methods (`onUpdate`, `onLayout`, `initialize`)
-  Use proper type annotations: `as Gfx.Dc`, `as Lang.Array<Lang.String>`

### Resource Access

```monkeyc
// Access generated resources through Rez module
Rez.Layouts.MainLayout(dc)
Rez.Strings.AppName
```

## Testing & Debugging

-  Use simulator through VS Code Monkey C extension
-  Test on multiple device sizes due to wide device support
-  Swedish text display requires proper Unicode handling
-  Verify font scaling across different screen resolutions (280x280 for Enduro3 target)
