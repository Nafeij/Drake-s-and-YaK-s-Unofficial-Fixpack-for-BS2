package engine.gui
{
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class GuiEventEater implements IGuiEventEater
   {
       
      
      private var eatenEvents:Dictionary;
      
      private var regurgitator:Timer;
      
      public function GuiEventEater()
      {
         this.eatenEvents = new Dictionary();
         this.regurgitator = new Timer(3000,0);
         super();
         this.regurgitator.addEventListener(TimerEvent.TIMER,this.regurgitatorHandler);
      }
      
      private function regurgitatorHandler(param1:TimerEvent) : void
      {
         if(this.eatenEvents)
         {
            this.regurgitator.stop();
         }
      }
      
      public function eatEvent(param1:MouseEvent) : void
      {
         if(!this.eatenEvents)
         {
            this.eatenEvents = new Dictionary();
            this.regurgitator.start();
         }
         this.eatenEvents[param1] = param1;
      }
      
      public function isEventEaten(param1:MouseEvent) : Boolean
      {
         return this.eatenEvents[param1];
      }
   }
}
