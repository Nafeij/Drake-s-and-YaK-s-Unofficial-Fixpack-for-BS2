package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class SagaSurvivalStartState extends GameState
   {
       
      
      public function SagaSurvivalStartState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
   }
}
