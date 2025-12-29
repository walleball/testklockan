import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;
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
        
        // Get current time
        var clockTime = System.getClockTime();
        
        // Read settings
        var settings = {
            "ShowMinus2Min" => getPropertyValue("ShowMinus2Min", true),
            "ShowMinus1Min" => getPropertyValue("ShowMinus1Min", true),
            "Show0Min" => getPropertyValue("Show0Min", true),
            "ShowPlus1Min" => getPropertyValue("ShowPlus1Min", true),
            "ShowPlus2Min" => getPropertyValue("ShowPlus2Min", true)
        };
        
        // Build text lines based on time and settings
        var lines = SwedishTimeFormatter.buildLines(clockTime, settings);
        
        // Choose the best font size
        var font = chooseFontSize(dc, lines);
        
        // Get text color from settings
        var textColor = getTextColor();
        
        // Draw the lines centered on screen
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        drawCenteredLines(dc, lines, font);
        
        // Draw battery indicator if enabled
        var showBattery = getPropertyValue("ShowBattery", false);
        if (showBattery) {
            drawBatteryIndicator(dc);
        }
    }
    
    // Helper to get property value with default
    function getPropertyValue(key as Lang.String, defaultValue as Lang.Boolean) as Lang.Boolean {
        try {
            var value = Application.Properties.getValue(key);
            if (value != null && value instanceof Lang.Boolean) {
                return value as Lang.Boolean;
            }
        } catch (e) {
            // Property read failed, use default
        }
        return defaultValue;
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
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();
        var fontH = dc.getFontHeight(font) + 0; // allow for dots
        
        // Calculate total height and starting Y position
        var totalH = lines.size() * fontH;
        var startY = (screenH - totalH) / 2 + 4; // slight adjustment
        
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

    // Draw battery level indicator at bottom center
    function drawBatteryIndicator(dc as Graphics.Dc) as Void {
        var batteryInfo = SwedishTimeFormatter.getBatteryInfo();
        var color = batteryInfo.get("color") as Graphics.ColorType;
        var percentage = batteryInfo.get("percentage") as Lang.Float;
        
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();
        var bottomMargin = 25;
        
        // Draw custom battery shape using rectangles
        var centerX = screenW / 2;
        var batteryY = screenH - bottomMargin - 10;
        
        // Battery dimensions
        var batteryWidth = 20;
        var batteryHeight = 8;
        var batteryX = centerX - (batteryWidth / 2);
        
        // Draw battery outline (white border)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(batteryX, batteryY, batteryWidth, batteryHeight);
        
        // Draw battery tip (small rectangle on the right)
        dc.fillRectangle(batteryX + batteryWidth, batteryY + 2, 2, 4);
        
        // Draw battery fill based on percentage
        var fillWidth = ((batteryWidth - 2) * percentage / 100).toNumber();
        if (fillWidth > 0) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(batteryX + 1, batteryY + 1, fillWidth, batteryHeight - 2);
        }
    }

    // Get text color from settings
    function getTextColor() as Graphics.ColorValue {
        try {
            var colorValue = Application.Properties.getValue("TextColor");
            
            if (colorValue != null && colorValue instanceof Lang.Number) {
                var colorNum = colorValue as Lang.Number;
                if (colorNum == 1) { return Graphics.COLOR_LT_GRAY; }
                if (colorNum == 2) { return Graphics.COLOR_RED; }
                if (colorNum == 3) { return Graphics.COLOR_BLUE; }
                if (colorNum == 4) { return Graphics.COLOR_GREEN; }
                if (colorNum == 5) { return Graphics.COLOR_YELLOW; }
                if (colorNum == 6) { return Graphics.COLOR_ORANGE; }
                if (colorNum == 7) { return Graphics.COLOR_PURPLE; }
            }
        } catch (e) {
            // If properties fail, use default white
        }
        
        return Graphics.COLOR_WHITE;
    }

}
