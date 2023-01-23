package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.gp.GpBinder;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class LoadGameState extends GameState
   {
       
      
      public function LoadGameState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         GpBinder.DISALLOW_INPUT_DURING_LOAD = true;
      }
      
      override protected function handleInterrupted() : void
      {
         GpBinder.DISALLOW_INPUT_DURING_LOAD = false;
      }
      
      override protected function handleCleanup() : void
      {
         GpBinder.DISALLOW_INPUT_DURING_LOAD = false;
      }
   }
}
