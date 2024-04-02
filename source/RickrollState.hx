package;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
#if DISCORD_ALLOWED
import DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.filters.BitmapFilter;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import Conductor.Rating;
import Shaders;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import Note.PreloadedChartNote;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0" || hxCodec == "git")
import hxcodec.flixel.FlxVideo as MP4Handler;
#elseif (hxCodec == "2.6.1")
import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0")
import VideoHandler as MP4Handler;
#else
import vlc.MP4Handler;
#end
#end

using StringTools;

class RickrollState extends MusicBeatState
{
	public var vidSprite:MP4Handler;
	public function startVideo(name:String, ?callback:Void->Void = null)
	{
		#if VIDEOS_ALLOWED
		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			if (callback != null)
				callback();
			else
			return;
		}

		vidSprite = new MP4Handler();
		#if (hxCodec < "3.0.0")
		vidSprite.playVideo(filepath);
		if (callback != null)
			vidSprite.finishCallback = callback;
		else{
			vidSprite.finishCallback = function()
				{
					openfl.system.System.exit(0);
					return;
				}
		}
		#else
		vidSprite.play(filepath);
		if (callback != null)
			vidSprite.onEndReached.add(callback);
		else{
			vidSprite.onEndReached.add(function(){
					vidSprite.dispose();
					openfl.system.System.exit(0);
					return;
				});
		}
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		if (callback != null)
			callback();
		else
		return;
		#end
	}
	override public function create()
	{
							var videoDone:Bool = true;
							vidSprite = new MP4Handler(); // it plays but it doesn't show???
							#if (hxCodec < "3.0.0")
							vidSprite.playVideo(Paths.video('aprilFool'), false, false);
							vidSprite.finishCallback = function()
							{
								videoDone = true;
							};
							#else
							vidSprite.play(Paths.video('aprilFool'));
							vidSprite.onEndReached.add(function(){
								vidSprite.dispose();
								videoDone = true;
							});
							#end
	}
	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE) {
			#if (hxCodec < "3.0.0") vidSprite.finishCallback() #else vidSprite.onEndReached #end;
			if (!FlxG.random.bool(20)) Sys.exit(0);
			else {
				vidSprite.dispose(); //So that it doesn't continue playing anyway
				FlxG.switchState(TitleState.new);
				FlashingState.rickroll = false;
			}
		}
	}
}