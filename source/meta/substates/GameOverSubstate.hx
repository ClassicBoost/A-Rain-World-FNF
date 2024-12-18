package meta.substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'damage/fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'damage/fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		//Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, characterName);
		add(bf);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		//FlxG.camera.bgColor.alpha = 0;

		bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

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

		var blueballedTxt:FlxText = new FlxText(20, 15, 0, "", 32);
		blueballedTxt.text = "Fails: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		if (CoolUtil.difficultyString().toLowerCase() == 'inv') {
			FlxG.sound.play(Paths.soundRandom('damage/inv/death', 1, 4));
			blueballedTxt.text = "Gamer: " + PlayState.deathCounter;
		}

		FlxTween.tween(bottomBar, {y: FlxG.height - 48}, 1, {ease: FlxEase.quartInOut, startDelay: 1,
			onComplete: function(twn:FlxTween)
				{
					FlxG.sound.play(Paths.sound('damage/death'));
				}});
		FlxTween.tween(topBar, {y: 0}, 1, {ease: FlxEase.quartInOut, startDelay: 1});
		FlxTween.tween(deathTxt, {alpha: 0.75}, 0.5, {ease: FlxEase.quartInOut, startDelay: 2});

		blueballedTxt.alpha = 0;

		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			PlayState.usedPractice = false;
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			lePlayState.callOnLuas('onGameOverConfirm', [false]);
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if(bf.animation.curAnim.curFrame == 12)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
			}

			if (bf.animation.curAnim.finished)
			{
			//	coolStartDeath();
				bf.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
		//	Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		//FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.usedPractice = false;
			MusicBeatState.resetState();
		}
	}
}
