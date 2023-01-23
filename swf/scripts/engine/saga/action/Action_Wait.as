package engine.saga.action
{
   import engine.saga.Saga;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Action_Wait extends Action
   {
      
      public static var DISABLE:Boolean;
       
      
      public function Action_Wait(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(DISABLE)
         {
            end();
            return;
         }
         var _loc1_:Timer = new Timer(def.time * 1000,1);
         _loc1_.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerComplete);
         _loc1_.start();
      }
      
      private function timerComplete(param1:TimerEvent) : void
      {
         (param1.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerComplete);
         end();
      }
      
      override public function fastForward() : Boolean
      {
         if(!ended && !def.instant)
         {
            end(true);
            return true;
         }
         return false;
      }
   }
}
