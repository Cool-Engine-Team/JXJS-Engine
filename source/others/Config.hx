package others;

import flixel.FlxState;

class Config {

    // MenuMessage.hx Stuff
    public static var onAccept:FlxState;
    public static var onDecline:FlxState;

    public static var AcceptText:String = "None";
    public static var DeclineText:String = "None";
    public static var Title:String = "None";
    public static var Content:String = "None";

    // Scripting Shit for ui

    public static var previewing:Bool = false;

    // MainMenu Section Shit

    public static var sectionCurSelected = 1;
}