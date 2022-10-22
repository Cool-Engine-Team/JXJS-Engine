package states;

import states.CacheState.ImageCache;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import states.MusicBeatState;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.shapes.FlxShapeArrow;
import flixel.math.FlxPoint;
#if sys
import sys.FileSystem;
#end
import openfl.utils.Assets as OpenflAssets;

using StringTools;

class ModsState extends states.MusicBeatState
{
	//DEJENLO COMO ARRAY NOMAS, NO LO CAMBIEN >:(
	public static var usableMods:Array<Bool>;
	public static var modsFolders:Array<String>;
	var exitState:FlxText;
	var warning:FlxText;
	var curMod:String;
	
	var grpMods:FlxTypedGroup<Alphabet>;

	var bg_but_not_vid:FlxSprite;

	override function create(){
		#if windows
		// Updating Discord Rich Presence
		Discord.DiscordClient.changePresence("In the Mod Selector Menu", null);
		#end

		modsFolders = CoolUtil.coolTextFile("mods/modsList.txt");

		bg_but_not_vid = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuBGBlue'));
		bg_but_not_vid.scrollFactor.x = 0;
		bg_but_not_vid.scrollFactor.y = 0.18;
		bg_but_not_vid.screenCenter();
		bg_but_not_vid.antialiasing = true;
		add(bg_but_not_vid);

		trace(ModPaths.getPreviewVideo('preview-video',modsFolders[curSelected]));


		exitState = new FlxText(0, 0, 0, "ESC to exit", 12);
		exitState.size = 28;
		exitState.y += 35;
		exitState.scrollFactor.set();
		exitState.screenCenter(X);
		exitState.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(exitState);

		usableMods = [];//Clear all cuz this can cause errors :/
		
		#if MOD_ALL
		if(modsFolders.length != 0 || modsFolders != []){
			var freakyMenu:String = 'mods/${modsFolders[curSelected]}/music/freakyMenu.ogg';
			if(FileSystem.exists(freakyMenu))
				FlxG.sound.playMusic(freakyMenu);
			else
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			grpMods = new FlxTypedGroup<Alphabet>();

			for(i in 0... modsFolders.length){
				if(usableMods.length == 0 || usableMods == [])
					usableMods.push(ModPaths.checkModCool(modsFolders[i]));

				var modText:Alphabet = new Alphabet(0,(i + 1) * 100, modsFolders[i],false);
				modText.isMenuItem = true;
				modText.targetY = i;
				modText.screenCenter(X);
				grpMods.add(modText);
				if(!usableMods[i])
					modText.changeText('${modsFolders[i]} (is not usable)');
			}
		}
		else{
			var modText:FlxText = new FlxText(0, 1 * 100, 'The folder is empty',false);
			modText.screenCenter(X);
			add(modText);
		}
		add(grpMods);
		#end

		super.create();
	}

	var curSelected:Int = 0;
	override function update(elapsed:Float){
		#if MOD_ALL
		if(controls.BACK) {
			LoadingState.loadAndSwitchState(new states.MainMenuState());
			FlxG.camera.flash(FlxColor.WHITE);
		}
		if(modsFolders.length != 0 || modsFolders != []) 
			if(controls.ACCEPT && usableMods[curSelected]){
				openSubState(new USure());
				ModsFreeplayState.mod = modsFolders[curSelected];
			}
		#else
		LoadingState.loadAndSwitchState(new MainMenuState());
		#end

		if(controls.UP_P)
		{
			changeSelection(-1);
		}		
		if(controls.DOWN_P)
		{
			changeSelection(-1);
		}
		super.update(elapsed);
	}

	private function changeSelection(change:Int):Void{


		curMod = modsFolders[curSelected - 1];
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		if(openfl.utils.Assets.exists('mods/' + modsFolders[curSelected + 1] + '/music/freakyMenu.ogg'))
			FlxG.sound.playMusic('mods/' + modsFolders[curSelected + 1] + '/music/freakyMenu.ogg');
		else
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		curSelected += change;

		if (curSelected < 0)
			curSelected = modsFolders.length - 1;
		if (curSelected >= modsFolders.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMods.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		trace(ModPaths.getModScripts('Script.hx',modsFolders[curSelected]));

	}
}

class USure extends states.MusicBeatSubstate
{
	var wasPressed:Bool = false;
	var areYouSure:FlxText = new FlxText();
	var ye:FlxText = new FlxText();
	var NO:FlxText = new FlxText();
	var marker:FlxShapeArrow;

	var theText:Array<FlxText> = [];
	var selected:Int = 0;

	var blackBox:FlxSprite;
	var restart:Bool;

	override function create()
	{
		super.create();

		blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        add(blackBox);

		marker = new FlxShapeArrow(0, 0, FlxPoint.weak(0, 0), FlxPoint.weak(0, 1), 24, {color: FlxColor.WHITE});

		areYouSure.setFormat(Paths.font("Funkin.otf"), 36, FlxColor.WHITE, FlxTextAlign.CENTER);
		areYouSure.text = "Are you sure you wanna to load this mod?";
		areYouSure.y = 176;
		areYouSure.screenCenter(X);
		add(areYouSure);

		theText.push(ye);
		theText.push(NO);
		ye.text = "Yes";
		NO.text = "No";

		for (i in 0...theText.length)
		{
			theText[i].setFormat(Paths.font("Funkin.otf"), 24, FlxColor.WHITE, FlxTextAlign.CENTER);
			theText[i].screenCenter(Y);
			theText[i].x = (i * FlxG.width / theText.length + FlxG.width / theText.length / 2) - theText[i].width / 2;
			add(theText[i]);
		}

		add(marker);

		blackBox.alpha = 0;
		ye.alpha = 0;
		NO.alpha = 0;
		areYouSure.alpha = 0;
		FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(ye, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(NO, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(areYouSure, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER && !wasPressed)
		{
			wasPressed = true;
			switch (selected)
			{
				case 0:
					FlxG.switchState(new ModsFreeplayState());
					ModsFreeplayState.onMods = true;
				case 1:
					FlxG.state.closeSubState();
					ModsFreeplayState.onMods = false;
			}
		}

		if (FlxG.keys.justPressed.LEFT)
		{
			changeSelection(-1);
		}

		if (FlxG.keys.justPressed.RIGHT)
		{
			changeSelection(1);
		}

		marker.x = theText[selected].x + theText[selected].width / 2 - marker.width / 2;
		marker.y = theText[selected].y - marker.height - 5;
	}

	function changeSelection(direction:Int = 0)
	{
		if (wasPressed)
			return;

		selected = selected + direction;
		if (selected < 0)
			selected = theText.length - 1;
		else if (selected >= theText.length)
			selected = 0;
	}
}
