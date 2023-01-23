package game.session.states.tutorial
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   import game.session.actions.TutorialCompletedTxn;
   
   public class TutorialEndState extends GameState
   {
       
      
      public function TutorialEndState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         logger.info("TutorialEndState DONE");
         if(config.stashed_account_info)
         {
            config.accountInfo = config.stashed_account_info;
            config.stashed_account_info = null;
         }
         config.accountInfo.completed_tutorial = true;
         var _loc1_:TutorialCompletedTxn = new TutorialCompletedTxn(config.fsm.credentials,null,config.logger);
         _loc1_.send(config.fsm.communicator);
         phase = StatePhase.COMPLETED;
      }
   }
}
