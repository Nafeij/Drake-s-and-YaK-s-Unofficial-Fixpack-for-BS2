package game.session.states
{
   import engine.core.RunMode;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.session.GameState;
   import game.session.actions.VsType;
   import game.session.states.tutorial.TutorialStartState;
   import game.session.states.tutorial.TutorialTownLoadState;
   
   public class FactionsState extends GameState
   {
       
      
      public function FactionsState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         if(!credentials.valid || !credentials.displayName || !credentials.userId || !credentials.sessionKey)
         {
            logger.info("FactionsState not logged in, going back to auth");
            data.setValue(GameStateDataEnum.AUTH_REQUIRE,true);
            config.fsm.transitionTo(PreAuthState,data);
            return;
         }
         config.addEventListener(GameConfig.EVENT_FACTIONS,this.factionsHandler);
         config.loadFactions();
      }
      
      private function factionsHandler(param1:Event) : void
      {
         var _loc2_:int = 0;
         if(!config.runMode.town || config.runMode == RunMode.KIOSK)
         {
            data.setValue(GameStateDataEnum.BATTLE_TIMER_SECS,45);
            data.setValue(GameStateDataEnum.VERSUS_TYPE,VsType.QUICK);
            config.fsm.transitionTo(VersusFindMatchState,data);
            return;
         }
         if(!config.fsm.session.credentials.offline)
         {
            if(config.options.startInVersus)
            {
               _loc2_ = config.options.overrideTurnLengthSecs >= 0 ? config.options.overrideTurnLengthSecs : 30;
               data.setValue(GameStateDataEnum.BATTLE_TIMER_SECS,_loc2_);
               data.setValue(GameStateDataEnum.FORCE_OPPONENT_ID,config.options.versusForceOpponentId);
               data.setValue(GameStateDataEnum.VERSUS_TOURNEY_ID,config.options.versusForceTourneyId);
               data.setValue(GameStateDataEnum.VERSUS_TYPE,VsType.RANKED);
               config.fsm.transitionTo(VersusFindMatchState,data);
               return;
            }
         }
         if(config.options.testTutorial)
         {
            TutorialStartState.staticSetup(config);
            config.fsm.transitionTo(TutorialTownLoadState,data);
            return;
         }
         if(!config.accountInfo.completed_tutorial)
         {
            if(!config.fsm.credentials.offline)
            {
               config.fsm.transitionTo(TutorialStartState,data);
               return;
            }
         }
         phase = StatePhase.COMPLETED;
      }
   }
}
