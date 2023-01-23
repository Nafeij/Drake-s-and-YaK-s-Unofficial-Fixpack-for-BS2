package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class HallOfValorState extends GameState
   {
       
      
      public function HallOfValorState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         gameFsm.updateGameLocation("loc_hall_of_valor");
      }
   }
}
