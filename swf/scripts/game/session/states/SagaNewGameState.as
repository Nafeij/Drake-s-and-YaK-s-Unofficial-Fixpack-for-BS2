package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class SagaNewGameState extends GameState
   {
       
      
      public var profile_index:int = -1;
      
      public var happening_id:String;
      
      public function SagaNewGameState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this.profile_index = param1.getValue(GameStateDataEnum.NEW_GAME_PROFILE);
         this.happening_id = param1.getValue(GameStateDataEnum.HAPPENING_ID);
      }
   }
}
