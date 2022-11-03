package states;

import modding.ModPaths;
import states.CacheState.ImageCache;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import openfl.display.BitmapData as Bitmap;
#if sys
import sys.FileSystem;
#end

using StringTools;

class TitleState extends states.MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:FlxText;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var timerWait:Float = 1.2;

	var start:Bool = false;
	var startNut = 0;
	//var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;


	override public function create():Void
	{
		(cast (openfl.Lib.current.getChildAt(0), Main)).setMaxFps(FlxG.save.data.FPSCap?120:240);
		PlayerSettings.init();

		//curWacky = FlxG.random.getObject(getIntroTextShit());

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/menuBGtitle'));
		add(bg);




		// DEBUG BULLSHIT

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		states.OptionsMenuState.OptionsData.initSave();
		KeyBinds.keyCheck();

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new states.FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new states.ChartingState());
		#elseif MAINMENU
		FlxG.switchState(new MainMenuState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			if(!FirstTimeState.firstTime)
				FlxG.switchState(new FirstTimeState());
			else
				startIntro();
		});
		#end

		#if desktop
		DiscordClient.initialize();
		#end

		var versionShit2 = new FlxText(5, FlxG.height - 9, 0, 'JXJS Engine - V${Application.current.meta.get('version')}', 12);
		versionShit2.scrollFactor.set();
		versionShit2.setFormat(Paths.font("Funkin.otf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit2.y -= 20;
		add(versionShit2);
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		persistentUpdate = true;

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('titlestate/logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: ONESHOT});


		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titlestate/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new FlxText(0,0,0,"", 24);
		credTextShit.scrollFactor.set();
		credTextShit.setFormat(Paths.font("Funkin.otf"), 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		credTextShit.screenCenter();
		add(credTextShit);

		start = true;

		// credTextShit.alignment = CENTER;



		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('titlestate/newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		// FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			{
				var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
				diamond.persist = true;
				diamond.destroyOnNoUse = false;

				FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
					new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
				FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// HAD TO MODIFY SOME BACKEND SHIT
				// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
				// https://github.com/HaxeFlixel/flixel-addons/pull/348

				// var music:FlxSound = new FlxSound();
				// music.loadStream(Paths.music('freakyMenu'));
				// FlxG.sound.list.add(music);
				// music.play();
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.8);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
				Conductor.changeBPM(102);
				initialized = true;
			}

		// credGroup.add(credTextShit);
	}

	/*function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}*/

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) {
			Conductor.songPosition = FlxG.sound.music.time;
		}
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		// if (start) {
		// 	var Timer:FlxTimer = new FlxTimer().start(0.1, function(timer:FlxTimer) {
		// 		if (startNut == 0) {
		// 			credTextShit.visible = true;
		// 			credTextShit.text = "Manux123\nJloor\nChasetodie\nJontoro\nOverchargedDev\nFairyBoy\nZeroArtist\nJuanen100\nXuelDev";
		// 			credTextShit.screenCenter();

		// 			timer.start(timerWait, function(timer:FlxTimer) {
		// 				credTextShit.text = "Present";
		// 				credTextShit.screenCenter();

		// 				timer.start(timerWait, function(timer:FlxTimer) {
		// 					credTextShit.text = "The Cool Engine!";
		// 					credTextShit.screenCenter();

		// 					timer.start(1, function(timer:FlxTimer) {
		// 						skipIntro();
		// 					});
		// 				});
		// 			});
		// 		}
		// 	});
		// }

		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if(gamepad != null){
			if (gamepad.justPressed.START#if switch || gamepad.justPressed.B#end)
				pressedEnter = true;
			#if (!switch && desktop)
			if(gamepad.justPressed.BACK)
				Application.current.window.close();
			#end
		}

		if(controls.BACK)
			Application.current.window.close();

		if (pressedEnter && !transitioning && skippedIntro)
		{
			if(titleText != null)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated
				var http = new haxe.Http("https://raw.githubusercontent.com/Manux123/FNF-Cool-Engine/master/ver.thing");
				var returnedData:Array<String> = [];
				var version:String = Application.current.meta.get('version');

				http.onData = function(data:String)
				{
					returnedData[0] = data.substring(0, data.indexOf('-'));
					returnedData[1] = data.substring(data.indexOf('+'), data.length);
					if (!version.contains(returnedData[0].trim()) && !OutdatedState.leftState)
					{
						trace('Poor guy, he is outdated');
						OutdatedState.daVersionNeeded = returnedData[0];
						OutdatedState.daChangelogNeeded = returnedData[1];
						FlxG.switchState(new OutdatedState());
					}
					else
					{
						//FlxG.switchState(new states.VideoState('test/sus',new states.PlayState()));
						FlxG.switchState(new MainMenuState());
					}
				}

				http.onError = function(error)
				{
					trace('error: $error');
					FlxG.switchState(new MainMenuState()); // fail but we go anyway
				}

				http.request();
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}
            
		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	};

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, yOffset:Float = 0)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		if (yOffset != 0)
			coolText.y -= yOffset;
		credGroup.add(coolText);
		textGroup.add(coolText);
		
		if(coolText != null && textGroup != null){
			FlxTween.tween(coolText,{y: coolText.y + (textGroup.length * 60) + 150},0.4,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
				{ 
				}});
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function userName():String {
		#if sys
		var env = Sys.environment();
		if (!env.exists("USERNAME")) {
			return "Couldnt find computa name";
		}
		return env["USERNAME"];
		#else
		return "Player";
		#end
	}

	var randomString = [];
	var randomString2 = [];
	var random:Int;

	override function beatHit()
	{

		randomString = ['Thx PabloelproxD210','Thx Chase for...',"Thx TheStrexx for", userName()];//This is for credits, not for funny texts :angry:
		randomString2 = ['for the Android port LOL','SOMTHING',"you'r 3 commits :D", "Thanks for playing B)"];
		//Q: But can't we use the txt file version instead of this hardcoded ver? :cries:
		//A: Cuz is for CREDITS to give thanks to peapole than dont do to much in this project :/
		//Q: if this is for credits that why is it called random also we have already wrote the credits in line 396-406 /:
		//A: Le puse "RandomString" porque no tenia un nombre mas original, igual super XD la pregunta de porque lo llame asi.
		//Y lo de que escribiste una wea en la linea 396... eres tonto o te haces?, literal, dije que era para CREDITOS ADICIONALES
		//PARA GENTE QUE CASI NO HIZO NADA, ademas de que en lo de la linea 396-406 no queda mas espacio en la pantall BRUH
		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		/*if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');*/

		FlxG.log.add(curBeat);

		FlxTween.tween(FlxG.camera, {zoom:1.02}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});

		/*switch (curBeat)
		{
			case 0:
				deleteCoolText();
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['Cool Engine Team']);
			case 7:
				addMoreText('Manux');
				addMoreText('Juanen100');
				addMoreText('MrClogsworthYt');
				addMoreText('JloorMC');
				addMoreText('Overcharged Dev');
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				random = FlxG.random.int(0,randomString.length);
				createCoolText([randomString[random]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(randomString2[random]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText("Funkin"); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}*/

		switch (curBeat)
		{
			case 0:
				deleteCoolText();
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['JXJS Engine Team']);
			case 7:
				addMoreText('Jotaro', 15);
				addMoreText('XuelDev', 15);
				addMoreText('Juanen100', 15);
				addMoreText('Shygee', 15);
				
			case 8:
				deleteCoolText();
				ngSpr.visible = true;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				ngSpr.visible = false;
				random = FlxG.random.int(0,randomString.length);
				createCoolText([randomString[random]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(randomString2[random]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText("Funkin"); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		remove(credTextShit);

		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);

			if(logoBl != null){
				FlxTween.tween(logoBl,{y: -100}, 1.4, {ease: FlxEase.expoInOut});

				logoBl.angle = -4;

				new FlxTimer().start(0.01, function(tmr:FlxTimer)
					{
						if(logoBl.angle == -4) 
							FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
						if (logoBl.angle == 4) 
							FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
					}, 0);
			}	
			skippedIntro = true;
		}
	}
}