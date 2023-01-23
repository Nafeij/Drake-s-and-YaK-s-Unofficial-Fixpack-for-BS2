package game.session.states.tutorial
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.session.states.TownLoadState;
   
   public class TutorialTownLoadState extends TownLoadState
   {
       
      
      public function TutorialTownLoadState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
      }
      
      override protected function handleCleanup() : void
      {
         super.handleCleanup();
      }
   }
}
