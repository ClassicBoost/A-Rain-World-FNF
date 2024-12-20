package meta.states.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;
/*
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠁⢹⠀⠀⠀⠀⠀⠀⣠⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠃⠀⢸⡆⠀⠀⠀⠀⠀⡇⠀⠻⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⢸⡇⠀⠀⠀⠀⠀⡇⠀⠀⢻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⡾⡇⠀⠀⣿⠀⠀⢸⡇⠀⠀⠀⠀⠀⡇⠀⠀⢸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣀⢀⡟⠀⢿⠀⠀⢸⡆⠀⠘⠷⠶⠶⠶⠦⣤⡇⠀⠀⢸⠁⠀⠀⠀⠀⣠⡀⠀⠀⠀⠀
⠀⠀⢠⡟⢿⣇⠀⠘⣇⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡿⠀⠀⠀⣠⡾⠛⡇⠀⠀⠀⠀
⠀⠀⢸⡇⠀⢻⣆⣰⠿⣽⢿⣷⡄⠀⠀⠀⠀⢀⣶⣦⣄⠀⠈⢷⣀⣴⠞⠁⠀⢰⠇⠀⠀⠀⠀
⠀⠀⢈⣻⣄⡤⢹⡏⠀⣷⣾⣿⣿⠀⠀⠀⢰⣏⣠⣿⣿⣷⠀⠘⣿⣀⣀⣀⣸⣿⣶⡆⠀⠀⠀
⠀⠀⠘⣯⠉⠛⠻⡇⠀⠻⢿⢿⣇⣀⠀⠀⠀⣿⣿⣿⣧⡿⠀⣿⣯⡉⠉⠉⠁⢠⡟⠀⠀⠀⠀
⠀⠀⠀⠸⣦⣀⣀⣿⡀⠀⠀⠀⠉⠋⠀⠀⠀⠈⠉⠛⠉⠀⠀⡇⠈⠳⣄⢀⣰⡟⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠻⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢷⣄⠄⢈⣿⡷⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣤⠖⠒⡆⢨⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡏⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⡴⠋⠁⠀⢀⡇⣼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢠⡞⠁⠀⠀⠀⠸⣷⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢠⡏⠀⠀⠀⠀⠀⠀⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⠀⠀⠀⠀⠀⠀⢰⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⡀⠀⠀⠀⠀⠀⠀
⣿⠀⠀⠀⠀⠀⢀⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⡄⠀⠀⠀⠀⠀
⢸⡄⠀⠀⠀⠀⢸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣷⠀⠀⠀⠀⠀
⠀⢻⣄⠀⠀⠀⢸⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀⠀⠀⠀
⠀⠀⠙⢦⡀⠀⠘⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠃⠀⠀⠀⠀⠀
⠀⠀⠀⠈⠛⠶⣄⣹⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠏⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠉⠻⣧⣤⠤⠤⣤⡀⠀⠀⠀⣀⣀⠀⠀⠀⣠⡴⠶⠶⣯⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣟⣀⠀⠀⣈⣻⣦⠞⠋⠉⠉⠉⠓⢶⣯⣤⣤⣤⣼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠉⠁⠀
*/
class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
		['Mod Credits'],
		['Classic1926',		'classic',		'Programmer and Charter',					'https://www.youtube.com/channel/UCKcqlPIGcsoiGl9qsasAJhw',	'FF6868'],
		['Cehroaza',		'cehroaza',		'Artist',					'https://twitter.com/Cehroaza',	'68B7D8'],
		['Rain World'],
		['Videocult',		'',		'Yea they made Rain World',					'https://twitter.com/VideoCultMedia',	'FF6868'],
		['Creator'],
		['Classic1926',		'classic',		'Made the fork',					'https://www.youtube.com/channel/UCKcqlPIGcsoiGl9qsasAJhw',	'FF6868'],
		[''],
		['Translations'],
		['ytggobs',		'',		'French Translation',					'',	'FF6868'],
		[''],
		['hi'],
		['Cehroaza',		'cehroaza',		'',					'https://twitter.com/Cehroaza',	'68B7D8'],
		[''],
		['Psych Engine Team'],
		['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',					'https://twitter.com/Shadow_Mario_',	'FFDD33'],
		['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',				'https://twitter.com/river_oaken',		'C30085'],
		[''],
		['Engine Contributors'],
		['shubs',				'shubs',			'New Input System Programmer\n(I do not support her)',							'',			'4494E6'],
		['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension',						'https://twitter.com/polybiusproxy',	'E01F32'],
		['gedehari',			'gedehari',			'Chart Editor\'s Sound Waveform base',				'https://twitter.com/gedehari',			'FF9300'],
		['Keoiki',				'keoiki',			'Note Splash Animations',							'https://twitter.com/Keoiki_',			'FFFFFF'],
		['SandPlanet',			'sandplanet',		'Mascot\'s Owner\nMain Supporter of the Engine',		'https://twitter.com/SandPlanetNG',	'D10616'],
		['bubba',				'bubba',		'Guest Composer for "Hot Dilf"',	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw',	'61536A'],
		[''],
		["Funkin' Crew"],
		['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				'https://twitter.com/ninja_muffin99',	'F73838'],
		['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					'https://twitter.com/PhantomArcade3K',	'FFBB1B'],
		['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					'https://twitter.com/evilsk8r',			'53E52C'],
		['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					'https://twitter.com/kawaisprite',		'6475F3']
	];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		MainMenuState.loadMenuJson();

		bg = new FlxSprite().loadGraphic(Paths.image('menus/${MainMenuState.stupidcreditsBG}'));
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable && creditsStuff[i][1] != '') {
				var icon:AttachedSprite = new AttachedSprite('menus/credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font(MainMenuState.choosenFont), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('menus/base/cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT && creditsStuff[curSelected][3] != '') {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('menus/base/scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
