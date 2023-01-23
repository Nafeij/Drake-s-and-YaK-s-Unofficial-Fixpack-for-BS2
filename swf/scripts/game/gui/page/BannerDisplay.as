package game.gui.page
{
   import engine.gui.IGuiButton;
   import flash.display.MovieClip;
   import game.session.GameFsm;
   import game.session.states.VideoTutorial1State;
   import game.session.states.VideoTutorial2State;
   import game.session.states.tutorial.TutorialStartState;
   
   public class BannerDisplay
   {
       
      
      private var mc:MovieClip;
      
      private var button$btn_basic_tutorial:IGuiButton;
      
      private var button$btn_adv_tutorial:IGuiButton;
      
      private var button$btn_replay_tutorial:IGuiButton;
      
      private var fsm:GameFsm;
      
      public function BannerDisplay(param1:GameFsm, param2:MovieClip)
      {
         super();
         this.mc = param2;
         this.fsm = param1;
         this.button$btn_basic_tutorial = param2.button$btn_basic_tutorial;
         this.button$btn_adv_tutorial = param2.button$btn_adv_tutorial;
         this.button$btn_replay_tutorial = param2.button$btn_replay_tutorial;
         this.button$btn_basic_tutorial.setDownFunction(this.basicButtonHandler);
         this.button$btn_adv_tutorial.setDownFunction(this.advButtonHandler);
         this.button$btn_replay_tutorial.setDownFunction(this.replayButtonHandler);
         this.button$btn_adv_tutorial.scaleTextToFit = true;
         this.button$btn_basic_tutorial.scaleTextToFit = true;
         this.button$btn_replay_tutorial.scaleTextToFit = true;
      }
      
      public function cleanup() : void
      {
         this.button$btn_basic_tutorial.cleanup();
         this.button$btn_adv_tutorial.cleanup();
         this.button$btn_replay_tutorial.cleanup();
         this.button$btn_basic_tutorial = null;
         this.button$btn_adv_tutorial = null;
         this.button$btn_replay_tutorial = null;
         this.mc = null;
         this.fsm = null;
      }
      
      public function basicButtonHandler(param1:IGuiButton) : void
      {
         this.fsm.transitionTo(VideoTutorial1State,this.fsm.current.data);
      }
      
      public function advButtonHandler(param1:IGuiButton) : void
      {
         this.fsm.transitionTo(VideoTutorial2State,this.fsm.current.data);
      }
      
      public function replayButtonHandler(param1:IGuiButton) : void
      {
         this.fsm.transitionTo(TutorialStartState,this.fsm.current.data);
      }
   }
}
