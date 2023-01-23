package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class AuthBuildMismatchState extends GameState
   {
       
      
      public var buildNumber:String;
      
      public function AuthBuildMismatchState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleCleanup() : void
      {
      }
      
      override protected function handleEnteredState() : void
      {
         this.buildNumber = data.getValue(GameStateDataEnum.BUILD_NUMBER);
      }
      
      public function set overrideBuildNumber(param1:Boolean) : void
      {
         if(param1)
         {
            phase = StatePhase.COMPLETED;
         }
         else
         {
            config.context.appInfo.terminateError("Build Number Mismatch");
         }
      }
   }
}
