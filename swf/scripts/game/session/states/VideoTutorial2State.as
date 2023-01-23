package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   
   public class VideoTutorial2State extends VideoState
   {
       
      
      public function VideoTutorial2State(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
         url_actual = "factions/video/tutorial_advanced.mp4";
      }
   }
}
