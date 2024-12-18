package meta.substates;

import backend.Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;

import openfl.utils.Assets as OpenFlAssets;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to Chart Editor', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;

	var bg:FlxSprite;
	var bottomBar:FlxSprite;
	var topBar:FlxSprite;
	var levelInfo:FlxText;
	var optionText:FlxText;

	public static var transCamera:FlxCamera;

	public function new(x:Float, y:Float)
	{
		super();
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		if (!MasterEditorMenu.inMasterMenu)
			menuItemsOG.remove('Exit to Chart Editor');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('pause_loop'), true, true);
		pauseMusic.volume = 0.5;
		pauseMusic.play(false, 0);

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		bottomBar = new FlxSprite().makeGraphic(FlxG.width, 48, FlxColor.BLACK);
		bottomBar.scrollFactor.set();
		bottomBar.y = (FlxG.height);
		add(bottomBar);
		topBar = new FlxSprite().makeGraphic(FlxG.width, 48, FlxColor.BLACK);
		topBar.scrollFactor.set();
		topBar.y = -48;
		add(topBar);

		levelInfo = new FlxText(20, 2, 0, "", 32);
		levelInfo.text += PlayState.SONG.song + ' - Fails: ' + PlayState.deathCounter;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("segoe.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		optionText = new FlxText(20, FlxG.height - 48, 0, "", 32);
		optionText.scrollFactor.set();
		optionText.setFormat(Paths.font("segoe.ttf"), 32);
		optionText.updateHitbox();
		add(optionText);

		var blueballedTxt:FlxText = new FlxText(20, 20 + 32, 0, "", 32);
		blueballedTxt.text = "Fails: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('segoe.ttf'), 32);
		blueballedTxt.updateHitbox();
		//add(blueballedTxt);

		var levelDifficulty:FlxText = new FlxText(20, 20 + 64, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('segoe.ttf'), 32);
		levelDifficulty.updateHitbox();
		//add(levelDifficulty);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('segoe.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		botplayText = new FlxText(20, 15 + 101 + 32, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font('segoe.ttf'), 32);
		botplayText.x = FlxG.width - (botplayText.width + 20);
		botplayText.updateHitbox();
		botplayText.visible = PlayState.cpuControlled;
		add(botplayText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		optionText.alpha = 0;

		FlxG.sound.play(Paths.sound('menus/${PlayState.instance.uiElement}/cancelMenu'), 0.4);

		levelInfo.screenCenter(X);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(bottomBar, {y: FlxG.height - 48}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(topBar, {y: 0}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1}, 3, {ease: FlxEase.quartInOut, startDelay: 2});
		FlxTween.tween(optionText, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut, startDelay: 1});
		//FlxTween.tween(blueballedTxt, {alpha: 1}, 3, {ease: FlxEase.quartInOut, startDelay: 2});
		//FlxTween.tween(levelDifficulty, {alpha: 1}, 3, {ease: FlxEase.quartInOut, startDelay: 2});
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItemCenter = true;
			songText.targetY = i;
		//	grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		var daSelected:String = menuItems[curSelected];

		if (FlxG.keys.justPressed.LEFT)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.RIGHT)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.ESCAPE)
			exitPause();

		optionText.text = '< ' + daSelected.toUpperCase() + ' >';
		optionText.x = FlxG.width - (optionText.width + 20);

		if (accepted)
		{
			for (i in 0...difficultyChoices.length-1) {
				if(difficultyChoices[i] == daSelected) {
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					return;
				}
			} 

			if (!OpenFlAssets.exists('assets/sounds/menus/${PlayState.instance.uiElement}/confirmMenu.$dumbThing'))
				FlxG.sound.play(Paths.sound('menus/base/confirmMenu'), 0.4);
			else
				FlxG.sound.play(Paths.sound('menus/${PlayState.instance.uiElement}/confirmMenu'), 0.4);

			switch (daSelected)
			{
				case "Resume":
					exitPause();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case 'Practice Mode':
					PlayState.practiceMode = !PlayState.practiceMode;
					practiceText.visible = PlayState.practiceMode;
				case "Restart Song":
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.resetState();
					PlayState.usedPractice = false;
					PlayState.usedBotplay = false;
					FlxG.sound.music.volume = 0;
				case 'Botplay':
					PlayState.cpuControlled = !PlayState.cpuControlled;
					botplayText.visible = PlayState.cpuControlled;
					PlayState.instance.botplayView(PlayState.cpuControlled);
				case 'Options':
					OptionsState.onPlayState = true;
					MusicBeatState.switchState(new OptionsState());
				case 'Exit to Chart Editor':
					PlayState.deathCounter = 0;
					MusicBeatState.switchState(new ChartingState());
				case "Exit to menu":
					MasterEditorMenu.inMasterMenu = false;
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					CustomFadeTransition.nextCamera = transCamera;
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.usedPractice = false;
					PlayState.usedBotplay = false;
					PlayState.changedDifficulty = false;
					PlayState.cpuControlled = false;

				case 'BACK':
					menuItems = menuItemsOG;
					regenMenu();
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	var dumbThing:String = 'ogg';

	function exitPause():Void {
		FlxG.sound.play(Paths.sound('menus/base/confirmMenu'), 0.4);
		FlxTween.tween(bg, {alpha: 0}, 1, {ease: FlxEase.quartOut,
			onComplete: function(twn:FlxTween)
				{
					close();
				}});
		FlxTween.tween(bottomBar, {y: FlxG.height}, 1, {ease: FlxEase.quartOut});
		FlxTween.tween(topBar, {y: -48}, 1, {ease: FlxEase.quartOut});
		FlxTween.tween(levelInfo, {alpha: 0}, 0.5, {ease: FlxEase.quartOut});
		FlxTween.tween(optionText, {alpha: 0}, 0.5, {ease: FlxEase.quartOut});
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (!OpenFlAssets.exists('assets/sounds/menus/${PlayState.instance.uiElement}/scrollMenu.$dumbThing'))
			FlxG.sound.play(Paths.sound('menus/base/scrollMenu'), 0.4);
		else
			FlxG.sound.play(Paths.sound('menus/${PlayState.instance.uiElement}/scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItemCenter = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}
