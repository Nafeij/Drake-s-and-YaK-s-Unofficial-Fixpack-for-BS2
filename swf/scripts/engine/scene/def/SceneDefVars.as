package engine.scene.def
{
   import engine.anim.def.AnimLibraryVars;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.def.BattleBoardDef;
   import engine.battle.board.def.BattleBoardDefVars;
   import engine.battle.board.def.BattleBoardTipsDef;
   import engine.battle.board.def.BattleBoardTriggerDefList;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   import engine.entity.def.EntityClassDefList;
   import engine.landscape.def.LandscapeDef;
   import engine.landscape.def.LandscapeDefVars;
   import engine.landscape.def.LandscapeLayerDef;
   import engine.landscape.model.Landscape;
   import engine.saga.happening.HappeningDefBagVars;
   import engine.saga.happening.HappeningDefVars;
   import engine.sound.def.SoundLibraryVars;
   
   public class SceneDefVars extends SceneDef
   {
      
      public static const schema:Object = {
         "name":"SceneDefVars",
         "type":"object",
         "properties":{
            "ambientParameter":{
               "type":"number",
               "optional":true
            },
            "landscape":{"type":LandscapeDefVars.schema},
            "boards":{
               "type":"array",
               "items":BattleBoardDefVars.schema,
               "optional":true
            },
            "soundLibrary":{
               "type":SoundLibraryVars.schema,
               "optional":true
            },
            "anims":{
               "type":AnimLibraryVars.schema,
               "optional":true
            },
            "cameraStart":{
               "type":PointVars.schema,
               "optional":true
            },
            "cameraAnchor":{
               "type":PointVars.schema,
               "optional":true
            },
            "cameraAnchorSpeed":{
               "type":"number",
               "optional":true
            },
            "cameraAnchorOnce":{
               "type":"boolean",
               "optional":true
            },
            "cameraDrift":{
               "type":"number",
               "optional":true
            },
            "cameraMinWidth":{"type":"number"},
            "cameraMaxWidth":{"type":"number"},
            "cameraMinHeight":{"type":"number"},
            "cameraMaxHeight":{"type":"number"},
            "cinemascope":{
               "type":"boolean",
               "optional":true
            },
            "reverb":{
               "type":"string",
               "optional":true
            },
            "happenings":{
               "type":"array",
               "items":HappeningDefVars.schema,
               "optional":true
            },
            "killMusic":{
               "type":"boolean",
               "optional":true
            },
            "music":{
               "type":"string",
               "optional":true
            },
            "tutorial":{
               "type":"string",
               "optional":true
            },
            "loadAudio":{
               "type":"boolean",
               "optional":true
            },
            "audioUrl":{
               "type":"string",
               "optional":true
            },
            "battleMusicUrl":{
               "type":"string",
               "optional":true
            },
            "loadBattleMusic":{
               "type":"boolean",
               "optional":true
            },
            "hideBannerButton":{
               "type":"boolean",
               "optional":true
            },
            "hideHelpButton":{
               "type":"boolean",
               "optional":true
            },
            "weatherDisabled":{
               "type":"boolean",
               "optional":true
            },
            "inputDisabled":{
               "type":"boolean",
               "optional":true
            },
            "tiltDisabled":{
               "type":"boolean",
               "optional":true
            },
            "disableAdjustBoundary":{
               "type":"boolean",
               "optional":true
            },
            "tips":{
               "type":BattleBoardTipsDef.schema,
               "optional":true
            },
            "showTrainingExitButton":{
               "type":"boolean",
               "optional":true
            },
            "split_happenings":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function SceneDefVars(param1:String)
      {
         super(param1);
      }
      
      public static function save(param1:SceneDef, param2:Boolean = false) : SceneDefSaveInfo
      {
         var sdsi:SceneDefSaveInfo = null;
         var rhs:SceneDef = param1;
         var maintain_legacy:Boolean = param2;
         try
         {
            sdsi = new SceneDefSaveInfo(rhs,maintain_legacy);
            return sdsi;
         }
         catch(e:Error)
         {
            throw new ArgumentError("Failed to save scene: " + rhs.url + "\n" + e.getStackTrace());
         }
      }
      
      public static function toJson(param1:SceneDef) : Object
      {
         var _loc3_:BattleBoardDef = null;
         var _loc2_:Object = {
            "cameraMinWidth":param1.cameraMinWidth,
            "cameraMaxWidth":param1.cameraMaxWidth,
            "cameraMinHeight":param1.cameraMinHeight,
            "cameraMaxHeight":param1.cameraMaxHeight
         };
         if(Boolean(param1.happenings) && param1.happenings.numHappenings > 0)
         {
            _loc2_.split_happenings = true;
         }
         if(param1.showTrainingExitButton)
         {
            _loc2_.showTrainingExitButton = param1.showTrainingExitButton;
         }
         if(param1.xmusic)
         {
            _loc2_.music = param1.xmusic;
         }
         if(param1.tutorial)
         {
            _loc2_.tutorial = param1.tutorial;
         }
         if(param1.killMusic)
         {
            _loc2_.killMusic = true;
         }
         if(param1.anims != null)
         {
            _loc2_.anims = AnimLibraryVars.save(param1.anims);
         }
         if(param1.cinemascope)
         {
            _loc2_.cinemascope = param1.cinemascope;
         }
         _loc2_.cameraAnchorSpeed = param1.cameraAnchorSpeed;
         _loc2_.cameraDrift = param1.cameraDrift;
         if(param1.cameraAnchor)
         {
            _loc2_.cameraAnchor = PointVars.save(param1.cameraAnchor);
         }
         if(param1.cameraStart)
         {
            _loc2_.cameraStart = PointVars.save(param1.cameraStart);
         }
         if(Boolean(param1.boards) && param1.boards.length > 0)
         {
            _loc2_.boards = [];
            for each(_loc3_ in param1.boards)
            {
               _loc2_.boards.push(BattleBoardDefVars.save(_loc3_));
            }
         }
         if(param1.soundLibrary)
         {
            _loc2_.soundLibrary = SoundLibraryVars.save(param1.soundLibrary);
         }
         _loc2_.landscape = LandscapeDefVars.save(param1.landscape as LandscapeDef);
         _loc2_.reverb = "";
         if(param1.reverb != null)
         {
            _loc2_.reverb = param1.reverb;
         }
         if(param1.loadAudio)
         {
            _loc2_.loadAudio = true;
         }
         if(param1._audioUrl)
         {
            _loc2_.audioUrl = param1._audioUrl;
         }
         if(param1._battleMusicUrl)
         {
            _loc2_.battleMusicUrl = param1._battleMusicUrl;
         }
         if(param1.loadBattleMusic)
         {
            _loc2_.loadBattleMusic = true;
         }
         if(param1.hideBannerButton)
         {
            _loc2_.hideBannerButton = param1.hideBannerButton;
         }
         if(param1.hideHelpButton)
         {
            _loc2_.hideHelpButton = param1.hideHelpButton;
         }
         if(param1.weatherDisabled)
         {
            _loc2_.weatherDisabled = param1.weatherDisabled;
         }
         if(param1.inputDisabled)
         {
            _loc2_.inputDisabled = param1.inputDisabled;
         }
         if(param1.tiltDisabled)
         {
            _loc2_.tiltDisabled = param1.tiltDisabled;
         }
         if(param1.disableAdjustBoundary)
         {
            _loc2_.disableAdjustBoundary = param1.disableAdjustBoundary;
         }
         if(param1.tips)
         {
            _loc2_.tips = param1.tips.toJson();
         }
         if(param1.cameraAnchorOnce)
         {
            _loc2_.cameraAnchorOnce = param1.cameraAnchorOnce;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:Locale, param3:EntityClassDefList, param4:BattleAbilityDefFactory, param5:BattleBoardTriggerDefList, param6:ILogger, param7:Boolean) : SceneDefVars
      {
         var forceWalkableDeployments:Boolean = false;
         var boardVars:Object = null;
         var bb:BattleBoardDef = null;
         var bblayer:LandscapeLayerDef = null;
         var vars:Object = param1;
         var locale:Locale = param2;
         var classes:EntityClassDefList = param3;
         var abilities:BattleAbilityDefFactory = param4;
         var triggers:BattleBoardTriggerDefList = param5;
         var logger:ILogger = param6;
         var stripHappenings:Boolean = param7;
         EngineJsonDef.validateThrow(vars,schema,logger);
         if(vars.anims)
         {
            anims = new AnimLibraryVars(name,vars.anims,BattleFacing,logger,null,null);
         }
         showTrainingExitButton = vars.showTrainingExitButton;
         _landscape = new LandscapeDefVars(this,vars.landscape,logger,anims);
         _landscape.resolveLandscapeDef();
         if(vars.cameraAnchor)
         {
            _cameraAnchor = PointVars.parse(vars.cameraAnchor,logger,_cameraAnchor);
         }
         if(vars.cameraStart)
         {
            _cameraStart = PointVars.parse(vars.cameraStart,logger,_cameraStart);
         }
         if(vars.cameraDrift != undefined)
         {
            cameraDrift = vars.cameraDrift;
         }
         if(vars.cameraAnchorSpeed != undefined)
         {
            cameraAnchorSpeed = vars.cameraAnchorSpeed;
         }
         _cameraAnchorOnce = BooleanVars.parse(vars.cameraAnchorOnce,_cameraAnchorOnce);
         if(vars.soundLibrary != undefined)
         {
            soundLibrary = new SoundLibraryVars(this.name,vars.soundLibrary,logger);
         }
         cameraMinWidth = vars.cameraMinWidth;
         cameraMaxWidth = vars.cameraMaxWidth;
         cameraMinHeight = vars.cameraMinHeight;
         cameraMaxHeight = vars.cameraMaxHeight;
         cinemascope = BooleanVars.parse(vars.cinemascope);
         reverb = vars.reverb;
         split_happenings = vars.split_happenings;
         if(vars.happenings)
         {
            happenings = new HappeningDefBagVars(name,this).fromJson(vars.happenings,logger,stripHappenings);
            if(!split_happenings)
            {
               legacy_happenings = true;
               logger.info("Scene importing legacy happenings for " + name);
            }
         }
         killMusic = BooleanVars.parse(vars.killMusic,killMusic);
         xmusic = vars.music;
         tutorial = vars.tutorial;
         loadAudio = vars.loadAudio;
         audioUrl = vars.audioUrl;
         loadBattleMusic = vars.loadBattleMusic;
         battleMusicUrl = vars.battleMusicUrl;
         hideBannerButton = vars.hideBannerButton;
         hideHelpButton = vars.hideHelpButton;
         weatherDisabled = vars.weatherDisabled;
         inputDisabled = vars.inputDisabled;
         tiltDisabled = vars.tiltDisabled;
         disableAdjustBoundary = vars.disableAdjustBoundary;
         try
         {
            if(vars.boards)
            {
               forceWalkableDeployments = !Landscape.EDITOR_MODE;
               for each(boardVars in vars.boards)
               {
                  bb = new BattleBoardDefVars(this,boardVars,logger,locale,classes,abilities,triggers,forceWalkableDeployments);
                  boards.push(bb);
                  bblayer = landscape.getLayer(bb.layer) as LandscapeLayerDef;
                  if(bblayer)
                  {
                     bblayer.always = true;
                  }
               }
            }
         }
         catch(e:Error)
         {
            logger.error("Failed to load SceneDefVars boards: " + e + ": " + e.getStackTrace());
            throw new ArgumentError("Failed to load SceneDefVars boards: " + e);
         }
         if(vars.tips)
         {
            this.tips = new BattleBoardTipsDef().fromJson(vars.tips,logger);
         }
         return this;
      }
   }
}
