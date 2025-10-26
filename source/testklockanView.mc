import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.WatchUi as Ui;

class testklockanView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Graphics.Dc) as Void {
        // No layout needed - we'll draw directly in onUpdate
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Graphics.Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Get and show the current time in Swedish format
        var clockTime = System.getClockTime();
        
        // Build text lines based on time
        var lines = buildLines(clockTime);
        
        // Choose the best font size
        var font = chooseFontSize(dc, lines);
        
        // Draw the lines centered on screen
        drawCenteredLines(dc, lines, font);
    }

    // Generate text lines based on time
    function buildLines(clockTime) as Lang.Array<Lang.String> {
        var hour = clockTime.hour;
        var min = clockTime.min;

        if (min == 0) {
            return ["Klockan", Lang.format("$1$", [hour])];
        } else if (min < 10) {
            return ["Klockan", Lang.format("$1$", [hour]), "och", Lang.format("$1$", [min])];
        } else if (min < 30) {
            return ["Klockan", Lang.format("$1$", [hour]), "och", Lang.format("$1$", [min])];
        } else {
            return ["Klockan", Lang.format("$1$:$2$", [hour, min.format("%02d")])];
        }
    }

    // Choose the largest font that fits all lines
    function chooseFontSize(dc as Graphics.Dc, lines as Lang.Array<Lang.String>) as Graphics.FontType {
        var fonts = [Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY];
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();

        for (var fi = 0; fi < fonts.size(); fi++) {
            var font = fonts[fi];
            var fits = true;

            // Check each line horizontally
            for (var i = 0; i < lines.size(); i++) {
                var dims = dc.getTextDimensions(lines[i], font);
                if (dims[0] > screenW * 0.9) { 
                    fits = false;
                    break;
                }
            }

            // Check vertically
            var fontH = dc.getFontHeight(font);
            var totalH = lines.size() * fontH;
            if (totalH > screenH * 0.9) {
                fits = false;
            }

            if (fits) {
                return font;
            }
        }

        return Graphics.FONT_TINY;
    }

    // Draw lines centered vertically and horizontally
    function drawCenteredLines(dc as Graphics.Dc, lines as Lang.Array<Lang.String>, font as Graphics.FontType) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();
        var fontH = dc.getFontHeight(font);
        
        // Calculate total height and starting Y position
        var totalH = lines.size() * fontH;
        var startY = (screenH - totalH) / 2;
        
        // Draw each line
        for (var i = 0; i < lines.size(); i++) {
            var y = startY + (i * fontH);
            dc.drawText(screenW / 2, y, font, lines[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
