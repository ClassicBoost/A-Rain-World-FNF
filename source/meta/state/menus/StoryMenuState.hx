package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.menu.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true];

	var weekCharacters:Array<Dynamic> = [
		['', '', ''],
	];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var invSecretTimer:Float = 60;
	var dialogueTimer:Float = 3.4;
	public var playedInvSecret:Bool = false;

	public var subtitleTxt:FlxText;

	var currentPart:Int = 1;

	public static var invDialogue:Map<Int, Array<Dynamic>> =
	[
		1 => ["Hey Apple, Check out my sweet new mods!", 3.4],
		2 => ["Why don't you play them for me?", 1.8],
		3 => ["It'd be pretty sweet yo!", 2.2],
		4 => ["Oh yea sure no problem I'll definitely play them.", 3],
		5 => ['', 1.9],
		6 => ["Surely nothing will be ha- ba-bad or wrong about this!", 3.9],
		7 => ["Oh yea, they're really cool!", 3.4],
		8 => ["You'll have a great time with them!", 2.1],
		9 => ["Aww thanks man!", 2.5],
		10 => ["This looks fun!", 1.6],
		11 => ["Eugh, huehuehuah yeah, you'll have lots of fun, huehuehuehue.", 4],
		12 => ["", 9999],
	];
	public var diffText:Array<String> = [
		'An easier version of the mod, enables ghost tapping.',
		'How the mod is meant to be played.',
		'A harder version of the mod. Long notes doesn\'t heal\nand your mistakes hurts you further.\n',
		'please die',
	];
	public var diffString:Array<String> = [
		'monk',
		'survivor',
		'hunter',
		'inv',
	];

	public var difficultyImage:FlxSprite;

	override function create()
	{
		super.create();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		#if DISCORD_RPC
		Discord.changePresence('STORY MENU', 'Main Menu');
		#end

		// freeaaaky
		ForeverTools.resetMenuMusic();

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 575, 0, "SCORE: 49324858", 36);
		scoreText.setFormat(Paths.font('segoe.ttf'), 24, FlxColor.GRAY, CENTER);
		scoreText.alpha = 0;

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 550, 0, "", 32);
		txtWeekTitle.setFormat(Paths.font('segoe.ttf'), 32, FlxColor.WHITE, CENTER);

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFADADAD);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		for (i in 0...Main.gameWeeks.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			weekThing.alpha = 0;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weekCharacters[curWeek][char]);
			weekCharacterThing.antialiasing = true;
			switch (weekCharacterThing.character)
			{
				case 'dad':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
				case 'bf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
					weekCharacterThing.x -= 80;
				case 'gf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
				case 'pico':
					weekCharacterThing.flipX = true;
				case 'parents-christmas':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
			}

			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		//difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		for (i in CoolUtil.difficultyArray)
			sprDifficulty.animation.addByPrefix(i.toLowerCase(), i.toUpperCase());
		sprDifficulty.animation.play('easy');

		difficultyImage = new FlxSprite(0, yellowBG.height + 10);
		difficultyImage.loadGraphic(Paths.image('menus/rainworld/difficulty/${diffString[curDifficulty]}'));
		difficultyImage.antialiasing = true;
		add(difficultyImage);
		changeDifficulty();

		//difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		//difficultySelectors.add(rightArrow);

		trace("Line 150");

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		//add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		subtitleTxt = new FlxText(0, FlxG.height - 24, FlxG.width, "", 20);
		subtitleTxt.setFormat(Paths.font('rw-menu.ttf'), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		subtitleTxt.scrollFactor.set();
		subtitleTxt.screenCenter(X);
		subtitleTxt.borderSize = 1.5;
		add(subtitleTxt);

		// very unprofessional yoshubs!

		updateText();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		var lerpVal = Main.framerateAdjust(0.5);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		scoreText.text = "PERSONAL BEST: " + lerpScore;

		txtWeekTitle.text = diffText[curDifficulty];

		scoreText.screenCenter(X);
		txtWeekTitle.screenCenter(X);

		if (curDifficulty != 3) invSecretTimer = 60;
		invSecretTimer -= 1 * elapsed;

		if (invSecretTimer < 0 && !playedInvSecret) {
			FlxG.sound.play(Paths.sound('menus/inv_secret'));
			playedInvSecret = true;
		}

		if (playedInvSecret) {
			dialogueTimer -= 1 * elapsed;

			subtitleTxt.text = invDialogue[currentPart][0];

			if (dialogueTimer < 0) {
				currentPart++;
				dialogueTimer = invDialogue[currentPart][1];
			}
		}

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.UI_RIGHT_P)
					changeDifficulty(1);
				if (controls.UI_LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			Main.switchState(this, new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('menus/storyStart'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].createCharacter('bfConfirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = Main.gameWeeks[curWeek][0].copy();
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic:String = '-' + CoolUtil.difficultyFromNumber(curDifficulty).toLowerCase();
			diffic = diffic.replace('-normal', '');

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				Main.switchState(this, new PlayState());
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyLength - 1;
		if (curDifficulty > CoolUtil.difficultyLength - 1)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		var difficultyString = CoolUtil.difficultyFromNumber(curDifficulty).toLowerCase();
		sprDifficulty.animation.play(difficultyString);
		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);

		FlxTween.cancelTweensOf(txtWeekTitle);
		FlxTween.cancelTweensOf(scoreText);

		if (intendedScore != 0) {
			FlxTween.tween(scoreText, {"alpha": 1}, 0.25, {ease: FlxEase.linear});
			FlxTween.tween(txtWeekTitle, {"y": 620}, 0.25, {ease: FlxEase.cubeOut});
		} else {
			FlxTween.tween(scoreText, {"alpha": 0}, 0.25, {ease: FlxEase.linear});
			FlxTween.tween(txtWeekTitle, {"y": 575}, 0.25, {ease: FlxEase.cubeOut});
		}
		FlxG.sound.play(Paths.sound('menus/base/scrollMenu'));
		difficultyImage.loadGraphic(Paths.image('menus/rainworld/difficulty/${diffString[curDifficulty]}'));
		difficultyImage.screenCenter(X);
		difficultyImage.y = 500;
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= Main.gameWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = Main.gameWeeks.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('menus/base/scrollMenu'));

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].createCharacter(weekCharacters[curWeek][0], true);
		// grpWeekCharacters.members[1].createCharacter(weekCharacters[curWeek][1]);
		// grpWeekCharacters.members[2].createCharacter(weekCharacters[curWeek][2]);
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = Main.gameWeeks[curWeek][0];
		for (i in stringThing)
			txtTracklist.text += "\n" + CoolUtil.dashToSpace(i);

		txtTracklist.text += "\n"; // pain
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
	}
}
