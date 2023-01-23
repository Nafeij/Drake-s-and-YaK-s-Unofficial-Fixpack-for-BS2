package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class AuthFailedState extends GameState
   {
       
      
      public var message:String;
      
      public function AuthFailedState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleCleanup() : void
      {
      }
      
      override protected function handleEnteredState() : void
      {
         this.message = data.getValue(GameStateDataEnum.SERVER_MESSAGE);
         config.fsm.current.data.setValue(GameStateDataEnum.SHOW_LOGIN_SCREEN,true);
      }
   }
}
