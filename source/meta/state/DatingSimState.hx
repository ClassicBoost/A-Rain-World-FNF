package meta.state;

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
import meta.MusicBeat.MusicBeatState;
import flixel.ui.FlxButton;
import meta.state.menus.*;
import flixel.ui.FlxSpriteButton;

using StringTools;

class DatingSimState extends MusicBeatState
{
    public var invNames:Array<String> = ['Inv', 'Enot', 'Sofanthiel', 'Gorbo', 'Paincat', '???'];
    public var daText:FlxText;

    var leftPortrait:FlxSprite;
    var rightPortrait:FlxSprite;

    var whichPart:String = 'Start';
    var isDead:Bool = false;

    var button1:FlxButton;
    var button2:FlxButton;
    var button3:FlxButton;
    var button4:FlxButton;
    var button5:FlxButton;

    override function create()
        {
            super.create();
            //PlayState.campaignScore = 0;
            FlxG.mouse.visible = true;

            var whiteBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
	    	add(whiteBG);

            daText = new FlxText(0, FlxG.height - 200, FlxG.width, '', 20);
            daText.setFormat(Paths.font('segoe.ttf'), 20, FlxColor.BLACK, CENTER);
            daText.scrollFactor.set();
            daText.screenCenter(X);
            daText.borderSize = 1.5;
            add(daText);

            leftPortrait = new FlxSprite(200, 100).loadGraphic(Paths.image('dialogue/datingSim/inv/normal'));
            leftPortrait.scrollFactor.set();
            leftPortrait.scale.set(0.6, 0.6);
            add(leftPortrait);
            rightPortrait = new FlxSprite(600, 100).loadGraphic(Paths.image('dialogue/datingSim/nothing'));
            rightPortrait.scrollFactor.set();
            rightPortrait.flipX = true;
            rightPortrait.scale.set(0.6, 0.6);
            add(rightPortrait);

           nextPart('Start');

            FlxG.sound.playMusic(Paths.music('kayava-daycore'));
            FlxG.sound.music.volume = 0.7;
        }

    override function update(elapsed:Float)
	    {
            if (FlxG.keys.justPressed.ESCAPE) {
                Main.switchState(this, new MainMenuState());
                FlxG.mouse.visible = false;
            }
            if (FlxG.keys.justPressed.R) {
                nextPart('reset',true);
            }

            super.update(elapsed);
        }
    
    function nextPart(whereTo:String, ?killsPlayer:Bool = false) {
        remove(button1);
        remove(button2);
        remove(button3);
        remove(button4);
        remove(button5);
        switch (whereTo) {
            case 'Start':
                leftPortrait.loadGraphic(Paths.image('dialogue/datingSim/inv/normal'));
                rightPortrait.loadGraphic(Paths.image('dialogue/datingSim/nothing'));
                var decoyName:String = '';
                var chance:Int = FlxG.random.int(0, invNames.length - 1);
                decoyName = invNames[chance];

                daText.text = 'You seriously had played the entire mod as ${decoyName}.\nAnyway find a mate or die.';
                button3 = new FlxButton(600, FlxG.height - 50, "North", function(){nextPart('North_0');});
                button3.screenCenter(X);

                button1 = new FlxButton(button3.x - 400, FlxG.height - 50, "West", function(){nextPart('West_0');});
                button2 = new FlxButton(button3.x - 200, FlxG.height - 50, "East", function(){nextPart('East_0');});
                button4 = new FlxButton(button3.x + 200, FlxG.height - 50, "South", function(){nextPart('South_0');});
                button5 = new FlxButton(button3.x + 400, FlxG.height - 50, "Down", function(){nextPart('Down_0', true);});
    
                add(button1);
                add(button2);
                add(button3);
                add(button4);
                add(button5);
            case 'Down_0':
                daText.text = "You haven't even found anyone and you just jumped\ndown a pit, good job.";
            case 'reset':
                daText.text = "Yeah, what do you expect pressing that?";
        }

        if (killsPlayer) {
            FlxG.sound.music.volume = 0;
            button1 = new FlxButton(0, FlxG.height - 50, "Restart", function(){nextPart('Start');});
            button1.screenCenter(X);
            add(button1);
            leftPortrait.loadGraphic(Paths.image('dialogue/datingSim/inv/dead'));
        } else {
            FlxG.sound.music.volume = 0.7;
        }
    }
}