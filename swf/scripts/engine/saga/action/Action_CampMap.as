package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import flash.events.Event;
   
   public class Action_CampMap extends Action
   {
       
      
      public function Action_CampMap(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(saga.mapCamp)
         {
            this.doMap();
            return;
         }
         var _loc1_:Boolean = saga.halted;
         if(!_loc1_)
         {
            saga.addEventListener(SagaEvent.EVENT_HALT,this.haltHandler);
         }
         saga.setHalting(null,this.toString());
         if(_loc1_)
         {
            this.haltHandler(null);
         }
      }
      
      override protected function handleEnded() : void
      {
         saga.removeEventListener(SagaEvent.EVENT_HALT,this.haltHandler);
         saga.cancelHalting(this.toString());
      }
      
      private function doMap() : void
      {
         if(!saga.halted && !saga.mapCamp)
         {
            return;
         }
         if(!def.instant && def.restore_scene)
         {
            this.sceneStateSave();
         }
         saga.addEventListener(SagaEvent.EVENT_MAP_CAMP,this.mapCampHandler);
         var _loc1_:* = def.param == "cinema";
         saga.performMapCamp(def.happeningId,def.anchor,def.id,def.varvalue,_loc1_);
      }
      
      private function mapCampHandler(param1:Event) : void
      {
         if(saga.mapCamp)
         {
            if(def.instant)
            {
               end();
            }
         }
         else
         {
            saga.removeEventListener(SagaEvent.EVENT_MAP_CAMP,this.mapCampHandler);
            end();
         }
      }
      
      private function haltHandler(param1:Event) : void
      {
         if(saga.halted)
         {
            saga.removeEventListener(SagaEvent.EVENT_HALT,this.haltHandler);
            this.doMap();
         }
      }
   }
}
