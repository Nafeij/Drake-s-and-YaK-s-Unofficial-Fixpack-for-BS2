package game.session.states.tutorial
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.session.states.VideoState;
   
   public class TutorialVideoPart2State extends VideoState
   {
       
      
      public function TutorialVideoPart2State(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
         url_actual = "common/video/tutorial_intro_video2.720.flv";
      }
   }
}
