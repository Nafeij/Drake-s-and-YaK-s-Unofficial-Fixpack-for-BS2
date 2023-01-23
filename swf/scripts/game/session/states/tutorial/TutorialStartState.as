package game.session.states.tutorial
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import game.cfg.GameConfig;
   import game.session.GameState;
   
   public class TutorialStartState extends GameState
   {
       
      
      public function TutorialStartState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      public static function staticSetup(param1:GameConfig) : void
      {
         param1.stashed_account_info = param1.accountInfo;
         if(param1.factions)
         {
            param1.accountInfo = param1.factions.generateStartingRoster(true);
         }
         param1.alerts.enabled = false;
      }
      
      override protected function handleEnteredState() : void
      {
         staticSetup(config);
         phase = StatePhase.COMPLETED;
      }
   }
}
