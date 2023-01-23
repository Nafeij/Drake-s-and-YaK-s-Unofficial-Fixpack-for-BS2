package engine.saga.action
{
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.landscape.travel.model.Travel_WipeData;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import flash.events.Event;
   
   public class Action_Camp extends BaseAction_TravelLocation
   {
       
      
      private var theUrl:String;
      
      public function Action_Camp(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
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
      
      override protected function handleTriggerSceneLoaded(param1:String, param2:int) : void
      {
         if(param1 != this.theUrl)
         {
            return;
         }
         if(def.instant)
         {
            end();
         }
      }
      
      override protected function handleEnded() : void
      {
         saga.removeEventListener(SagaEvent.EVENT_HALT,this.haltHandler);
         saga.cancelHalting(this.toString());
      }
      
      private function campHandler(param1:Event) : void
      {
         if(!saga.camped)
         {
            saga.removeEventListener(SagaEvent.EVENT_CAMP,this.campHandler);
            end();
         }
      }
      
      private function haltHandler(param1:Event) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:TravelLocator = null;
         var _loc5_:Travel_FallData = null;
         var _loc6_:Travel_WipeData = null;
         if(saga.halted)
         {
            if(!def.instant)
            {
               saga.addEventListener(SagaEvent.EVENT_CAMP,this.campHandler);
            }
            saga.removeEventListener(SagaEvent.EVENT_HALT,this.haltHandler);
            if(!def.restore_scene)
            {
               saga.campSceneStateClear();
            }
            _loc2_ = !def.param || def.param.indexOf("nopan") < 0;
            saga.camped = true;
            if(def.scene)
            {
               this.theUrl = def.scene;
            }
            else
            {
               this.theUrl = saga.getCampSceneUrl();
               if(!this.theUrl)
               {
                  throw new ArgumentError("No camp scene url fetched!");
               }
            }
            if(def.location)
            {
               _loc3_ = def.location;
               _loc4_ = generateTravelLocator(_loc3_);
               _loc6_ = generateWipeData(def.param);
               saga.performTravelStart(this.theUrl,_loc4_,_loc5_,_loc6_,def.happeningId,false);
            }
            else
            {
               saga.performSceneStart(this.theUrl,def.happeningId,_loc2_);
            }
         }
      }
   }
}
