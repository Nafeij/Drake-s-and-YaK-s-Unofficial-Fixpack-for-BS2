package game.gui.page
{
   import engine.core.fsm.FsmEvent;
   import engine.core.fsm.StatePhase;
   import engine.core.util.MovieClipUtil;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.text.TextField;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.states.ReadyState;
   
   public class StartPage extends GamePage
   {
       
      
      private var textLoading:TextField;
      
      private var mcu:MovieClipUtil;
      
      private var eventStage:DisplayObject;
      
      public function StartPage(param1:GameConfig)
      {
         super(param1);
      }
      
      protected function fsmCurrentHandler(param1:Event) : void
      {
         if(config.fsm.currentClass == ReadyState)
         {
            this.checkFinished();
         }
      }
      
      override public function cleanup() : void
      {
         config.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         super.cleanup();
      }
      
      private function checkFinished() : void
      {
         if(config.fsm.currentClass == ReadyState)
         {
            config.fsm.current.phase = StatePhase.COMPLETED;
         }
      }
   }
}
