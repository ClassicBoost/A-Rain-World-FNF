import backend.Paths;
import editors.*;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.background.*;
import backend.*;
import meta.*;
import meta.states.*;
import meta.substates.*;
import meta.states.menus.*;
import meta.data.*;
import meta.data.dependency.*;
import gameObjects.userInterface.dialogue.*;
import gameObjects.userInterface.menus.*;
import shaders.*;
import backend.Translation;
import meta.MusicBeatState;
import meta.MusicBeatSubstate;
import gameObjects.userInterface.notes.*;
import backend.Achievements.AchievementObject;
import meta.data.StageData.StageFile;
import meta.data.Song.SwagSong;
import meta.data.Section.SwagSection;
import backend.Controls.Control;
import meta.data.Conductor.BPMChangeEvent;
import gameObjects.userInterface.dialogue.DialogueBoxPsych.DialogueFile;
import meta.lua.*;
import meta.lua.FunkinLua;
#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end