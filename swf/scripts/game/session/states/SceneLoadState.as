package game.session.states
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.anim.view.XAnimClipSpriteFlash;
   import engine.anim.view.XAnimClipSpriteStarling;
   import engine.battle.board.model.BattleBoard;
   import engine.core.analytic.Ga;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityDef;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import engine.landscape.view.DisplayObjectWrapperStarling;
   import engine.resource.AnimClipResource;
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import engine.resource.ResourceManager;
   import engine.resource.ResourceMonitor;
   import engine.saga.Saga;
   import engine.scene.SceneContext;
   import engine.scene.SceneControllerConfig;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneLoader;
   import flash.errors.IllegalOperationError;
   import flash.utils.getTimer;
   import game.cfg.GameConfig;
   import game.gui.GuiIcon;
   import game.gui.GuiIconLayoutType;
   import game.gui.GuiIconStarling;
   import game.session.GameState;
   
   public class SceneLoadState extends GameState
   {
      
      public static const inputDataKeys:Array = [GameStateDataEnum.SCENE_URL];
       
      
      public var sceneLoader:SceneLoader;
      
      private var monitor:ResourceMonitor;
      
      private var url:String;
      
      private var startLoadTime:Number = 0;
      
      private var _loadedAndReadyToComplete:Boolean;
      
      public function SceneLoadState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this.url = data.getValue(GameStateDataEnum.SCENE_URL);
         this.monitor = new ResourceMonitor("SLS " + this.url,config.logger,this.resourceMonitorChangedHandler);
         SceneLoader.aboutToLoadUrl = this.url;
      }
      
      public static function ctorSceneLoader(param1:String, param2:SceneLoaderConfig) : SceneLoader
      {
         var _loc4_:SceneLoader = null;
         if(!param1)
         {
            throw new IllegalOperationError("Why no URL for SceneLoadState?");
         }
         var _loc3_:SceneContext = param2.context;
         return new SceneLoader(param1,_loc3_,param2.sceneLoaderComplete,param2.setupLocalPartyCallback,param2.opponent,param2.bcd,param2.localBattleOrder,param2.isOnline,param2.convo,param2.happeningId,param2.battle_info,param2.travel_locator,param2.fallData,param2.stripHappenings,param2.battleMusicDefUrl,param2.battleMusicOverride,param2.battle_vitalities);
      }
      
      public function get scene() : Scene
      {
         return !!this.sceneLoader ? this.sceneLoader.scene : null;
      }
      
      override public function toString() : String
      {
         return super.toString() + "[" + StringUtil.getBasename(this.url) + "]";
      }
      
      override public function toInfoString() : String
      {
         var _loc1_:String = super.toInfoString();
         _loc1_ += "   monitor=" + this.monitor + "\n";
         if(this.monitor)
         {
            _loc1_ += "           " + this.monitor.waitingReport + "\n";
         }
         return _loc1_;
      }
      
      override protected function getRequiredInputDataKeys() : Array
      {
         return inputDataKeys;
      }
      
      private function resourceMonitorChangedHandler(param1:ResourceMonitor) : void
      {
         percentLoaded = this.monitor.percent;
         this.checkReady();
      }
      
      override protected function handleEnteredState() : void
      {
         if(cleanedup)
         {
            throw new IllegalOperationError("already cleanedup");
         }
         config.battleHudConfig.reset(false);
         if(SceneControllerConfig.instance)
         {
            SceneControllerConfig.instance.reset();
         }
         this.startLoadTime = getTimer();
         loading = true;
         config.resman.addMonitor(this.monitor);
         var _loc1_:GameConfig = config;
         var _loc2_:SceneLoaderConfig = new SceneLoaderConfig(config.fsm,this.sceneLoaderComplete,this.setupLocalPartyCallback,this.convoPortraitGenerator,data);
         this.sceneLoader = ctorSceneLoader(this.url,_loc2_);
         this.sceneLoader.load(null,true);
         this.checkReady();
      }
      
      override protected function handleCleanup() : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("handleCleanup " + this);
         }
         this._loadedAndReadyToComplete = false;
         super.handleCleanup();
         if(this.monitor)
         {
            this.monitor.cleanup();
            this.monitor = null;
         }
         if(this.sceneLoader)
         {
            this.sceneLoader.completeCallback = null;
            this.sceneLoader = null;
         }
      }
      
      override protected function handleInterrupted() : void
      {
         this._loadedAndReadyToComplete = false;
         super.handleInterrupted();
         if(this.sceneLoader)
         {
            this.sceneLoader.cleanup();
            this.sceneLoader.completeCallback = null;
            this.sceneLoader = null;
         }
      }
      
      private function sceneLoaderComplete(param1:SceneLoader) : void
      {
         if(param1 != this.sceneLoader)
         {
            return;
         }
         if(!this.sceneLoader.ok)
         {
            config.context.logger.error("SceneLoadState failed to load scene " + this.sceneLoader.url);
            this.monitor.abort();
            if(config.saga)
            {
               config.saga.triggerSceneExit(this.sceneLoader.url,this.sceneLoader.sceneUniqueId);
            }
            phase = StatePhase.FAILED;
            return;
         }
         this.checkReady();
      }
      
      protected function checkReady() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:String = null;
         if(this.sceneLoader && this.monitor.empty && this.sceneLoader.ok && this.sceneLoader.finished)
         {
            data.setValue(GameStateDataEnum.SCENE_LOADER,this.sceneLoader);
            config.resman.removeMonitor(this.monitor);
            _loc1_ = getTimer() - this.startLoadTime;
            _loc2_ = StringUtil.getBasename(this.url);
            Ga.trackSceneLoadTime(_loc2_,_loc1_);
            this._loadedAndReadyToComplete = true;
         }
      }
      
      override public function update(param1:int) : void
      {
         if(this._loadedAndReadyToComplete)
         {
            loading = false;
            this._loadedAndReadyToComplete = false;
            phase = StatePhase.COMPLETED;
         }
      }
      
      public function convoPortraitGenerator(param1:IEntityDef, param2:Boolean, param3:Number) : DisplayObjectWrapper
      {
         var _loc6_:IResource = null;
         var _loc7_:String = null;
         var _loc9_:XAnimClipSpriteBase = null;
         var _loc10_:GuiIconStarling = null;
         var _loc11_:GuiIcon = null;
         var _loc4_:ResourceManager = config.resman;
         var _loc5_:IEntityAppearanceDef = param1.appearance;
         var _loc8_:int = 0;
         if(param2)
         {
            _loc7_ = _loc5_.portraitUrl;
         }
         else
         {
            _loc7_ = _loc5_.backPortraitUrl;
            _loc8_ = _loc5_.backPortraitOffset * param3;
         }
         if(!_loc7_)
         {
            logger.error("convoPortraitGenerator: no portrait for " + param1.id + (param2 ? " FRONT " : " BACK"));
            return null;
         }
         if(StringUtil.endsWith(_loc7_,".clip") || StringUtil.endsWith(_loc7_,".clipq"))
         {
            _loc6_ = _loc4_.getResource(_loc7_,AnimClipResource,null);
            if(PlatformStarling.instance)
            {
               _loc9_ = new XAnimClipSpriteStarling(_loc6_ as AnimClipResource,null,logger,true);
            }
            else
            {
               _loc9_ = new XAnimClipSpriteFlash(_loc6_ as AnimClipResource,null,logger,true);
            }
            _loc6_.release();
            return _loc9_.displayObjectWrapper;
         }
         if(StringUtil.endsWith(_loc7_,".png"))
         {
            _loc6_ = _loc4_.getResource(_loc7_,BitmapResource,null);
            if(PlatformStarling.instance)
            {
               _loc10_ = new GuiIconStarling(false,_loc6_,GuiIconLayoutType.ACTUAL,_loc8_,true);
               return new DisplayObjectWrapperStarling(_loc10_);
            }
            _loc11_ = new GuiIcon(_loc6_,config.gameGuiContext,GuiIconLayoutType.ACTUAL,_loc8_,true);
            return new DisplayObjectWrapperFlash(_loc11_);
         }
         logger.error("convoPortraitGenerator: no handler for type " + _loc7_);
         return null;
      }
      
      private function setupLocalPartyCallback(param1:BattleBoard, param2:String) : void
      {
         var _loc5_:Saga = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         if(!param1)
         {
            return;
         }
         var _loc3_:int = data.getValue(GameStateDataEnum.PLAYER_ORDER);
         var _loc4_:int = data.getValue(GameStateDataEnum.LOCAL_TIMER_SECS);
         if(!_loc4_)
         {
            _loc5_ = Saga.instance;
            if(_loc5_.isSurvival)
            {
               _loc4_ = _loc5_.survivalBattleTimerSec;
            }
         }
         if(_loc3_ == 0)
         {
            if(param1.numParties == 0)
            {
               _loc6_ = config.fsm.credentials.displayName;
               _loc7_ = config.fsm.credentials.userId.toString();
               _loc8_ = _loc7_;
               _loc9_ = param2;
               if(!_loc9_)
               {
                  _loc9_ = "player" + _loc8_;
               }
               param1.createLocalParty(_loc6_,_loc8_,_loc7_,_loc9_,_loc4_);
            }
         }
      }
   }
}
