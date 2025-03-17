package meta.subState;

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
import meta.MusicBeat.MusicBeatSubState;
import meta.data.font.Alphabet;
import meta.state.*;
import meta.state.menus.*;

class PauseSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var bg:FlxSprite;
	var bottomBar:FlxSprite;
	var topBar:FlxSprite;
	var levelInfo:FlxText;
	var optionText:FlxText;

	public function new(x:Float, y:Float)
	{
		super();
		#if debug
		// trace('pause call');
		#end

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('pause_loop'), true, true);
		pauseMusic.volume = 0.4;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		#if debug
		// trace('pause background');
		#end

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


		levelInfo = new FlxText(20, 0, 0, "", 32);
		levelInfo.text += CoolUtil.dashToSpace(PlayState.SONG.song) + ' - Fails: ' + PlayState.deaths;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("segoe.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		#if debug
		// trace('pause info');
		#end

		optionText = new FlxText(20, FlxG.height - 48, 0, "", 32);
		optionText.scrollFactor.set();
		optionText.setFormat(Paths.font("segoe.ttf"), 32);
		optionText.updateHitbox();
		add(optionText);

		levelInfo.alpha = 0;

		levelInfo.screenCenter(X);

		FlxTween.tween(bg, {alpha: 0.6}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(bottomBar, {y: FlxG.height - 48}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(topBar, {y: 0}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1}, 3, {ease: FlxEase.quartInOut, startDelay: 2});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
		//	grpMenuShit.add(songText);
		}

		#if debug
		// trace('change selection');
		#end
		FlxG.sound.play(Paths.sound('menus/base/cancelMenu'), 0.4);
		changeSelection();

		#if debug
		// trace('cameras');
		#end

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if debug
		// trace('cameras done');
		#end
	}

	override function update(elapsed:Float)
	{
		#if debug
		// trace('call event');
		#end

		super.update(elapsed);

		#if debug
		// trace('updated event');
		#end

		var upP = controls.UI_LEFT_P;
		var downP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;

		var daSelected:String = menuItems[curSelected];

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		optionText.text = '< ' + daSelected.toUpperCase() + ' >';
		optionText.x = FlxG.width - (optionText.width + 20);

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					exitPause();
				case "Restart Song":
					Main.switchState(this, new PlayState());
				case "Exit to menu":
					PlayState.resetMusic();
					PlayState.deaths = 0;

					if (PlayState.isStoryMode)
						Main.switchState(this, new StoryMenuState());
					else
						Main.switchState(this, new FreeplayState());
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}

		#if debug
		// trace('music volume increased');
		#end
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

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
		FlxG.sound.play(Paths.sound('menus/base/scrollMenu'));

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		#if debug
		// trace('mid selection');
		#end

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

		#if debug
		// trace('finished selection');
		#end
		//
	}
}
