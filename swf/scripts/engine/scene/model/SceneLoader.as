package engine.scene.model
{
   import engine.battle.board.def.BattleBoardDef;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleBoard_Spawn;
   import engine.battle.music.BattleMusicDef;
   import engine.core.logging.ILogger;
   import engine.core.util.StableJson;
   import engine.core.util.StringUtil;
   import engine.entity.def.EntityListDefVars;
   import engine.landscape.def.ClickMask;
   import engine.landscape.def.ILandscapeLayerDef;
   import engine.landscape.def.ILandscapeSpriteDef;
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.resource.ResourceMonitor;
   import engine.resource.def.DefResource;
   import engine.resource.def.DefWrangler;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.convo.Convo;
   import engine.saga.vars.IBattleEntityProvider;
   import engine.scene.SceneContext;
   import engine.scene.def.SceneAudioDef;
   import engine.scene.def.SceneAudioDefVars;
   import engine.scene.def.SceneDef;
   import engine.scene.def.SceneDefVars;
   import engine.scene.view.SceneViewSprite;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import tbs.srv.battle.data.BattlePartyData;
   import tbs.srv.battle.data.client.BattleCreateData;
   
   public class SceneLoader
   {
      
      public static var aboutToLoadUrl:String;
      
      private static var _cleanupQueue:SceneLoader;
       
      
      public var _url:String;
      
      public var def:SceneDef;
      
      public var scene:Scene;
      
      public var viewSprite:SceneViewSprite;
      
      public var monitor:ResourceMonitor;
      
      public var resource:DefResource;
      
      public var completeCallback:Function;
      
      public var context:SceneContext;
      
      public var finished:Boolean;
      
      public var ok:Boolean;
      
      private var battleCreateData:BattleCreateData;
      
      private var battleOrder:int;
      
      private var isOnline:Boolean;
      
      private var opponent:BattlePartyData;
      
      public var convo:Convo;
      
      public var happeningId:String;
      
      public var view_factory:Function;
      
      public var setupLocalPartyCallback:Function;
      
      public var travel_locator:TravelLocator;
      
      public var fallData:Travel_FallData;
      
      public var stripHappenings:Boolean;
      
      public var battleMusicDefUrl:String;
      
      public var battleMusicOverride:Boolean;
      
      private var battle_vitalities:String;
      
      public var cleanedup:Boolean;
      
      public var logger:ILogger;
      
      public var battle_info:SceneLoaderBattleInfo;
      
      public var keep_json:Boolean;
      
      public var id:String;
      
      private var ownsDef:Boolean;
      
      private var audioDefWrangler:DefWrangler;
      
      private var battleMusicDefWrangler:DefWrangler;
      
      private var creatingSprite:Boolean;
      
      private var _checkFinishedFailed:Boolean;
      
      public function SceneLoader(param1:String, param2:SceneContext, param3:Function, param4:Function, param5:BattlePartyData, param6:BattleCreateData, param7:int, param8:Boolean, param9:Convo, param10:String, param11:SceneLoaderBattleInfo, param12:TravelLocator, param13:Travel_FallData, param14:Boolean, param15:String, param16:Boolean, param17:String)
      {
         super();
         if(!param2)
         {
            throw new ArgumentError("no context for sceneloader");
         }
         aboutToLoadUrl = null;
         this.monitor = new ResourceMonitor("SL " + param1,param2.logger,this.resourceMonitorHandler);
         this.opponent = param5;
         this._url = param1;
         this.id = StringUtil.getBasename(this._url);
         this.context = param2;
         this.completeCallback = param3;
         this.battleOrder = param7;
         this.battleCreateData = param6;
         this.isOnline = param8;
         this.convo = param9;
         this.happeningId = param10;
         this.battle_info = param11;
         this.setupLocalPartyCallback = param4;
         this.travel_locator = param12;
         this.fallData = param13;
         this.stripHappenings = param14;
         this.battleMusicDefUrl = param15;
         this.battleMusicOverride = param16;
         this.battle_vitalities = param17;
         this.logger = param2.logger;
         if(!this.battle_info)
         {
            this.battle_info = new SceneLoaderBattleInfo();
         }
      }
      
      public static function queue_addForCleanup(param1:SceneLoader) : void
      {
         if(_cleanupQueue)
         {
            _cleanupQueue.cleanup();
         }
         _cleanupQueue = param1;
      }
      
      public static function queue_performCleanup() : void
      {
         queue_addForCleanup(null);
      }
      
      public function checkCleanup() : void
      {
         if(SceneLoader.aboutToLoadUrl == this.url)
         {
            SceneLoader.queue_addForCleanup(this);
         }
         else
         {
            this.cleanup();
         }
      }
      
      public function toString() : String
      {
         return StringUtil.getBasename(this._url);
      }
      
      public function pause() : void
      {
         if(this.scene)
         {
            this.scene.pause();
         }
      }
      
      public function resume() : void
      {
         if(this.scene)
         {
            this.scene.resume();
         }
      }
      
      public function cleanup() : void
      {
         this.cleanedup = true;
         if(this.monitor)
         {
            this.monitor.cleanup();
            this.monitor = null;
         }
         if(this.viewSprite)
         {
            try
            {
               this.viewSprite.cleanup();
               this.viewSprite = null;
            }
            catch(e:Error)
            {
               logger.error("Failed to cleanup SceneViewSprite for " + this + "\n" + e.getStackTrace());
            }
         }
         if(this.scene)
         {
            this.scene.removeEventListener(Scene.EVENT_AUDIO_READY,this.sceneAudioReadyHandler);
            this.scene.removeEventListener(Scene.EVENT_HAPPENING_AUDIO_READY,this.sceneAudioReadyHandler);
            this.scene.removeEventListener(Scene.EVENT_AUDIO_READY,this.sceneAudioReadyHandler);
            this.scene.removeEventListener(Scene.EVENT_BATTLE_MUSIC_READY,this.sceneAudioReadyHandler);
            this.scene.cleanup();
            this.scene = null;
         }
         if(this.resource)
         {
            this.resource.removeResourceListener(this.defrCompleteHandler);
            this.resource.release();
            this.resource = null;
         }
         if(this.audioDefWrangler)
         {
            this.audioDefWrangler.cleanup();
            this.audioDefWrangler = null;
         }
         if(this.battleMusicDefWrangler)
         {
            this.battleMusicDefWrangler.cleanup();
            this.battleMusicDefWrangler = null;
         }
         if(this.def)
         {
            if(this.ownsDef)
            {
               this.def.cleanup();
            }
            this.def = null;
         }
         this.context = null;
         this.completeCallback = null;
         this.battleCreateData = null;
         this.convo = null;
         this.setupLocalPartyCallback = null;
         this.view_factory = null;
         this.opponent = null;
      }
      
      private function resourceMonitorHandler(param1:ResourceMonitor) : void
      {
         this.checkFinished();
      }
      
      public function load(param1:SceneDef, param2:Boolean) : void
      {
         this.ownsDef = param2;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SceneLoader.load " + this._url + " owns=" + param2);
         }
         if(this.context.saga)
         {
            this.context.saga.scenePreprocessor.handleScenePreprocessing(this.id,this.scenePreprocessorHandler);
            return;
         }
         this._beginLoadingDef();
      }
      
      private function scenePreprocessorHandler() : void
      {
         if(!this.cleanedup)
         {
            this._beginLoadingDef();
         }
      }
      
      private function _beginLoadingDef() : void
      {
         this.context.resman.addMonitor(this.monitor);
         if(this.def)
         {
            this.def = this.def;
            this.loadFromDef();
         }
         else
         {
            this.resource = this.context.resman.getResource(this.url,DefResource) as DefResource;
            this.resource.addResourceListener(this.defrCompleteHandler);
         }
      }
      
      private function loadFromDef() : void
      {
         var board_id:String = null;
         var bi:int = 0;
         var bbs:Array = null;
         var bbsi:int = 0;
         var board:BattleBoardDef = null;
         var b:BattleBoard = null;
         var bs:BattleBoard_Spawn = null;
         var opponentDeployment:String = null;
         var isAlly:Boolean = false;
         var remote_eld:Object = null;
         var remote_party:EntityListDefVars = null;
         var vitalitiesArgv:Array = null;
         var vitalitiesDict:Dictionary = null;
         var vid:String = null;
         var slash:int = 0;
         var sku:String = null;
         var murl:String = null;
         if(this.cleanedup)
         {
            return;
         }
         try
         {
            this.scene = new Scene(this.def,this.context,this.battleCreateData,this.battleOrder,this.travel_locator,this.fallData);
            this.scene.addEventListener(Scene.EVENT_AUDIO_READY,this.sceneAudioReadyHandler);
            this.scene.addEventListener(Scene.EVENT_HAPPENING_AUDIO_READY,this.sceneAudioReadyHandler);
            this.scene.addEventListener(Scene.EVENT_AUDIO_READY,this.sceneAudioReadyHandler);
            this.scene.addEventListener(Scene.EVENT_BATTLE_MUSIC_READY,this.sceneAudioReadyHandler);
            this.scene.convo = this.convo;
            board_id = this.battle_info.battle_board_id;
            if(this.def.boards.length > 0)
            {
               if(board_id == "*")
               {
                  bi = Math.round(this.context.rng.nextNumber() * (this.def.boards.length - 1));
                  board_id = this.def.boards[bi].id;
                  this.logger.info("SceneLoader random board [" + board_id + "]");
               }
               else if(Boolean(board_id) && board_id.indexOf(",") > 0)
               {
                  bbs = board_id.split(",");
                  if(Boolean(bbs) && bbs.length > 0)
                  {
                     bbsi = Math.round(this.context.rng.nextNumber() * (bbs.length - 1));
                     board_id = bbs[bbsi];
                     this.logger.info("SceneLoader random board [" + board_id + "]");
                  }
               }
            }
            if(board_id)
            {
               board = this.def.getBoard(board_id);
               if(!board)
               {
                  this.logger.error("SceneLoader no such board [" + board_id + "] for [" + this.url + "]");
               }
               else
               {
                  b = this.scene.prepareBoard(board_id,this.battle_info.scenarioDef,this.isOnline,this.battle_info.battle_spawn_tags);
                  if(this.setupLocalPartyCallback != null)
                  {
                     this.setupLocalPartyCallback(b,this.battle_info.battle_deployment_area);
                  }
                  bs = b._spawn;
                  if(this.opponent)
                  {
                     opponentDeployment = b.def.getDeploymentAreaIdByIndex(this.opponent.party_index);
                     isAlly = false;
                     remote_eld = {"defs":this.opponent.defs};
                     remote_party = new EntityListDefVars(this.context.locale,this.logger).fromJson(remote_eld,this.logger,this.context.abilities,this.context.classes,this.context.saga as IBattleEntityProvider,true,this.context.itemDefs);
                     b.addRemoteParty(this.opponent.display_name,this.opponent.user.toString(),this.opponent.team,opponentDeployment,remote_party,this.opponent.timer,isAlly);
                     bs.shouldSpawnAi = false;
                  }
                  bs._bucket = this.battle_info.battle_bucket;
                  bs._bucket_quota = this.battle_info.battle_bucket_quota;
                  bs._bucket_deployment = this.battle_info.battle_bucket_deployment;
                  if(this.battle_vitalities)
                  {
                     vitalitiesArgv = this.battle_vitalities.split(",");
                     vitalitiesDict = new Dictionary();
                     for each(vid in vitalitiesArgv)
                     {
                        vitalitiesDict[vid] = true;
                     }
                     b.setVitalities(vitalitiesDict);
                  }
                  b.loadSnapshot(this.battle_info.snap);
                  b.enabled = true;
                  if(b.error)
                  {
                     this.logger.error("SceneLoader FAILED TO LOAD BOARD " + this.def.url);
                     this.abort();
                     return;
                  }
                  this.scene.focusedBoard = b;
               }
            }
            this.ok = true;
            if(this.context.soundDriver)
            {
               if(this.def.loadAudio)
               {
                  this.audioDefWrangler = new DefWrangler(this.def.audioUrl,this.logger,this.context.resman,this.audioLoadedHandler);
                  this.audioDefWrangler.load();
               }
               if(Boolean(this.battleMusicDefUrl) && (this.battleMusicOverride || !this.def.loadBattleMusic))
               {
                  this.battleMusicDefWrangler = new DefWrangler(this.battleMusicDefUrl,this.logger,this.context.resman,this.battleMusicLoadedHandler);
                  this.battleMusicDefWrangler.load();
               }
               else if(this.def.loadBattleMusic)
               {
                  this.battleMusicDefWrangler = new DefWrangler(this.def.battleMusicUrl,this.logger,this.context.resman,this.battleMusicLoadedHandler);
                  this.battleMusicDefWrangler.load();
               }
               else if(!this.def.xmusic && this.def.boards && this.def.boards.length > 0)
               {
                  if(this._url)
                  {
                     slash = this._url.indexOf("/");
                     if(slash > 0)
                     {
                        sku = this._url.substring(0,slash);
                        murl = sku + "/scene/battle/music/default.btlmusic.json.z";
                        this.battleMusicDefWrangler = new DefWrangler(murl,this.logger,this.context.resman,this.battleMusicLoadedHandler);
                        this.battleMusicDefWrangler.load();
                     }
                  }
               }
            }
            this.checkFinished();
            return;
         }
         catch(e:Error)
         {
            context.logger.error("SceneLoader.loadFromDef failed to load Scene [" + url + "]: " + e + " " + e.getStackTrace());
            this.abort();
            return;
         }
      }
      
      private function audioLoadedHandler(param1:DefWrangler) : void
      {
         var _loc2_:SceneAudioDef = null;
         if(!this.def)
         {
            return;
         }
         if(this.audioDefWrangler.vars)
         {
            _loc2_ = new SceneAudioDefVars(this.def).fromJson(this.audioDefWrangler.vars,this.logger);
            _loc2_.url = param1.url;
            if(this.keep_json)
            {
               _loc2_.loadedJson = StableJson.stringify(this.audioDefWrangler.vars,null,"\t");
            }
            this.def.audio = _loc2_;
         }
         this.audioDefWrangler.cleanup();
         this.audioDefWrangler = null;
         this.checkFinished();
      }
      
      private function battleMusicLoadedHandler(param1:DefWrangler) : void
      {
         var _loc2_:BattleMusicDef = null;
         if(this.battleMusicDefWrangler.vars)
         {
            _loc2_ = new BattleMusicDef().fromJson(this.battleMusicDefWrangler.vars,this.logger);
            _loc2_.url = param1.url;
            this.def.battleMusic = _loc2_;
         }
         this.battleMusicDefWrangler.cleanup();
         this.battleMusicDefWrangler = null;
         this.checkFinished();
      }
      
      private function sceneAudioReadyHandler(param1:Event) : void
      {
         this.checkFinished();
      }
      
      protected function defrCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         var fn:String = null;
         var event:ResourceLoadedEvent = param1;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SceneLoader.defrCompleteHandler " + this.resource + " ok=" + this.resource.ok);
         }
         this.resource.removeResourceListener(this.defrCompleteHandler);
         if(!this.resource.ok)
         {
            this.logger.error("SceneLoader.defrCompleteHandler FAILED " + this.resource);
            if(this.completeCallback != null)
            {
               this.completeCallback(this);
            }
            return;
         }
         try
         {
            fn = StringUtil.getFilename(this.resource.url);
            this.def = new SceneDefVars(fn).fromJson(this.resource.jo,this.context.locale,this.context.classes,this.context.abilities,this.context.triggers,this.context.logger,this.stripHappenings);
            this.def.url = this.url;
            this.readClickMasks(this.resource.bytes);
            this.readLayerBlockerClickMasks(this.resource.bytes);
            this.resource.release();
            this.resource = null;
            this.loadFromDef();
            return;
         }
         catch(e:Error)
         {
            context.logger.error("SceneLoader failed to load Scene [" + url + "]: " + e + " " + e.getStackTrace());
            this.abort();
            return;
         }
      }
      
      private function readClickMasks(param1:ByteArray) : void
      {
         var _loc4_:String = null;
         var _loc5_:ClickMask = null;
         var _loc6_:ILandscapeSpriteDef = null;
         if(!param1 || !param1.bytesAvailable)
         {
            return;
         }
         var _loc2_:int = param1.readInt();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = param1.readUTF();
            _loc5_ = new ClickMask().readData(param1);
            _loc6_ = this.def.landscape.getSpriteDef(_loc4_);
            if(!_loc6_)
            {
               _loc5_.cleanup();
               this.logger.error("No such clickmask spritedef: " + _loc4_);
            }
            else
            {
               _loc6_.setClickMask(_loc5_);
            }
            _loc3_++;
         }
      }
      
      private function readLayerBlockerClickMasks(param1:ByteArray) : void
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Dictionary = null;
         var _loc7_:int = 0;
         var _loc8_:ClickMask = null;
         var _loc9_:ILandscapeLayerDef = null;
         var _loc10_:String = null;
         if(!param1 || !param1.bytesAvailable)
         {
            return;
         }
         var _loc2_:int = param1.readInt();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = param1.readUTF();
            _loc5_ = param1.readInt();
            _loc6_ = !!_loc5_ ? new Dictionary() : null;
            _loc7_ = 0;
            while(_loc7_ < _loc5_)
            {
               _loc10_ = param1.readUTF();
               _loc6_[_loc10_] = true;
               _loc7_++;
            }
            _loc8_ = new ClickMask().readData(param1);
            _loc9_ = this.def.landscape.getLayer(_loc4_);
            if(!_loc9_)
            {
               this.logger.error("No such clickmask layerdef: " + _loc4_);
            }
            else
            {
               _loc9_.setClickBlockerMask(_loc8_,_loc6_);
            }
            _loc3_++;
         }
      }
      
      private function abort() : void
      {
         if(this.monitor)
         {
            this.monitor.abort();
            this.monitor = null;
         }
         if(this.completeCallback != null)
         {
            this.completeCallback(this);
         }
      }
      
      private function checkFinished() : void
      {
         if(this._checkFinishedFailed)
         {
            return;
         }
         try
         {
            this._checkFinished();
         }
         catch(e:Error)
         {
            _checkFinishedFailed = true;
            logger.error("Failed to checkFinished " + this + "\n" + e.getStackTrace());
         }
      }
      
      private function _checkFinished() : void
      {
         if(this.finished || this.cleanedup)
         {
            return;
         }
         if(this.audioDefWrangler)
         {
            return;
         }
         if(this.battleMusicDefWrangler)
         {
            return;
         }
         if(!this.scene)
         {
            return;
         }
         if(Boolean(this.scene.audio) && !this.scene.audio.complete)
         {
            return;
         }
         if(!this.viewSprite)
         {
            if(this.creatingSprite)
            {
               return;
            }
            this.creatingSprite = true;
            if(this.view_factory != null)
            {
               this.viewSprite = this.view_factory(this.scene,this.context.soundDriver);
            }
            else
            {
               this.viewSprite = new SceneViewSprite(this.scene,this.context.soundDriver);
            }
            this.creatingSprite = false;
            this.checkFinished();
            return;
         }
         if(!this.scene.happeningAudioReady)
         {
            return;
         }
         if(!this.scene.sceneAudioReady)
         {
            return;
         }
         if(this.monitor.empty)
         {
            if(Boolean(this.scene) && Boolean(this.viewSprite))
            {
               this.scene.removeEventListener(Scene.EVENT_AUDIO_READY,this.sceneAudioReadyHandler);
               this.scene.removeEventListener(Scene.EVENT_HAPPENING_AUDIO_READY,this.sceneAudioReadyHandler);
               this.scene.removeEventListener(Scene.EVENT_AUDIO_READY,this.sceneAudioReadyHandler);
               this.scene.removeEventListener(Scene.EVENT_BATTLE_MUSIC_READY,this.sceneAudioReadyHandler);
               this.monitor.cleanup();
               this.monitor = null;
               this.finished = true;
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("SceneLoader CHECKFINISHED READY " + this.url);
               }
               this.scene.start(this.happeningId);
               if(this.cleanedup || !this.scene)
               {
                  this.logger.info("SceneLoader the rug was pulled out [" + this.url + "]");
                  return;
               }
               if(this.viewSprite)
               {
                  this.viewSprite.start();
               }
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("SceneLoader CHECKFINISHED COMPLETE " + this.url);
               }
               if(this.completeCallback != null)
               {
                  try
                  {
                     this.completeCallback(this);
                  }
                  catch(err:Error)
                  {
                     logger.error("SceneLoader " + url + " failed to complete:\n" + err.getStackTrace());
                  }
               }
               queue_performCleanup();
            }
         }
         else if(this.logger.isDebugEnabled)
         {
         }
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function get sceneUniqueId() : int
      {
         return !!this.scene ? this.scene.uniqueId : 0;
      }
   }
}
