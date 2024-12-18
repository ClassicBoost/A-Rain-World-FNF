package meta.states.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import haxe.Json;
import editors.MasterEditorMenu;

using StringTools;

typedef MenuOptionsIG =
{
	var story_mode:Bool;
	var freeplay:Bool;
	var options:Bool;
	var awards:Bool;
	var credits:Bool;
	var donate:Bool;

	var menu_bg:String;
	var freeplay_bg:String;
	var options_bg:String;
	var awards_bg:String;
	var credits_bg:String;

	var main_font:String;
}

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	public static var menuOptions:MenuOptionsIG;

	public static var stupidmenuBG:String = 'bg';
	public static var stupidfreeplayBG:String = 'bg';
	public static var stupidoptionsBG:String = 'bg';
	public static var stupidawardsBG:String = 'bg';
	public static var stupidcreditsBG:String = 'bg';

	public static var choosenFont:String = 'rw-menu.ttf';

	public static var invUnlocked:Int = 0;
	
	var optionShit:Array<String> = [
	'story_mode',
	'freeplay',
	'options',
	#if ACHIEVEMENTS_ALLOWED 'awards', #end
	'credits' #if !switch ,
	'donate' #end];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	public static var inMenu:Bool = false;

	private var keysPressed:String = '';
	private var currentPart:Int = 0;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!inMenu) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);

		inMenu = true;

		// IGNORE THIS!!!
		menuOptions = cast Json.parse(Paths.getTextFromFile('images/menus/MenuOptions.json'));

		// One has to be enabled, idk if the game would crash or not if there is an empty array but either way.
		if (menuOptions.story_mode || menuOptions.freeplay || menuOptions.options || menuOptions.awards || menuOptions.credits || menuOptions.donate) {
			if (!menuOptions.story_mode) optionShit.remove('story_mode');
			if (!menuOptions.freeplay) optionShit.remove('freeplay');
			if (!menuOptions.options) optionShit.remove('options');
			if (!menuOptions.awards) optionShit.remove('awards');
			if (!menuOptions.credits) optionShit.remove('credits');
			if (!menuOptions.donate) optionShit.remove('donate');
		}

		loadMenuJson();

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/$stupidmenuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.color = 0xFFFDE871;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menus/$stupidmenuBG'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.frames = Paths.getSparrowAtlas('menus/main/' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, '${Translation.versionTxt} v' + Main.foreverVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font(choosenFont), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Psych Engine v" + psychEngineVersion + " | FNF v" + Application.current.meta.get('version'), 12);
		if (invUnlocked == 2) versionShit.text = 'Press NINE to enter the Dating Sim';
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font(choosenFont), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		if (FlxG.save.data.invUnlocked == null) invUnlocked = 0;
		else invUnlocked = FlxG.save.data.invUnlocked;

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		keyboardShit();

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('menus/base/scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('menus/base/scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				//selectedSomethin = true;
				//FlxG.sound.play(Paths.sound('menus/base/cancelMenu'));
				//MusicBeatState.switchState(new TitleState());
			}

			if (FlxG.keys.justPressed.NINE && invUnlocked == 2) MusicBeatState.switchState(new DatingSimState());

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('menus/base/confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (controls.MASTER && Main.devMode)
			{
				selectedSomethin = true;
			//	FlxTween.tween(FlxG.sound.music, {pitch: 0.3, volume: 0.3}, 1, {ease: FlxEase.cubeOut});
				FlxG.sound.music.fadeIn(1, 0.7, 0.2);
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function keyboardShit() {
		if (FlxG.keys.justPressed.ANY) {
			currentPart++;
			switch (currentPart) {
				case 0:
					if (FlxG.keys.justPressed.S) return;
				case 1:
					if (FlxG.keys.justPressed.O) return;
				case 2:
					if (FlxG.keys.justPressed.F) return;
				case 3:
					if (FlxG.keys.justPressed.A) return;
				case 4:
					if (FlxG.keys.justPressed.N) return;
				case 5:
					if (FlxG.keys.justPressed.T) return;
				case 6:
					if (FlxG.keys.justPressed.H) return;
				case 7:
					if (FlxG.keys.justPressed.I) return;
				case 8:
					if (FlxG.keys.justPressed.E) return;
				case 9:
					if (FlxG.keys.justPressed.L) {
						FlxG.sound.play(Paths.sound('unlocked'));
						currentPart = 0;
						if (invUnlocked == 0) {
							invUnlocked = 1;
							FlxG.save.data.invUnlocked = invUnlocked;
						}
						return;
				}
			}
			if (currentPart > 2) FlxG.sound.play(Paths.sound('menus/base/cancelMenu'));
			currentPart = 0;
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}

	public static function loadMenuJson() {
		if (menuOptions.menu_bg != null) stupidmenuBG = menuOptions.menu_bg;
		if (menuOptions.freeplay_bg != null) stupidfreeplayBG = menuOptions.freeplay_bg;
		if (menuOptions.options_bg != null) stupidoptionsBG = menuOptions.options_bg;
		if (menuOptions.awards_bg != null) stupidawardsBG = menuOptions.awards_bg;
		if (menuOptions.credits_bg != null) stupidcreditsBG = menuOptions.credits_bg;

		if (menuOptions.main_font != null) choosenFont = menuOptions.main_font;
	}
}
