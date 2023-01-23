package game.session.states
{
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.core.RunMode;
   import engine.core.cmd.CmdExec;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.entity.def.IEntityListDef;
   import engine.resource.ResourceMonitor;
   import engine.saga.IBattleTutorial;
   import engine.saga.WarOutcome;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneEvent;
   import engine.scene.model.SceneLoader;
   import engine.scene.model.SceneLoaderBattleInfo;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import game.session.GameState;
   
   public class SceneState extends GameState
   {
      
      public static const EVENT_CHAT_ENABLED:String = "SceneState.EVENT_CHAT_ENABLED";
      
      public static const EVENT_BANNER_BUTTON_ENABLED:String = "SceneState.EVENT_BANNER_ENABLED";
      
      public static const EVENT_HELP_ENABLED:String = "SceneState.EVENT_HELP_ENABLED";
      
      public static const EVENT_WAR_RESOLUTION:String = "SceneState.EVENT_WAR_RESOLUTION";
      
      public static const EVENT_BATTLE_RESOLUTION:String = "SceneState.EVENT_BATTLE_RESOLUTION";
      
      public static const EVENT_RESOURCES_READY:String = "SceneState.EVENT_RESOURCES_READY";
      
      public static const EVENT_SCENE_EXITING:String = "SceneState.EVENT_SCENE_EXITING";
      
      public static const EVENT_SCENE_TRANSITIONING_OUT:String = "SceneState.EVENT_SCENE_TRANSITIONING_OUT";
      
      public static const inputDataKeys:Array = [GameStateDataEnum.SCENE_LOADER];
       
      
      public var loader:SceneLoader;
      
      public var timer:int;
      
      public var party:IEntityListDef;
      
      public var battleHandler:SceneStateBattleHandler;
      
      public var playerOrder:int;
      
      public var opponentName:String;
      
      public var opponentId:int;
      
      public var battle_info:SceneLoaderBattleInfo;
      
      private var _chatEnabled:Boolean = true;
      
      private var _bannerButtonEnabled:Boolean = false;
      
      private var _helpEnabled:Boolean = false;
      
      private var _resourcesReady:Boolean;
      
      public var monitor:ResourceMonitor;
      
      public var wipeInDuration:Number = 1;
      
      public var wipeInHold:Number = 0;
      
      public var tut:IBattleTutorial;
      
      public var warOutcome:WarOutcome;
      
      public var warFinished:BattleFinishedData;
      
      public var battleFinished:BattleFinishedData;
      
      public var battleResolutionShowStats:Boolean;
      
      public function SceneState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this.loader = data.getValue(GameStateDataEnum.SCENE_LOADER);
         this.monitor = new ResourceMonitor("SceneState " + StringUtil.getFilename(this.loader.url),param3,this.monitorCallback);
         shell.add("battle",this.shellCmdFuncBattle);
         this.bannerButtonEnabled = Boolean(this.scene._def.boards) && this.scene._def.boards.length > 0;
         this.helpEnabled = this._helpEnabled;
      }
      
      override public function toString() : String
      {
         return super.toString() + "[" + this.loader + "]";
      }
      
      private function monitorCallback(param1:ResourceMonitor) : void
      {
         this.checkMonitorReady();
      }
      
      private function checkMonitorReady() : void
      {
         if(Boolean(this.monitor) && this.monitor.empty)
         {
            this.monitor.cleanup();
            this.monitor = null;
            this.setResourcesReady();
         }
      }
      
      public function get bannerButtonEnabled() : Boolean
      {
         return this._bannerButtonEnabled;
      }
      
      public function set bannerButtonEnabled(param1:Boolean) : void
      {
         param1 = param1 && !this.scene._def.hideBannerButton;
         if(this._bannerButtonEnabled != param1)
         {
            this._bannerButtonEnabled = param1;
            dispatchEvent(new Event(EVENT_BANNER_BUTTON_ENABLED));
         }
      }
      
      public function get helpEnabled() : Boolean
      {
         return this._helpEnabled;
      }
      
      public function set helpEnabled(param1:Boolean) : void
      {
         param1 = param1 && !this.scene._def.hideHelpButton;
         if(this._helpEnabled != param1)
         {
            this._helpEnabled = param1;
            dispatchEvent(new Event(EVENT_HELP_ENABLED));
         }
      }
      
      public function get chatEnabled() : Boolean
      {
         return this._chatEnabled;
      }
      
      public function set chatEnabled(param1:Boolean) : void
      {
         if(this._chatEnabled != param1)
         {
            this._chatEnabled = param1;
            dispatchEvent(new Event(EVENT_CHAT_ENABLED));
         }
      }
      
      override protected function getRequiredInputDataKeys() : Array
      {
         return inputDataKeys;
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:Class = null;
         if(Boolean(config) && Boolean(config.tutorialLayer))
         {
            config.tutorialLayer.removeAllTooltips();
         }
         if(!data.hasValue(GameStateDataEnum.SCENE_LOADER))
         {
            throw new IllegalOperationError("data came in without the right stuff");
         }
         if(!this.loader.scene)
         {
            throw new IllegalOperationError("Cannot enter scene state without a scene");
         }
         config.resman.addMonitor(this.monitor);
         this.loader.resume();
         this.party = data.getValue(GameStateDataEnum.LOCAL_PARTY);
         this.playerOrder = data.getValue(GameStateDataEnum.PLAYER_ORDER);
         this.opponentName = data.getValue(GameStateDataEnum.OPPONENT_NAME);
         this.opponentId = data.getValue(GameStateDataEnum.OPPONENT_ID);
         this.timer = data.getValue(GameStateDataEnum.LOCAL_TIMER_SECS);
         this.battle_info = data.getValue(GameStateDataEnum.BATTLE_INFO);
         if(data.hasValue(GameStateDataEnum.WIPEIN_DURATION))
         {
            this.wipeInDuration = data.getValue(GameStateDataEnum.WIPEIN_DURATION);
            data.removeValue(GameStateDataEnum.WIPEIN_DURATION);
         }
         if(data.hasValue(GameStateDataEnum.WIPEIN_HOLD))
         {
            this.wipeInHold = data.getValue(GameStateDataEnum.WIPEIN_HOLD);
            data.removeValue(GameStateDataEnum.WIPEIN_HOLD);
         }
         this.battleHandler = new SceneStateBattleHandler(this);
         this.helpEnabled = this.scene.focusedBoard != null;
         this.scene.addEventListener(SceneEvent.EXIT,this.sceneExitHandler);
         if(Boolean(this.scene.focusedBoard) && Boolean(this.scene._def.tutorial))
         {
            _loc1_ = getDefinitionByName(this.scene._def.tutorial) as Class;
            this.tut = new _loc1_(this);
            this.scene.focusedBoard.tutorial = this.tut;
         }
         if(config && config.pageManager && Boolean(config.pageManager.loadingOverlayLayer))
         {
            config.pageManager.loadingOverlayLayer.playTransition();
         }
         this.checkMonitorReady();
         if(config.saga)
         {
            config.saga.triggerSceneEnterState(this.loader.url);
         }
      }
      
      protected function sceneExitHandler(param1:SceneEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Scene = null;
         var _loc4_:int = 0;
         if(cleanedup)
         {
            return;
         }
         dispatchEvent(new Event(EVENT_SCENE_EXITING));
         if(config.runMode.town)
         {
            if(data.getValue(GameStateDataEnum.REMATCH))
            {
               config.fsm.transitionTo(VersusFindMatchState,data);
               return;
            }
            _loc2_ = data.getValue(GameStateDataEnum.BATTLE_FRIEND_LOBBY_ID);
            if(Boolean(config.factions) && _loc2_ == config.factions.lobbyManager.current.options.lobby_id)
            {
               config.factions.lobbyManager.current.ready = false;
               config.fsm.transitionTo(FriendLobbyState,null);
            }
            else
            {
               if(config.saga)
               {
                  _loc3_ = param1.scene;
                  _loc4_ = !!_loc3_ ? _loc3_.uniqueId : 0;
                  config.saga.triggerSceneExit(this.loader.url,_loc4_);
                  return;
               }
               if(config.options.startInFactions)
               {
                  config.fsm.transitionTo(TownLoadState,null);
               }
            }
         }
         else if(config.runMode == RunMode.KIOSK)
         {
            config.context.appInfo.exitGame("SceneState.sceneExitHandler runMode=" + config.runMode);
         }
         else
         {
            config.fsm.transitionTo(VersusFindMatchState,data);
         }
      }
      
      public function get scene() : Scene
      {
         return this.loader.scene;
      }
      
      override protected function handleCleanup() : void
      {
         if(cleanedup)
         {
            return;
         }
         if(this.tut)
         {
            this.tut.cleanup();
            this.tut = null;
         }
         this.scene.exitScene();
         this.scene.removeEventListener(SceneEvent.EXIT,this.sceneExitHandler);
         super.handleCleanup();
         if(this.battleHandler)
         {
            this.battleHandler.cleanup();
            this.battleHandler = null;
         }
         if(this.loader)
         {
            if(!data.getValue(GameStateDataEnum.SCENELOADER_PRESERVE))
            {
               this.loader.checkCleanup();
            }
            else
            {
               this.loader.pause();
            }
            this.loader = null;
            this.party = null;
         }
      }
      
      public function shellCmdFuncBattle(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(Boolean(this.battleHandler) && Boolean(this.battleHandler.fsm))
         {
            _loc2_ = _loc2_.slice(1);
            this.battleHandler._fsm.shell.execArgv(param1.cmdline,_loc2_);
         }
         else
         {
            logger.info("Current has no shell handler");
         }
      }
      
      override public function handleMessage(param1:Object) : Boolean
      {
         if(this.battleHandler)
         {
            if(this.battleHandler.fsm)
            {
               return this.battleHandler.fsm.handleMessage(param1);
            }
         }
         return false;
      }
      
      public function handleLandscapeClick(param1:String) : Boolean
      {
         return false;
      }
      
      public function showWarResolution(param1:WarOutcome, param2:BattleFinishedData) : void
      {
         this.warOutcome = param1;
         this.warFinished = param2;
         dispatchEvent(new Event(EVENT_WAR_RESOLUTION));
      }
      
      public function showBattleResolution(param1:BattleFinishedData, param2:Boolean) : void
      {
         BattleFsmConfig.guiHudEnabled = true;
         this.warOutcome = null;
         this.battleFinished = param1;
         this.battleResolutionShowStats = param2;
         dispatchEvent(new Event(EVENT_BATTLE_RESOLUTION));
      }
      
      public function respawnBattle(param1:int, param2:String, param3:String, param4:String) : void
      {
         if(this.battleHandler)
         {
            this.battleHandler.respawnBattle(param1,param2,param3,param4);
            this.scene.respawnBattleMusic();
         }
      }
      
      public function get resourcesReady() : Boolean
      {
         return this._resourcesReady;
      }
      
      public function setResourcesReady() : void
      {
         if(this._resourcesReady)
         {
            return;
         }
         this._resourcesReady = true;
         if(cleanedup || phase.value >= StatePhase.COMPLETING.value)
         {
            return;
         }
         dispatchEvent(new Event(EVENT_RESOURCES_READY));
      }
      
      override public function handleTransitioningOut() : void
      {
         if(cleanedup)
         {
            return;
         }
         if(this.scene.forceTransitionOut)
         {
            isReadyForTransitionOut = true;
         }
         this.scene.pause();
         if(hasEventListener(EVENT_SCENE_TRANSITIONING_OUT))
         {
            dispatchEvent(new Event(EVENT_SCENE_TRANSITIONING_OUT));
         }
         else
         {
            isReadyForTransitionOut = true;
         }
      }
   }
}
