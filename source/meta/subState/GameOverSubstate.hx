package meta.subState;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Boyfriend;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Conductor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import meta.state.*;
import meta.state.menus.*;

class GameOverSubstate extends MusicBeatSubState
{
	//
	var bf:Boyfriend;
	var camFollow:FlxObject;

	public static var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		var daBoyfriendType = PlayState.boyfriend.curCharacter;
		var daBf:String = '';
		switch (daBoyfriendType)
		{
			case 'bf-og':
				daBf = daBoyfriendType;
			case 'bf-pixel':
				daBf = 'bf-pixel-dead';
				stageSuffix = '-pixel';
			default:
				daBf = 'bf-dead';
		}

		super();

		Conductor.songPosition = 0;

		PlayState.defaultCamZoom = 1;

		bf = new Boyfriend();
		bf.setCharacter(x, y + PlayState.boyfriend.height, daBf);
		add(bf);

		var bottomBar = new FlxSprite().makeGraphic(FlxG.width, 48, FlxColor.BLACK);
		bottomBar.scrollFactor.set();
		bottomBar.y = (FlxG.height);
		add(bottomBar);
		var topBar = new FlxSprite().makeGraphic(FlxG.width, 48, FlxColor.BLACK);
		topBar.scrollFactor.set();
		topBar.y = -48;
		add(topBar);

		var deathTxt:FlxText = new FlxText(20, FlxG.height - 46, 0, "Game Over - Press ENTER to retry.", 32);
		deathTxt.scrollFactor.set();
		deathTxt.setFormat(Paths.font("segoe.ttf"), 32);
		deathTxt.alpha = 0;
		deathTxt.updateHitbox();
		add(deathTxt);

		PlayState.boyfriend.destroy();

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);

		Conductor.changeBPM(100);

		if (CoolUtil.difficultyFromNumber(PlayState.storyDifficulty).toLowerCase() == 'pain')
			FlxG.sound.play(Paths.soundRandom('damage/inv/death', 1, 4));

		FlxTween.tween(bottomBar, {y: FlxG.height - 48}, 1, {ease: FlxEase.quartInOut, startDelay: 1,
			onComplete: function(twn:FlxTween)
				{
					FlxG.sound.play(Paths.sound('damage/death'));
				}});
		FlxTween.tween(topBar, {y: 0}, 1, {ease: FlxEase.quartInOut, startDelay: 1});
		FlxTween.tween(deathTxt, {alpha: 0.75}, 0.5, {ease: FlxEase.quartInOut, startDelay: 2});

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deaths = 0;

			if (PlayState.isStoryMode)
			{
				Main.switchState(this, new StoryMenuState());
			}
			else
				Main.switchState(this, new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		// if (FlxG.sound.music.playing)
		//	Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
				{
					Main.switchState(this, new PlayState());
				});
			});
			//
		}
	}
}
