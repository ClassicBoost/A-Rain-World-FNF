package backend;

import haxe.Json;

typedef TranslationThing =
{
    var translation_name:String;

    var score_info:String;
    var accuracy_info:String;
    var misses_info:String;
    var rank_info:String;
    var dead_info:String;
    var botplay_score:String;
    var charting_mode:String;

    var volume_txt:String;
    var volume_max:String;

    var version_txt:String;
    var mod_info:String;
    var base_mod:String;
    var experimental_active:String;

    var sick_judge:String;
    var good_judge:String;
    var bad_judge:String;
    var shit_judge:String;
    var miss_judge:String;
    var note_counter:String;

    var freeplay_personal:String;
}

class Translation {
    // boo
    public static var scoreInfo:String = 'Score';
    public static var accuracyInfo:String = 'Accuracy';
    public static var missesInfo:String = 'Combo Breaks';
    public static var rankInfo:String = 'Rank';
    public static var deadInfo:String = 'died';
    public static var botplayScore:String = 'Used Botplay - Score not counted.';
    public static var chartingMode:String = 'Chart Editor used - Score not counted.';
    
    public static var volumeTxt:String = 'VOLUME';
    public static var volumeMax:String = 'MAX';

    public static var versionTxt:String = 'Psych Forever';
    public static var modInfo:String = 'Mod';
    public static var baseMod:String = 'Base Engine';
    public static var experiemntalActive:String = 'EXPERIMENTAL FEATURES ENABLED';

    public static var sickJudge:String = 'Sick';
    public static var goodJudge:String = 'Good';
    public static var badJudge:String = 'Bad';
    public static var shitJudge:String = 'Shit';
    public static var missJudge:String = 'Miss';

    public static var noteCounter:String = 'Notes Hit';

    public static var freeplayPersonal:String = 'PERSONAL BEST';

    public static var translationShit:TranslationThing;

    public static function updateText() {
        translationShit = cast Json.parse(Paths.getTextFromFile('translations/${ClientPrefs.language}.json'));

        scoreInfo = translationShit.score_info;
        accuracyInfo = translationShit.accuracy_info;
        missesInfo = translationShit.misses_info;
        rankInfo = translationShit.rank_info;
        deadInfo = translationShit.dead_info;
        botplayScore = translationShit.botplay_score;
        chartingMode = translationShit.charting_mode;
        volumeTxt = translationShit.volume_txt;
        volumeMax = translationShit.volume_max;
        versionTxt = translationShit.version_txt;
        modInfo = translationShit.mod_info;
        baseMod = translationShit.base_mod;
        experiemntalActive = translationShit.experimental_active;
        sickJudge = translationShit.sick_judge;
        goodJudge = translationShit.good_judge;
        badJudge = translationShit.bad_judge;
        shitJudge = translationShit.shit_judge;
        missJudge = translationShit.miss_judge;
        freeplayPersonal = translationShit.freeplay_personal;
        noteCounter = translationShit.note_counter;
    }
}