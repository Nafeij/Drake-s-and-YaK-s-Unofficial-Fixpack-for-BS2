package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import flash.events.Event;
   
   public class Action_Halt extends Action
   {
       
      
      public function Action_Halt(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(Boolean(def.param) && def.param.indexOf("snap_halt") >= 0)
         {
            this.snapHalt();
         }
         else
         {
            this.setHalting();
         }
      }
      
      private function snapHalt() : void
      {
         if(def.varvalue > 0)
         {
            saga.halted = true;
            end();
         }
         else
         {
            saga.cancelHalting("snap_halt canceled " + this);
            saga.halted = false;
         }
      }
      
      private function setHalting() : void
      {
         if(def.varvalue > 0)
         {
            if(saga.halted || saga.halting)
            {
               end();
               return;
            }
            saga.setHalting(def.location,"start " + this);
            saga.addEventListener(SagaEvent.EVENT_HALT,this.haltHandler);
            if(def.instant)
            {
               end();
            }
         }
         else
         {
            saga.cancelHalting("start " + this);
            end();
         }
      }
      
      private function haltHandler(param1:Event) : void
      {
         if(saga.halted)
         {
            end();
         }
      }
   }
}
