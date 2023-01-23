package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.saga.save.GameSaveSynchronizer;
   import engine.scene.model.SceneLoaderBattleInfo;
   import engine.session.IAuthentication;
   import engine.session.NullAuthentication;
   import engine.user.UserLifecycleManager;
   import flash.events.Event;
   import game.entry.SimpleSteamAuth;
   import game.gui.IGuiDialog;
   import game.session.GameState;
   import tbs.srv.battle.data.client.BattleCreateData;
   
   public class StartState extends GameState
   {
      
      public static var authenticator:IAuthentication;
      
      public static var SIMPLE_STEAM_AUTH_ENABLED:Boolean = false;
       
      
      private var initialized:Boolean = false;
      
      private var ssa:SimpleSteamAuth;
      
      private var saveSyncComplete:Boolean;
      
      public function StartState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      private function authenticatedHandler(param1:String) : void
      {
         var _loc2_:IGuiDialog = null;
         logger.info("StartState.authenticatedHandler " + this.ssa.ok);
         if(!this.ssa.ok)
         {
            _loc2_ = config.gameGuiContext.createDialog();
            _loc2_.openDialog("Steam Error","Unable to login to Steam.\n\n" + "Please ensure that:\n\n" + "1. You are connected to the internet.\n" + "2. The Steam Client is running.\n" + "3. Steam Client is NOT in \'Offline\' Mode.","OK",this.authCloseHandler);
            phase = StatePhase.FAILED;
            return;
         }
         this.checkCompleted();
      }
      
      private function authCloseHandler(param1:*) : void
      {
         config.context.appInfo.terminateError("Auth Failed");
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:IGuiDialog = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:BattleCreateData = null;
         var _loc7_:SceneLoaderBattleInfo = null;
         if(config.options.under_construction)
         {
            this.showUnderConstruction(config.options.under_construction);
            return;
         }
         logger.debug("StartState.handleEnteredState authenticator=" + authenticator + ", config=" + config + ", credentials=" + credentials);
         if(!authenticator)
         {
            logger.info("StartState.handleEnteredState creating NullAuthentication");
            authenticator = new NullAuthentication();
         }
         if(authenticator && authenticator.enabled && !authenticator.initialized)
         {
            _loc1_ = config.gameGuiContext.createDialog();
            _loc2_ = config.gameGuiContext.translate("steam_error_title");
            _loc3_ = config.gameGuiContext.translate("steam_error_body");
            _loc4_ = config.gameGuiContext.translate("ok");
            _loc1_.openDialog(_loc2_,_loc3_,_loc4_,this.steamFailHandler);
            phase = StatePhase.FAILED;
            return;
         }
         logger.debug("StartState.handleEnteredState 2");
         if(SIMPLE_STEAM_AUTH_ENABLED)
         {
            this.ssa = new SimpleSteamAuth(authenticator,logger,this.authenticatedHandler);
            this.ssa.start();
         }
         if(config.options.overrideSteamId)
         {
            logger.debug("StartState.handleEnteredState 3");
            credentials.steamId = config.options.overrideSteamId;
            credentials.displayName = "∏" + config.options.overrideSteamId;
         }
         else
         {
            logger.debug("StartState.handleEnteredState 4");
            credentials.steamId = authenticator.getUserID();
            config.client_language = authenticator.getUserLanguage();
            if(!credentials.steamId)
            {
               logger.debug("StartState.handleEnteredState $$ NO USER ID");
            }
            else
            {
               _loc5_ = authenticator.getAccountID(credentials.steamId);
               logger.info("StartState.handleEnteredState $$ USER ID=" + credentials.steamId + ", account " + _loc5_);
               credentials.displayName = authenticator.getDisplayName();
            }
         }
         if(config.options.startInCombat)
         {
            logger.info("StartState.handleEnteredState $$ starting in combat");
            _loc6_ = new BattleCreateData();
            _loc6_.scene = config.options.startInCombat;
            data.setValue(GameStateDataEnum.BATTLE_CREATE_DATA,_loc6_);
            data.setValue(GameStateDataEnum.SCENE_URL,config.options.startInCombat);
            data.setValue(GameStateDataEnum.LOCAL_PARTY,config.legend.party.getEntityListDef());
            _loc7_ = new SceneLoaderBattleInfo();
            _loc7_.battle_board_id = "*";
            data.setValue(GameStateDataEnum.BATTLE_INFO,_loc7_);
            data.setValue(GameStateDataEnum.LOCAL_TIMER_SECS,0);
            config.fsm.current.data.setValue(GameStateDataEnum.SCENE_AUTOPAN,true);
            config.fsm.transitionTo(SceneLoadState,data);
            return;
         }
         if(logger.isDebugEnabled)
         {
            logger.debug("StartState.handleEnteredState $$ showing login screen and completing");
         }
         if(config.options.startInFactions)
         {
            data.setValue(GameStateDataEnum.AUTH_REQUIRE,true);
         }
         logger.debug("StartState.handleEnteredState 5");
         data.setValue(GameStateDataEnum.AUTOLOGIN,true);
         loading = true;
         config.context.appInfo.emitPlatformEvent("dismiss_splash_screen");
         if(UserLifecycleManager.Instance().userAlwaysValid)
         {
            config.context.appInfo.setSystemIdleKeepAwake(true);
            logger.info("StartState: pull cloud saves");
            GameSaveSynchronizer.instance.addEventListener(GameSaveSynchronizer.EVENT_PULL_COMPLETE,this.onSaveSyncComplete);
            GameSaveSynchronizer.instance.pull();
         }
         else
         {
            this.onSaveSyncComplete(null);
         }
      }
      
      final private function onSaveSyncComplete(param1:Event) : void
      {
         logger.info("StartState.onSaveSyncComplete");
         GameSaveSynchronizer.instance.removeEventListener(GameSaveSynchronizer.EVENT_PULL_COMPLETE,this.onSaveSyncComplete);
         this.saveSyncComplete = true;
         this.checkCompleted();
      }
      
      private function checkCompleted() : void
      {
         if(Boolean(this.ssa) && !this.ssa.ok)
         {
            return;
         }
         loading = false;
         config.context.appInfo.setSystemIdleKeepAwake(false);
         phase = StatePhase.COMPLETED;
      }
      
      private function steamFailHandler(param1:String) : void
      {
         config.context.appInfo.exitGame("Steam could not initialize");
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
      }
      
      private function showUnderConstruction(param1:String) : void
      {
         var _loc2_:IGuiDialog = config.gameGuiContext.createDialog();
         var _loc3_:String = "Important Message";
         var _loc4_:String = param1;
         var _loc5_:String = "Ok";
         _loc2_.openDialog(_loc3_,_loc4_,_loc5_,this.underConstructionHandler);
         phase = StatePhase.FAILED;
      }
      
      private function underConstructionHandler(param1:String) : void
      {
         config.context.appInfo.exitGame("Under Construction");
      }
   }
}
