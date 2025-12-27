import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Graphics;

class SwedishTimeFormatter {

    // Constants for months
    static const JANUARY = 1;
    static const DECEMBER = 12;
    
    // Constants for days of week (Garmin uses 1=Sunday, 2=Monday, etc.)
    static const TUESDAY = 3;
    static const THURSDAY = 5;
    static const SATURDAY = 7;
    
    // Hour names in Swedish
    static const HOURS = ["TOLV", "ETT", "TVÅ", "TRE", "FYRA", "FEM", "SEX", "SJU", "ÅTTA", "NIO", "TIO", "ELVA"];

    // Generate Swedish text lines based on time
    static function buildLines(clockTime as System.ClockTime) as Lang.Array<Lang.String> {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        
        return getTimeStrings(clockTime, info, null);
    }
    
    // Generate Swedish text lines based on time with settings
    static function buildLinesWithSettings(clockTime as System.ClockTime, settings as Lang.Dictionary) as Lang.Array<Lang.String> {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        
        return getTimeStrings(clockTime, info, settings);
    }
    
    // Get battery level information for display
    static function getBatteryInfo() as Lang.Dictionary {
        var stats = System.getSystemStats();
        var battery = stats.battery;
        
        var color = Graphics.COLOR_GREEN;
        
        if (battery <= 10) {
            color = Graphics.COLOR_RED;
        } else if (battery <= 25) {
            color = Graphics.COLOR_RED;
        } else if (battery <= 50) {
            color = Graphics.COLOR_YELLOW;
        } else if (battery <= 75) {
            color = Graphics.COLOR_GREEN;
        } else {
            color = Graphics.COLOR_GREEN;
        }
        
        return {
            "color" => color,
            "percentage" => battery
        };
    }
    
    static function getEventStrings(clockTime as System.ClockTime, info as Time.Gregorian.Info) as Lang.Dictionary {
        var line1 = "";
        var line2 = "";
        var minutes = 0;
        
        var nYear = info.year;
        var nMonth = info.month;
        var nDay = info.day;
        var nHour = clockTime.hour;
        var nMinute = clockTime.min;
        var weekDay = info.day_of_week;
        
        // Melodikrysset - 10:00 on saturdays
        if (weekDay == SATURDAY) {
            if (nHour == 9 && nMinute >= 38) {
                line1 = "MELODI";
                line2 = "KRYSSET";
                minutes = nMinute - 60;
            } else if (nHour == 10 && nMinute <= 2) {
                line1 = "MELODI";
                line2 = "KRYSSET";
                minutes = nMinute;
            }
        }
        
        // Hangouts at 15:30 on tuesday and thursday
        // if (weekDay == TUESDAY || weekDay == THURSDAY) {
        //     if (nHour == 15 && nMinute >= 18 && nMinute <= 32) {
        //         line1 = "HANG";
        //         line2 = "OUT";
        //         minutes = nMinute - 30;
        //     }
        // }
        
        // Kalle Anka - Christmas Eve
        if (nMonth == DECEMBER && nDay == 24) {
            if (nHour == 14 && nMinute >= 38) {
                line1 = "KALLE";
                line2 = "ANKA";
                minutes = nMinute - 60;
            } else if (nHour == 15 && nMinute <= 2) {
                line1 = "KALLE";
                line2 = "ANKA";
                minutes = nMinute;
            }
        }
        
        // New Year
        if (nMonth == DECEMBER && nDay == 31) {
            if (nHour == 23 && nMinute >= 38) {
                line1 = Lang.format("$1$", [nYear + 1]);
                minutes = nMinute - 60;
            }
        }
        if (nMonth == JANUARY && nDay == 1) {
            if (nHour == 0 && nMinute <= 2) {
                line1 = Lang.format("$1$", [nYear]);
                minutes = nMinute;
            }
        }
        
        var lines = [] as Lang.Array<Lang.String>;
        if (line1.length() > 0) { lines.add(line1); }
        if (line2.length() > 0) { lines.add(line2); }
        
        return {
            "lines" => lines,
            "minutes" => minutes
        };
    }
    
    static function getHourStrings(clockTime as System.ClockTime, info as Time.Gregorian.Info) as Lang.Dictionary {
        var hour = clockTime.hour;
        var minute = clockTime.min;
        var minutes = minute;
        
        var eventStrings = getEventStrings(clockTime, info);
        var eventLines = eventStrings.get("lines") as Lang.Array<Lang.String>;
        if (eventLines.size() > 0) {
            return {
                "lines" => eventLines,
                "minutes" => eventStrings.get("minutes")
            };
        }
        
        var lines = [] as Lang.Array<Lang.String>;
        if (minute >= 38) {
            lines.add(HOURS[(hour + 1) % 12]);
            minutes = minute - 60;
        } else if (minute >= 23) {
            var hourString = "HALV " + HOURS[(hour + 1) % 12];
            lines.add(hourString);
            // lines.add("HALV");
            // lines.add(HOURS[(hour + 1) % 12]);
            minutes = minute - 30;
        } else {
            lines.add(HOURS[hour % 12]);
            minutes = minute;
        }
        
        return {
            "lines" => lines,
            "minutes" => minutes
        };
    }
    
    static function getMinuteStrings(minutes as Lang.Number) as Lang.Dictionary {
        var lines = [] as Lang.Array<Lang.String>;
        var minute = minutes;
        
        if (minutes <= -18) {
            lines.add("TJUGO I");
            minute = minutes + 20;
        } else if (minutes <= -13) {
            lines.add("KVART I");
            minute = minutes + 15;
        } else if (minutes <= -8) {
            lines.add("TIO I");
            minute = minutes + 10;
        } else if (minutes <= -3) {
            lines.add("FEM I");
            minute = minutes + 5;
        } else if (minutes <= 2) {
            // lines remains empty
            minute = minutes;
        } else if (minutes <= 7) {
            lines.add("FEM ÖVER");
            minute = minutes - 5;
        } else if (minutes <= 12) {
            lines.add("TIO ÖVER");
            minute = minutes - 10;
        } else if (minutes <= 17) {
            lines.add("KVART ÖVER");
            minute = minutes - 15;
        } else {
            lines.add("TJUGO ÖVER");
            minute = minutes - 20;
        }
        
        return {
            "lines" => lines,
            "minutes" => minute
        };
    }
    
    static function getTimeStrings(clockTime as System.ClockTime, info as Time.Gregorian.Info, settings as Lang.Dictionary?) as Lang.Array<Lang.String> {
        var hour = clockTime.hour;
        
        var hourStrings = getHourStrings(clockTime, info);
        var hourLines = hourStrings.get("lines") as Lang.Array<Lang.String>;
        var hourMinutes = hourStrings.get("minutes") as Lang.Number;
        
        var minuteStrings = getMinuteStrings(hourMinutes);
        var minuteLines = minuteStrings.get("lines") as Lang.Array<Lang.String>;
        var minutes = minuteStrings.get("minutes") as Lang.Number;
        
        // Special case: "DRAG HÅLET" for quarter past three
        if (hour % 12 == 3 && minutes >= 0 && minuteLines.size() > 1 && 
            minuteLines[0].equals("KVART") && minuteLines[1].equals("ÖVER")) {
            hourLines = ["DRAG", "HÅLET"];
        }
        
        var lines = [] as Lang.Array<Lang.String>;
        
        // Apply settings filters for minute-specific text
        var showMinus2 = settings == null ? true : (settings.get("ShowMinus2Min") as Lang.Boolean);
        var showMinus1 = settings == null ? true : (settings.get("ShowMinus1Min") as Lang.Boolean);
        var show0 = settings == null ? true : (settings.get("Show0Min") as Lang.Boolean);
        var showPlus1 = settings == null ? true : (settings.get("ShowPlus1Min") as Lang.Boolean);
        var showPlus2 = settings == null ? true : (settings.get("ShowPlus2Min") as Lang.Boolean);
        
        if (minutes == -2 && showMinus2) {
            lines.add("SNART");
        } else if (minutes == -1 && showMinus1) {
            lines.add("STRAX");
        }
        
        if (minuteLines.size() == 0) {
            if (minutes == 0 && show0) {
                if (hourLines[0].equals("HALV")) {
                    lines.add("EXAKT");
                } else {
                    lines.add("PRICK");
                }
            } else if (minutes == 1 && showPlus1) {
                lines.add("STRAX ÖVER");
            } else if (minutes == 2 && showPlus2) {
                lines.add("LITE ÖVER");
            }
        } else {
            var over = false;
            if (minuteLines.size() == 1 && minuteLines[0].length() >= 4 && 
                minuteLines[0].substring(minuteLines[0].length() - 5, minuteLines[0].length()).equals(" ÖVER")) {
                over = true;
            } else if (minuteLines.size() > 1 && minuteLines[minuteLines.size() - 1].equals("ÖVER")) {
                over = true;
            }

            if (minutes == 1 && showPlus1) {
                if (over) {
                    lines.add("NYSS");
                }
                else {
                    lines.add("NYSS");
                }
            } else if (minutes == 2 && showPlus2) {
                // if minuteLines[0] ends with ÖVER, change to LITE ÖVER
                if (over) {
                    lines.add("MER ÄN");
                }
                else {
                    lines.add("MINDRE ÄN");
                }
            }
        }        
        // Combine all lines
        for (var i = 0; i < minuteLines.size(); i++) {
            lines.add(minuteLines[i]);
        }
        for (var i = 0; i < hourLines.size(); i++) {
            lines.add(hourLines[i]);
        }
        
        return lines;
    }
}