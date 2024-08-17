package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;

import backend.Highscore;
import backend.Song;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.2h'; // This is also used for Discord RPC
	public static var curSelected:Int = 2;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		'play',
		'options',
		'credits'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		FlxG.mouse.visible = true;
		curSelected = 3;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var logo:FlxSprite = new FlxSprite(222, 20, Paths.image('logoJoaquim'));
		logo.frames = Paths.getSparrowAtlas('logoJoaquim');
		logo.animation.addByPrefix('idle', 'logoMod', 24);
		logo.animation.play('idle');
		add(logo);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);

			switch (i)
			{
			case 0:
				menuItem.x = 226; menuItem.y = 300;
			case 1:
				menuItem.x = 826; menuItem.y = 300;
			case 2:
				menuItem.x = 526; menuItem.y = 500;
								
			}
		}

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		super.create();

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{

			menuItems.forEach(function(menuItemFunc:FlxSprite)
			{
				if (FlxG.mouse.justReleased && selectedSomethin == false && curSelected != 3 && FlxG.mouse.overlaps(menuItems))
				{
					selectedSomethin = true;

						switch (optionShit[curSelected])
						{
							case 'play':
								PlayState.SONG = Song.loadFromJson('joaquim', 'joaquim');
								PlayState.isStoryMode = false;
								PlayState.storyDifficulty = 1;

								selectedSomethin = true;
								LoadingState.loadAndSwitchState(new PlayState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
						}

					for (i in 0...menuItems.members.length)
					{
						if (i == curSelected)
							continue;
						FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								menuItems.members[i].kill();
							}
						});
					}
				}

				if (FlxG.mouse.overlaps(menuItemFunc) && menuItemFunc.ID != curSelected)
				{
					if (curSelected != 3)
					{
						menuItems.members[curSelected].animation.play('idle');
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					curSelected = menuItemFunc.ID;

					menuItems.members[curSelected].animation.play('selected');
				}
			});

			/*#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end*/
		}

		super.update(elapsed);
	}

}
