package engine.saga.action
{
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.landscape.travel.model.Travel_WipeData;
   import engine.saga.Saga;
   
   public class Action_Travel extends BaseAction_TravelLocation
   {
       
      
      public function Action_Travel(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.location;
         var _loc2_:TravelLocator = generateTravelLocator(_loc1_);
         var _loc3_:Travel_FallData = generateTravelFallData(def.param);
         var _loc4_:Travel_WipeData = generateWipeData(def.param);
         saga.performTravelStart(def.scene,_loc2_,_loc3_,_loc4_,def.happeningId,true);
         if(def.instant)
         {
            end();
         }
      }
      
      override protected function handleTriggerSceneLoaded(param1:String, param2:int) : void
      {
         if(param1 == def.scene)
         {
            end();
         }
      }
   }
}
