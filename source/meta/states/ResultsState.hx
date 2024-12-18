package meta.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;

using StringTools;

class ResultsState extends MusicBeatState
{
    var gameCompleted:FlxText;
    var resultsTxt:FlxText;
    var scoreTxt:FlxText;

    var curTime:Float = 0;

    public static var curScore:Int = 0;
    public static var curScoreOG:Int = 0;
    public static var totalMisses:Int = 0;
    public static var totalHit:Float = 0;
    public static var totalNotes:Float = 0;
    public static var inFreeplay:Bool = false;

    public var ratingStuff:Array<Dynamic> = [
		['F', 0.7], //From 20% to 39%
		['E', 0.75], //From 40% to 49%
		['D', 0.8], //From 50% to 59%
		['C', 0.85], //From 60% to 68%
		['B', 0.9], //From 70% to 79%
		['A', 0.95], //From 80% to 89%
		['S', 1], //From 90% to 99%
		['S+', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

    override function create()
        {
            gameCompleted = new FlxText(200, 100, 0, '${inFreeplay ? 'SONG COMPLETED' : 'GAME COMPLETED'}', 20);
            gameCompleted.setFormat(Paths.font(MainMenuState.choosenFont), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            gameCompleted.scrollFactor.set();
            gameCompleted.borderSize = 1.5;
            add(gameCompleted);

            resultsTxt = new FlxText(200, 300, 0, "SCORE\nMISSES\nAVG. ACC\n\nRANK\n", 20);
            resultsTxt.setFormat(Paths.font(MainMenuState.choosenFont), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            resultsTxt.scrollFactor.set();
            resultsTxt.borderSize = 1.5;
            add(resultsTxt);

            scoreTxt = new FlxText(300, 300, 0, "", 20);
            scoreTxt.setFormat(Paths.font(MainMenuState.choosenFont), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            scoreTxt.scrollFactor.set();
            scoreTxt.borderSize = 1.5;
            add(scoreTxt);

            scoreTxt.text = '          ';

            var hibernationScreen = new FlxSprite(0).loadGraphic(Paths.image('menus/me in bedwars'));
            hibernationScreen.scrollFactor.set();
            hibernationScreen.scale.set(0.6,0.6);
            hibernationScreen.screenCenter();
            hibernationScreen.x += 350;
            add(hibernationScreen);

            curScore = PlayState.campaignScore;
            curScoreOG = PlayState.campaignScoreOG;
            totalMisses = PlayState.campaignMisses;
            totalHit = PlayState.campaignNotesHit;
            totalNotes = PlayState.campaignNotesTotal;
            inFreeplay = !PlayState.isStoryMode;

            super.create();
        }

    var timeInt:Int = 0;
    var ratingString:String;
    override function update(elapsed:Float)
	    {
            curTime += 1 * elapsed;

            var ratingPercent = totalHit / totalNotes;

            if (Math.isNaN(ratingPercent)) ratingPercent = 0;

            if (timeInt != Std.int(curTime)) {
                timeInt = Std.int(curTime);

                switch (timeInt) {
                    case 2:
                        scoreTxt.text += '${ClientPrefs.oldScore ? curScoreOG : curScore}\n';
                    case 4:
                        scoreTxt.text += '$totalMisses\n';
                    case 6:
                        scoreTxt.text += Highscore.floorDecimal(ratingPercent * 100, 2) + '%\n';
                    case 8:
                        if(ratingPercent >= 1) {
                            ratingPercent = 1;
                            ratingString = ratingStuff[ratingStuff.length-1][0]; //Uses last string
                        } else {
                            for (i in 0...ratingStuff.length-1) {
                                if(ratingPercent < ratingStuff[i][1]) {
                                    ratingString = ratingStuff[i][0];
                                    break;
                                }
                            }
                        }

                        scoreTxt.text += '\n$ratingString\n';
                    
                    case 12:
                        //scoreTxt.text += '\n\n\nPress ENTER to Continue\n';
                }
            }

            if (curTime < 0) curTime = 0;

            if (FlxG.keys.justPressed.ENTER) exitDumb();

            super.update(elapsed);
        }
    
    function exitDumb() {
        if (inFreeplay) {
            MusicBeatState.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
        } else {
            MusicBeatState.switchState(new StoryMenuState());
        }
        PlayState.usedPractice = false;
        PlayState.usedBotplay = false;
        PlayState.changedDifficulty = false;

        PlayState.campaignScore = 0;
        PlayState.campaignScoreOG = 0;
        PlayState.campaignNotesHit = 0;
        PlayState.campaignNotesTotal = 0;
        PlayState.campaignMisses = 0;
    }
    
}