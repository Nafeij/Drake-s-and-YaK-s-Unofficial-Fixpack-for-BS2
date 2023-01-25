package engine.scene.model
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quart;
   import engine.anim.def.AnimFrame;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.def.BattleBoardDef;
   import engine.battle.board.def.BattleBoardTips;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleScenarioDef;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.music.BattleMusic;
   import engine.battle.sim.BattleSim;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.core.render.CameraDrifter;
   import engine.landscape.def.ILandscapeSpriteDef;
   import engine.landscape.model.Landscape;
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.resource.BitmapResource;
   import engine.resource.ResourceGroup;
   import engine.saga.EnableSceneElementEvent;
   import engine.saga.ISaga;
   import engine.saga.ISagaSound;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.saga.SagaPresenceManager;
   import engine.saga.SagaVar;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.action.BaseAction_Sound;
   import engine.saga.convo.Convo;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.IHappening;
   import engine.scene.SceneContext;
   import engine.scene.def.ISceneDef;
   import engine.scene.def.SceneDef;
   import engine.sound.ISoundDefBundle;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.ISoundDef;
   import engine.subtitle.SubtitleSequenceResource;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import tbs.srv.battle.data.client.BattleCreateData;
   
   public class Scene extends EventDispatcher implements IScene
   {
      
      public static const EVENT_CLICKABLES:String = "SceneState.EVENT_CLICKABLES";
      
      public static const EVENT_AUDIO_READY:String = "SceneState.EVENT_AUDIO_READY";
      
      public static const EVENT_HAPPENING_AUDIO_READY:String = "SceneState.EVENT_HAPPENING_AUDIO_READY";
      
      public static const EVENT_BATTLE_MUSIC_READY:String = "SceneState.EVENT_BATTLE_MUSIC_READY";
      
      private static var _lastUniqueId:int;
      
      public static var DISABLE_BATTLEPAN:Boolean = false;
       
      
      public var uniqueId:int;
      
      public var _def:SceneDef;
      
      public var name:String;
      
      public var landscape:Landscape;
      
      public var boards:Vector.<BattleBoard>;
      
      public var _context:SceneContext;
      
      public var _camera:BoundedCamera;
      
      public var numEnabledBoards:int;
      
      private var _focusedBoard:BattleBoard;
      
      private var battleCreateData:BattleCreateData;
      
      private var battleOrder:int;
      
      public var _convo:Convo;
      
      public var _ready:Boolean;
      
      private var _allClickablesDisabled:Boolean = false;
      
      private var _enableClickables:Dictionary;
      
      private var _saga:ISaga;
      
      private var _audio:SceneAudio;
      
      private var _battleMusic:BattleMusic;
      
      private var noMusicTimer:int;
      
      private var NO_MUSIC_TIMER_LIMIT_MS:int = 5000;
      
      public var logger:ILogger;
      
      public var isStartScene:Boolean;
      
      private var soundBundle:ISoundDefBundle;
      
      public var tips:BattleBoardTips;
      
      public var cameraGlobalLock:Boolean;
      
      public var resourceGroup:ResourceGroup;
      
      public var happeningAudioReady:Boolean = true;
      
      public var sceneAudioReady:Boolean = true;
      
      public var sceneBattleMusicReady:Boolean = true;
      
      private var _started:Boolean;
      
      private var _happening:IHappening;
      
      public var _lookingForReady:Boolean;
      
      private var _wiped:Boolean;
      
      private var _battleSetupPanning:Boolean;
      
      private var _disableStartPan:Boolean;
      
      private var _anchorReady:Boolean;
      
      public var forceTransitionOut:Boolean;
      
      private var _paused:Boolean;
      
      public var cleanedup:Boolean;
      
      private var exited:Boolean;
      
      public function Scene(param1:SceneDef, param2:SceneContext, param3:BattleCreateData, param4:int, param5:TravelLocator, param6:Travel_FallData)
      {
         this.boards = new Vector.<BattleBoard>();
         this._enableClickables = new Dictionary();
         this.noMusicTimer = this.NO_MUSIC_TIMER_LIMIT_MS / 2;
         super();
         this.uniqueId = ++_lastUniqueId;
         this.logger = param2.logger;
         this.resourceGroup = new ResourceGroup(this,this.logger);
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("Scene CTOR start");
         }
         this.battleCreateData = param3;
         this.battleOrder = param4;
         this._saga = param2.saga;
         this._def = param1;
         this.name = param1.name;
         this._context = param2;
         this._camera = new BoundedCamera("scene:" + this.name,param2.logger,param1.boundary,param1.disableAdjustBoundary);
         this._camera.disableTilt = param1.tiltDisabled;
         this._def.addEventListener(SceneDef.EVENT_BATTLE_MUSIC,this.sceneDefBattleMusicHandler);
         this._camera.drift.anchorSpeed = this._def.cameraAnchorSpeed;
         this._camera.drift.driftMax = this._def.cameraDrift;
         this._camera.minHeight = this._def.cameraMinHeight;
         this._camera.maxHeight = this._def.cameraMaxHeight;
         this._camera.minWidth = this._def.cameraMinWidth;
         this._camera.maxWidth = this._def.cameraMaxWidth;
         this._camera.cinemascope = this._def.cinemascope;
         this._camera.fitCamera(this._camera.maxWidth,this._camera.maxHeight);
         if(this._def.landscape)
         {
            this.landscape = new Landscape(this,this._def.landscape,param2,this._camera,param5,param6);
         }
         this.sceneDefAudioHandler(null);
         this.sceneDefBattleMusicHandler(null);
         if(this._saga)
         {
            this._saga.addEventListener(EnableSceneElementEvent.TYPE,this.enableSceneElementHandler);
            this._saga.addEventListener(SagaEvent.EVENT_PAUSE,this.sagaPauseHandler);
         }
         this.isStartScene = Boolean(this.saga) && this.saga.startUrl == this._def.url;
         this._def.addEventListener(SceneDef.EVENT_AUDIO,this.sceneDefAudioHandler);
         this.preloadHappeningAudio();
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("Scene CTOR end");
         }
      }
      
      override public function toString() : String
      {
         return this.name;
      }
      
      public function get battleSetupPanning() : Boolean
      {
         return this._battleSetupPanning;
      }
      
      public function set battleSetupPanning(param1:Boolean) : void
      {
         if(this._battleSetupPanning == param1)
         {
            return;
         }
         this._battleSetupPanning = param1;
         if(!this._battleSetupPanning)
         {
            this.checkReady();
         }
      }
      
      private function preloadHappeningAudio() : void
      {
         var _loc2_:Vector.<ISoundDef> = null;
         var _loc3_:HappeningDef = null;
         var _loc4_:ActionDef = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(!this._context || !this.saga || !this.saga.iSagaSound)
         {
            this.happeningAudioReady = true;
            return;
         }
         if(this.saga.mapCamp && !this.saga.mapCampCinema)
         {
            return;
         }
         var _loc1_:ISagaSound = !!this.saga ? this.saga.iSagaSound : null;
         if(!_loc1_)
         {
            return;
         }
         for each(_loc3_ in this._def.happenings.list)
         {
            if(_loc3_.enabled)
            {
               if(this.landscape.travel)
               {
                  _loc5_ = this.landscape.travel.position;
                  _loc6_ = this.landscape.travel.def.findNextLoadBarrier(_loc5_);
                  if(!this.landscape.travel.def.isLocationTriggerInRange(_loc3_.triggers,_loc5_,_loc6_))
                  {
                     continue;
                  }
               }
               for each(_loc4_ in _loc3_.actions)
               {
                  if(_loc4_.enabled)
                  {
                     _loc2_ = BaseAction_Sound.getSoundDefsForActionDef(_loc4_,_loc1_,_loc2_);
                     if(_loc4_.type == ActionType.VO)
                     {
                        if(Boolean(_loc4_.subtitle) && _loc4_.subtitle.indexOf(".sbv.z") > 0)
                        {
                           this._context.resman.getResource(_loc4_.subtitle,SubtitleSequenceResource,this.resourceGroup);
                        }
                     }
                  }
               }
            }
         }
         if(_loc2_)
         {
            if(this.saga.logger.isDebugEnabled)
            {
               this.saga.logger.debug("Scene PRELOAD Sound Bundle Defs " + _loc2_.join(", "));
            }
            this.happeningAudioReady = false;
            this.soundBundle = this._context.soundDriver.preloadSoundDefData(this._def.url,_loc2_);
            this.soundBundle.addListener(this);
         }
         else
         {
            this.happeningAudioReady = true;
            this.soundDefBundleComplete(null);
         }
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         this.happeningAudioReady = true;
         dispatchEvent(new Event(EVENT_HAPPENING_AUDIO_READY));
      }
      
      public function sceneDefAudioHandler(param1:Event) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(this._audio)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("Scene.sceneDefAudioHandler re-creating");
            }
            this._audio.cleanup();
            this.audio = null;
         }
         this.audio = new SceneAudio(this);
      }
      
      public function sceneDefBattleMusicHandler(param1:Event) : void
      {
         if(Boolean(this._def.battleMusic) && !this._battleMusic)
         {
            this.battleMusic = new BattleMusic(this._def.battleMusic,this._context.soundDriver.system,this._context.logger,this._context.animDispatcher);
         }
         else if(!this._def.battleMusic && Boolean(this._battleMusic))
         {
            this.battleMusic = null;
         }
      }
      
      public function start(param1:String) : void
      {
         var _loc2_:HappeningDef = null;
         var _loc3_:HappeningDef = null;
         if(this._started)
         {
            return;
         }
         this._started = true;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("Scene.start");
         }
         if(this._context.saga)
         {
            if(this._def.happenings.numHappenings)
            {
               this._context.saga.addHappeningDefProvider(this._def.happenings);
            }
            this._def.happenings.executeAutomatics(this._context.saga);
            if(param1)
            {
               _loc2_ = this._def.happenings.getHappeningDef(param1);
               _loc3_ = this.saga.getHappeningDefById(param1,this._def.happenings);
               if(Boolean(_loc2_) && Boolean(_loc3_) && _loc2_ != _loc3_)
               {
                  this.logger.error("Scene start happening " + _loc3_ + " hides happening " + _loc2_);
               }
               if(_loc3_)
               {
                  if(_loc3_.automatic)
                  {
                     this.logger.error("Don\'t start automatic happening: " + _loc3_);
                  }
                  else
                  {
                     this.logger.info("Scene starting happening " + _loc3_.toString() + "]");
                     this._happening = this._context.saga.preExecuteHappeningDef(_loc3_,this);
                     if(this._happening)
                     {
                        this._happening.execute();
                     }
                  }
               }
               else
               {
                  this.logger.error("Scene.start No such happening: " + param1 + " in scene " + this._def.url);
               }
            }
         }
         if(this.landscape)
         {
            this.landscape.start();
         }
      }
      
      private function battlePanningCompleteHandler() : void
      {
         this.battleSetupPanning = false;
         this.checkBattleMusic();
      }
      
      public function checkBattleFocus() : Point
      {
         var _loc1_:Point = null;
         if(this._focusedBoard)
         {
            _loc1_ = this._focusedBoard.getParty(0).getCentroid();
         }
         return _loc1_;
      }
      
      public function disableStartPan() : void
      {
         if(!this._disableStartPan)
         {
            this.logger.debug("Scene.disableStartPan");
         }
         this._disableStartPan = true;
         if(this.battleSetupPanning)
         {
            TweenMax.killTweensOf(this._camera);
            this.battlePanningCompleteHandler();
         }
         if(!this._anchorReady)
         {
            this._anchorReady = true;
         }
      }
      
      public function checkStartAnchor(param1:Boolean, param2:Point) : void
      {
         var _loc3_:Point = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(this.cleanedup)
         {
            return;
         }
         this.lookingForReady = true;
         if(param1 && param2 && !this._disableStartPan && !DISABLE_BATTLEPAN)
         {
            _loc4_ = this._camera.width / this._camera.maxWidth;
            _loc5_ = Math.min(1.25,BoundedCamera.computeDpiFingerScale());
            _loc6_ = 4;
            if(!Camera.ALLOW_ZOOM)
            {
               _loc6_ = 1.5;
            }
            this.battleSetupPanning = true;
            this._camera.zoom = _loc4_;
            TweenMax.to(this._camera,_loc6_,{
               "zoom":_loc5_,
               "x":param2.x,
               "y":param2.y,
               "delay":0.5,
               "ease":Quart.easeInOut,
               "onComplete":this.battlePanningCompleteHandler
            });
            this.checkReady();
            return;
         }
         if(!this._camera.drift.anchor && !DISABLE_BATTLEPAN && !this._disableStartPan)
         {
            this.logger.info("Scene.checkStartAnchor drift anchoring autopan=" + param1);
            _loc3_ = null;
            if(param1)
            {
               _loc3_ = !!this._def.cameraStart ? this._def.cameraStart : this._def.cameraAnchor;
            }
            else
            {
               _loc3_ = this._def.cameraAnchor;
            }
            if(_loc3_)
            {
               this._camera.setPosition(_loc3_.x,_loc3_.y);
            }
            this._camera.drift.anchor = this._def.cameraAnchor;
         }
         this.anchorReachedHandler(null);
      }
      
      private function anchorReachedHandler(param1:Event) : void
      {
         if(!this._camera)
         {
            return;
         }
         this.checkReady();
         this.checkBattleMusic();
      }
      
      public function forceReady() : void
      {
         this.forceTransitionOut = true;
         if(this.ready || this.cleanedup)
         {
            return;
         }
         var _loc1_:CameraDrifter = this._camera.drift;
         this.wiped = true;
         if(this.ready)
         {
            return;
         }
         if(this.lookingForReady && !this._anchorReady)
         {
            if(Boolean(_loc1_) && _loc1_.isAnchorAnimating)
            {
               this._camera.removeEventListener(Camera.EVENT_ANCHOR_REACHED,this.anchorReachedHandler);
               _loc1_.forceAnchor();
               this.checkReady();
            }
         }
         if(this.ready)
         {
            return;
         }
         this.battleSetupPanning = false;
      }
      
      private function sagaPauseHandler(param1:Event) : void
      {
         this.checkReady();
      }
      
      private function checkReady() : void
      {
         var _loc2_:int = 0;
         if(this.ready)
         {
            return;
         }
         if(Boolean(this._saga) && this._saga.paused)
         {
         }
         var _loc1_:CameraDrifter = this._camera.drift;
         if(!this._wiped)
         {
            return;
         }
         if(this.lookingForReady && !this._anchorReady)
         {
            if(!(!_loc1_ || !_loc1_.isAnchorAnimating))
            {
               this._camera.addEventListener(Camera.EVENT_ANCHOR_REACHED,this.anchorReachedHandler);
               return;
            }
            this._camera.removeEventListener(Camera.EVENT_ANCHOR_REACHED,this.anchorReachedHandler);
            this._anchorReady = true;
         }
         if(this._battleSetupPanning)
         {
            return;
         }
         if(this.focusedBoard != null)
         {
            SagaPresenceManager.setBaseState(SagaPresenceManager.StateInBattle);
         }
         else if(this.saga != null && this.saga.camped)
         {
            SagaPresenceManager.setBaseState(SagaPresenceManager.StateCamping);
         }
         else if(this.landscape != null && Boolean(this.landscape.travel))
         {
            SagaPresenceManager.setBaseState(SagaPresenceManager.StateTraveling);
         }
         else if(this.isStartScene)
         {
            SagaPresenceManager.setBaseState(SagaPresenceManager.StateStartingGame);
         }
         if(this._def.cameraAnchorOnce)
         {
            this._camera.drift.anchor = null;
         }
         this.ready = true;
         dispatchEvent(new SceneEvent(SceneEvent.READY));
         if(this._context.saga)
         {
            _loc2_ = Boolean(this.landscape) && Boolean(this.landscape.travel) ? int(this.landscape.travel.position) : -1;
            (this._context.saga as Saga).triggerSceneLoaded(this._def.url,_loc2_,this.focusedBoard != null,this.uniqueId);
         }
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
      
      public function pause() : void
      {
         this._paused = true;
      }
      
      public function resume() : void
      {
         this._paused = false;
      }
      
      public function cleanup() : void
      {
         var _loc1_:BattleBoard = null;
         var _loc2_:BattleMusic = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("double cleanup");
         }
         AnimFrame.purgeOrphanedTextures(this.logger);
         BitmapResource.purgeOrphanedTextures(this.logger);
         this.cleanedup = true;
         this.ready = false;
         if(this.saga)
         {
            this.saga.handleSceneDestruction(this);
         }
         if(this.resourceGroup)
         {
            this.resourceGroup.release();
            this.resourceGroup = null;
         }
         if(this._def)
         {
            this._def.removeEventListener(SceneDef.EVENT_AUDIO,this.sceneDefAudioHandler);
            this._def.removeEventListener(SceneDef.EVENT_BATTLE_MUSIC,this.sceneDefBattleMusicHandler);
         }
         if(this.soundBundle)
         {
            this.soundBundle.removeListener(this);
            this.soundBundle = null;
         }
         if(this._audio)
         {
            this.audio = null;
         }
         if(this.battleMusic)
         {
            _loc2_ = this.battleMusic;
            this.battleMusic = null;
            _loc2_.cleanup();
         }
         if(this._saga)
         {
            this._saga.removeEventListener(EnableSceneElementEvent.TYPE,this.enableSceneElementHandler);
            this._saga.removeEventListener(SagaEvent.EVENT_PAUSE,this.sagaPauseHandler);
            this._saga = null;
         }
         this.exitScene();
         this._camera.removeEventListener(Camera.EVENT_ANCHOR_REACHED,this.anchorReachedHandler);
         if(this._context.saga)
         {
            this._context.saga.removeHappeningDefProvider(this._def.happenings);
            if(this._happening)
            {
               if(!this._happening.isEnded)
               {
                  if(!this._happening.isTranscendent)
                  {
                     this.logger.info("SCENE CLEANUP KILL HAPPENING " + this._happening);
                     this._happening.end(true);
                  }
               }
            }
         }
         this.focusedBoard = null;
         for each(_loc1_ in this.boards)
         {
            _loc1_.removeEventListener(BattleBoardEvent.ENABLED,this.boardEnabledHandler);
            if(_loc1_.sim.fsm.current)
            {
               _loc1_.sim.fsm.stopFsm(false);
            }
            _loc1_.sim.fsm = null;
            _loc1_.cleanup();
         }
         this.boards = null;
         TweenMax.killTweensOf(this._camera);
         this._camera.cleanup();
         this._camera = null;
         if(this.landscape)
         {
            this.landscape.cleanup();
            this.landscape = null;
         }
         if(this.tips)
         {
            this.tips.cleanup();
            this.tips = null;
         }
         this._context.cleanup();
         this._context = null;
         this._def = null;
      }
      
      public function get focusedBoard() : BattleBoard
      {
         return this._focusedBoard;
      }
      
      public function set focusedBoard(param1:BattleBoard) : void
      {
         if(this._focusedBoard == param1)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("Scene.focusedBoard " + param1);
         }
         this._focusedBoard = param1;
         dispatchEvent(new SceneEvent(SceneEvent.FOCUSED_BOARD));
         if(!this._focusedBoard)
         {
            this.exitScene();
         }
         else if(this._def.tips)
         {
            if(Boolean(this.saga) && this._def.tips.checkPrereqs(this.saga,null))
            {
               this.tips = new BattleBoardTips(this._def.tips,this._focusedBoard);
            }
         }
         this.checkBattleMusic();
      }
      
      private function checkBattleMusic() : void
      {
         if(!this._battleMusic)
         {
            return;
         }
         if(this._focusedBoard)
         {
            if(this.ready || this._wiped && this.lookingForReady)
            {
               this._battleMusic.start();
            }
         }
      }
      
      public function exitScene() : void
      {
         if(!this.exited)
         {
            this.exited = true;
            dispatchEvent(new SceneEvent(SceneEvent.EXIT));
         }
      }
      
      public function prepareBoard(param1:String, param2:BattleScenarioDef, param3:Boolean, param4:String) : BattleBoard
      {
         if(this.cleanedup || !this._def)
         {
            throw new ArgumentError("Attempt to prepareBoard on invalid Scene");
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("Scene.prepareBoard " + param1);
         }
         if(this._saga)
         {
            this._saga.setVar(SagaVar.VAR_BATTLE_BOARD,param1);
         }
         var _loc5_:BattleBoardDef = this._def.getBoard(param1);
         if(!_loc5_)
         {
            throw new ArgumentError("No such board: " + param1 + " for " + this._def.url);
         }
         var _loc6_:BattleBoard = new BattleBoard(_loc5_,param2,this,this._context.logger,this._context.resman,this._context.abilities,this._context.battleAssets,this._context.soundDriver,param4,this._context.saga);
         var _loc7_:BattleFsmConfig = new BattleFsmConfig();
         var _loc8_:BattleFsm = new BattleFsm(this._context.session,_loc6_,this._context.logger,_loc7_,this.battleCreateData,this.battleOrder,param3,this._context.chat,this._context.fsm);
         _loc6_.sim = new BattleSim(_loc6_,_loc8_);
         this.boards.push(_loc6_);
         _loc6_.addEventListener(BattleBoardEvent.ENABLED,this.boardEnabledHandler);
         if(_loc6_.enabled)
         {
            ++this.numEnabledBoards;
         }
         return _loc6_;
      }
      
      protected function boardEnabledHandler(param1:BattleBoardEvent) : void
      {
         if(param1.board.enabled)
         {
            ++this.numEnabledBoards;
         }
         else
         {
            --this.numEnabledBoards;
         }
         dispatchEvent(new SceneEvent(SceneEvent.NUM_ENABLED_BOARDS));
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:BattleBoard = null;
         if(this.cleanedup)
         {
            return;
         }
         if(Boolean(this._audio) && (this._audio.def || this._audio.extraEmitters && this._audio.extraEmitters.length > 0))
         {
         }
         if(this._paused)
         {
            return;
         }
         if(this._camera)
         {
            this._camera.update(param1);
         }
         if(!this._lookingForReady && !this._ready)
         {
            return;
         }
         if(this.landscape)
         {
            this.landscape.update(param1);
         }
         for each(_loc2_ in this.boards)
         {
            _loc2_.update(param1);
         }
         if(this._audio)
         {
            this._audio.update();
         }
         if(this._battleMusic)
         {
            this._battleMusic.updateBattleMusic();
         }
         this.checkNoMusic(param1);
      }
      
      private function checkNoMusic(param1:int) : void
      {
         if(Boolean(this.boards) && this.boards.length > 0)
         {
            return;
         }
         if(!this._context || !this._context.saga)
         {
            return;
         }
         var _loc2_:ISoundSystem = this._context.soundDriver.system;
         this.noMusicTimer += param1;
         if(this.noMusicTimer > this.NO_MUSIC_TIMER_LIMIT_MS)
         {
            if(this.saga.iSagaSound)
            {
               this.saga.iSagaSound.checkMusicSituation();
               this.noMusicTimer = 0;
            }
         }
      }
      
      public function set convo(param1:Convo) : void
      {
         this._convo = param1;
         if(this._convo)
         {
            if(this.landscape)
            {
               this.landscape.suppressTravel();
            }
         }
      }
      
      public function get convo() : Convo
      {
         return this._convo;
      }
      
      public function isClickableEnabled(param1:String) : Boolean
      {
         if(this._allClickablesDisabled)
         {
            return false;
         }
         if(param1 in this._enableClickables && !this._enableClickables[param1])
         {
            return false;
         }
         return true;
      }
      
      public function setClickableEnabled(param1:String, param2:Boolean, param3:String) : void
      {
         var _loc4_:ILandscapeSpriteDef = null;
         if(param1 == "*")
         {
            if(param2)
            {
               this._enableClickables = new Dictionary();
            }
            else
            {
               this._def.landscape.visitClickables(this._clickableDisabledVisitor);
            }
            dispatchEvent(new Event(EVENT_CLICKABLES));
            return;
         }
         _loc4_ = this._def.landscape.findClickable(param1);
         if(!_loc4_)
         {
            this.logger.info("setClickableEnabled: No such clickable: [" + param1 + "] in " + this._def.url + " reason [" + param3 + "]");
            return;
         }
         if(this._enableClickables[param1] != param2)
         {
            this._enableClickables[param1] = param2;
            dispatchEvent(new Event(EVENT_CLICKABLES));
         }
      }
      
      private function _clickableDisabledVisitor(param1:ILandscapeSpriteDef) : void
      {
         this._enableClickables[param1.getNameId()] = false;
      }
      
      public function get allClickablesDisabled() : Boolean
      {
         return this._allClickablesDisabled;
      }
      
      public function set allClickablesDisabled(param1:Boolean) : void
      {
         if(this._allClickablesDisabled == param1)
         {
            return;
         }
         this._allClickablesDisabled = param1;
         dispatchEvent(new Event(EVENT_CLICKABLES));
      }
      
      private function enableSceneElementHandler(param1:EnableSceneElementEvent) : void
      {
         if(!param1.clickable)
         {
            return;
         }
         this.setClickableEnabled(param1.id,param1.enabled,param1.reason);
      }
      
      public function get audio() : SceneAudio
      {
         return this._audio;
      }
      
      public function set audio(param1:SceneAudio) : void
      {
         if(this._audio == param1)
         {
            return;
         }
         if(this._audio)
         {
            this._audio.removeEventListener(Event.COMPLETE,this.audioCompleteHandler);
            this._audio.cleanup();
         }
         this._audio = param1;
         if(this._audio)
         {
            this.sceneAudioReady = false;
            if(this.landscape && this.landscape.travel && Boolean(this.landscape.travel.audio))
            {
               this.landscape.travel.audio.handleSceneAudio(this._audio);
            }
            this._audio.addEventListener(Event.COMPLETE,this.audioCompleteHandler);
            this.audio.preload();
         }
         else
         {
            this.sceneAudioReady = true;
            this.audioCompleteHandler(null);
         }
      }
      
      private function audioCompleteHandler(param1:Event) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(this._audio)
         {
            this._audio.removeEventListener(Event.COMPLETE,this.audioCompleteHandler);
         }
         this.sceneAudioReady = true;
         dispatchEvent(new Event(EVENT_AUDIO_READY));
      }
      
      private function battleMusicCompleteHandler(param1:Event) : void
      {
         this.sceneBattleMusicReady = true;
         dispatchEvent(new Event(EVENT_BATTLE_MUSIC_READY));
      }
      
      public function get wiped() : Boolean
      {
         return this._wiped;
      }
      
      public function set wiped(param1:Boolean) : void
      {
         this._wiped = param1;
         this.anchorReachedHandler(null);
         this.logger.info("Scene.wiped " + param1);
      }
      
      public function get battleMusic() : BattleMusic
      {
         return this._battleMusic;
      }
      
      public function set battleMusic(param1:BattleMusic) : void
      {
         if(this._battleMusic == param1)
         {
            return;
         }
         if(this._battleMusic)
         {
            this._battleMusic.preloader.removeEventListener(Event.COMPLETE,this.battleMusicCompleteHandler);
            this._battleMusic.stop();
         }
         this._battleMusic = param1;
         if(this._battleMusic)
         {
            this.sceneBattleMusicReady = false;
            this._battleMusic.preloader.addEventListener(Event.COMPLETE,this.battleMusicCompleteHandler);
            this._battleMusic.preloader.preload();
         }
         else
         {
            this.sceneBattleMusicReady = true;
            this.battleMusicCompleteHandler(null);
         }
         this.checkBattleMusic();
      }
      
      public function respawnBattleMusic() : void
      {
         var _loc1_:IBattleParty = null;
         if(this._battleMusic)
         {
            if(this._focusedBoard)
            {
               _loc1_ = this._focusedBoard.getPartyById("0");
               if(_loc1_)
               {
                  this._battleMusic.respawnTrauma(_loc1_);
               }
            }
         }
      }
      
      public function handleTraumaChanged(param1:IBattleParty) : void
      {
         if(this._battleMusic)
         {
            this._battleMusic.handleTraumaChange(param1);
         }
      }
      
      public function handleBattleState() : void
      {
         var _loc1_:BattleFinishedData = null;
         if(!this._focusedBoard)
         {
            return;
         }
         if(this._battleMusic)
         {
            if(this._focusedBoard.fsm.battleFinished)
            {
               _loc1_ = this._focusedBoard.fsm.finishedData;
               if(_loc1_)
               {
                  if(!this._context.saga)
                  {
                     this._battleMusic.handleBattleFinished(_loc1_.victoriousTeam == "0");
                  }
               }
            }
         }
      }
      
      public function performBattleFinishMusic(param1:Boolean) : void
      {
         if(this._battleMusic)
         {
            this._battleMusic.handleBattleFinished(param1);
         }
      }
      
      public function handleBattleWaveIncrease(param1:Boolean) : void
      {
         if(!this._focusedBoard)
         {
            return;
         }
         if(this._battleMusic)
         {
            this._battleMusic.handleBattleWaveIncrease(param1);
         }
      }
      
      public function handleBattlePillage(param1:Boolean) : void
      {
         if(!this._focusedBoard)
         {
            return;
         }
         if(this._battleMusic)
         {
            this._battleMusic.handleBattlePillage(param1);
         }
      }
      
      public function stopBattleMusic() : void
      {
         if(this._battleMusic)
         {
            this._battleMusic.stop();
            this._battleMusic.cleanup();
            this._battleMusic = null;
         }
      }
      
      public function cropToBoundary() : Dictionary
      {
         return this._def.cropToBoundary(this.logger);
      }
      
      public function performBattleUnitEnable(param1:String, param2:Boolean) : void
      {
         if(this._focusedBoard)
         {
            this._focusedBoard.performBattleUnitEnable(param1,param2);
         }
      }
      
      public function get lookingForReady() : Boolean
      {
         return this._lookingForReady;
      }
      
      public function set lookingForReady(param1:Boolean) : void
      {
         if(this._lookingForReady == param1)
         {
            return;
         }
         this._lookingForReady = param1;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("Scene.lookingForReady " + param1);
         }
      }
      
      public function get ready() : Boolean
      {
         return this._ready;
      }
      
      public function set ready(param1:Boolean) : void
      {
         if(this._ready == param1)
         {
            return;
         }
         this._ready = param1;
         if(param1)
         {
            this.logger.info("Scene.ready " + param1);
         }
      }
      
      public function get saga() : ISaga
      {
         return this._saga;
      }
      
      public function get context() : SceneContext
      {
         return this._context;
      }
      
      public function get camera() : BoundedCamera
      {
         return this._camera;
      }
      
      public function get def() : ISceneDef
      {
         return this._def;
      }
   }
}
