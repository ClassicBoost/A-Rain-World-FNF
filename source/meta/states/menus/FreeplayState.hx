package meta.states.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import flixel.tweens.FlxEase;
import haxe.Json;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	public static var disableControls:Bool = false;

	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;

	var allowBop:Bool = false;

	var trackPlaying:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	public var bgThing:FlxTypedGroup<FlxSprite>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	public static var inFreeplay:Bool = false;

	var barText:FlxText;

	var switched:String = '';

	public var hasDifficulties:Bool = true;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		MainMenuState.loadMenuJson();

		inFreeplay = true;

		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3) {
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.setDirectoryFromWeek();

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}

		Conductor.changeBPM(100);

		persistentUpdate = true;
		persistentDraw = true;

		// LOAD MUSIC

		// LOAD CHARACTERS
		
		bgThing = new FlxTypedGroup<FlxSprite>();
		add(bgThing);

		bg = new FlxSprite().loadGraphic(Paths.image('menus/${MainMenuState.stupidfreeplayBG}'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bgThing.add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font(MainMenuState.choosenFont), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 1.5;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, (hasDifficulties ? 150 : 40), 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.borderSize = 1.5;
	//	add(diffText);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		add(sprDifficultyGroup);

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var sprDifficulty:FlxSprite = new FlxSprite(scoreText.x, scoreText.y + 50).loadGraphic(Paths.image('menus/freeplay/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficultyGroup.add(sprDifficulty);
		}

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		barText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "", 18);
		barText.setFormat(Paths.font(MainMenuState.choosenFont), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		barText.borderSize = 1.5;
		barText.scrollFactor.set();
		add(barText);

		changeSelection();
		changeDiff();
		super.create();
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (allowBop) Conductor.songPosition = FlxG.sound.music.time;

		barText.screenCenter(X);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = '${Translation.freeplayPersonal}: ' + lerpScore + ' (' + Highscore.floorDecimal(lerpRating * 100, 2) + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!disableControls) {
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if (controls.UI_LEFT_P)
				changeDiff(-1);
			if (controls.UI_RIGHT_P)
				changeDiff(1);

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{

				changeSelection(-shiftMult * FlxG.mouse.wheel);
				changeDiff();
			}

			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				inFreeplay = false;
				FlxG.sound.play(Paths.sound('menus/base/cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}
		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

		/*	if((!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop)))	&& !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
				curDifficulty = 1;
				changeDiff();
			}*/

		if ((accepted || space || FlxG.mouse.justPressed) && !disableControls)
		{
			
			#if !html5 if((!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
				poop = songLowercase;
				curDifficulty = 1;
				changeDiff(0); // just show it shows Normal instead of being stuck
				trace('Couldnt find file');
				barText.text = 'Song is Missing or wrong difficulty. (Note: Charts belong in the songs folder)';
				FlxG.sound.play(Paths.sound('ANGRY'), 0.7);
			} else {#end
				destroyFreeplayVocals();

				Paths.currentModDirectory = songs[curSelected].folder;

				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				PlayState.storyWeek = songs[curSelected].week;
				#if PRELOAD_ALL
				if (space && instPlaying != curSelected) {
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				trackPlaying = true;
		
				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				if (FlxG.keys.pressed.SHIFT) vocals.volume = 0.7;
				else vocals.volume = 0;
				instPlaying = curSelected;

				barText.text = 'Track Playing: $songLowercase' + (vocals.volume == 0 ? ' (INST ONLY)' : '');

				Conductor.mapBPMChanges(PlayState.SONG);
				Conductor.changeBPM(PlayState.SONG.bpm);

				allowBop = true;
				
				} else #end if (accepted || FlxG.mouse.justPressed) {
					if (songLowercase == 'pictures-of-the-past' && curDifficulty == 3) {

					} else {
					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
					if(colorTween != null) {
						colorTween.cancel();
					}
					inFreeplay = false;
					LoadingState.loadAndSwitchState(new PlayState());
	
					FlxG.sound.music.volume = 0;
					}
				}
			#if !html5 } #end
			trace(poop);
		}
		else if(controls.RESET)
		{
			disableControls = true;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('menus/base/scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = (MainMenuState.invUnlocked == 0 ? 3 : CoolUtil.difficultyStuff.length-1);
		if (curDifficulty >= (MainMenuState.invUnlocked == 0 ? 3 : CoolUtil.difficultyStuff.length))
			curDifficulty = 0;
		
		sprDifficultyGroup.forEach(function(spr:FlxSprite) {
			spr.visible = false;
			if(curDifficulty == spr.ID) {
				spr.visible = true;
				spr.alpha = 0;
				FlxTween.tween(spr, {alpha: 1}, 0.07);
			}
		});

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('menus/base/scrollMenu'), 0.4);

		curSelected += change;

		#if PRELOAD_ALL
		barText.text = "Press SPACE to listen to this Song (SHIFT + SPACE for Vocals) / Press RESET to Reset your Score and Accuracy.";
		#else
		barText.text = "Press RESET to Reset your Score and Accuracy.";
		#end

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
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

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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
		changeDiff();
		Paths.currentModDirectory = songs[curSelected].folder;
		if (ClientPrefs.loadModMenu) updateShit();
	}

	public var selectedMod = '';
	
	public function updateShit() {
		#if MODS_ALLOWED
		// It should really only care about the modpacks as assets would juts be well. Already loaded lmao.
		if ((sys.FileSystem.exists(Paths.modsImages('menus/${MainMenuState.stupidfreeplayBG}')) && OpenFlAssets.exists(Paths.image('menus/${MainMenuState.stupidfreeplayBG}'))) && Paths.currentModDirectory != selectedMod) {
			remove(bg);
			// can you just not change background images without actually leaving and re-entering the state?
			Paths.destroyLoadedImages(true);
			bg = new FlxSprite().loadGraphic(Paths.image('menus/${MainMenuState.stupidfreeplayBG}'));
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			bgThing.add(bg);
		}
		else
			bg.loadGraphic(Paths.image('menus/bg'));
		
		selectedMod = Paths.currentModDirectory;
		#end
	}

	override function beatHit() {
		super.beatHit();

		if (allowBop) FlxG.camera.zoom = 1.05;

		FlxTween.cancelTweensOf(FlxG.camera);
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.3, {ease: FlxEase.quadOut});
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;

		sprDifficultyGroup.forEach(function(spr:FlxSprite) {
			spr.x = Std.int(scoreBG.x + (scoreBG.width / 2));
			spr.x -= spr.width / 2;
		});
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
