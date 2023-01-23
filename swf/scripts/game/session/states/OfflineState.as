package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class OfflineState extends GameState
   {
       
      
      public function OfflineState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         if(config.factions)
         {
            config.factions.createOfflineAccountInfo();
         }
         credentials.offline = true;
         if(communicator)
         {
            communicator.connected = false;
         }
         config.fsm.session.communicator = null;
         phase = StatePhase.COMPLETED;
      }
   }
}
