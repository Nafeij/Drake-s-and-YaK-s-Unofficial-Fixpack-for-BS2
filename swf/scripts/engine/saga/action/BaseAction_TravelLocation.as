package engine.saga.action
{
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.landscape.travel.model.Travel_WipeData;
   import engine.saga.Saga;
   import flash.errors.IllegalOperationError;
   
   public class BaseAction_TravelLocation extends Action
   {
       
      
      public function BaseAction_TravelLocation(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      protected function generateTravelLocator(param1:String) : TravelLocator
      {
         var _loc2_:TravelLocator = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(param1 == "$travel_locator")
         {
            if(!saga.caravan)
            {
               throw new IllegalOperationError("No caravan for generateTravelLocator");
            }
            _loc2_ = saga.caravan.travel_locator.clone();
            logger.info("jumping to travel locator " + _loc2_);
         }
         else
         {
            if(param1 == "$travel_location")
            {
               throw new ArgumentError("did you mean $travel_locator?");
            }
            if(param1)
            {
               _loc3_ = param1.indexOf(":");
               _loc5_ = param1;
               if(_loc3_ >= 0)
               {
                  _loc4_ = param1.substring(0,_loc3_);
                  _loc5_ = param1.substring(_loc3_ + 1);
               }
               _loc2_ = new TravelLocator().setup(_loc4_,param1);
            }
            else
            {
               _loc2_ = new TravelLocator();
            }
         }
         return _loc2_;
      }
      
      protected function generateTravelFallData(param1:String) : Travel_FallData
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:Array = param1.split(";");
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.split("=");
            if(_loc4_.length != 2)
            {
               continue;
            }
            switch(_loc4_[0])
            {
               case "fallData":
                  return this.parseTravelFallDataValue(_loc4_[1]);
            }
         }
         return null;
      }
      
      protected function parseTravelFallDataValue(param1:String) : Travel_FallData
      {
         var _loc3_:Travel_FallData = null;
         var _loc2_:Array = param1.split("@");
         if(Boolean(_loc2_) && _loc2_.length == 2)
         {
            return new Travel_FallData(_loc2_[0],_loc2_[1]);
         }
         return null;
      }
      
      protected function generateWipeData(param1:String) : Travel_WipeData
      {
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc2_:Travel_WipeData = new Travel_WipeData();
         if(!param1)
         {
            return _loc2_;
         }
         var _loc3_:Array = param1.split(";");
         var _loc4_:int = 0;
         for(; _loc4_ < _loc3_.length; _loc4_++)
         {
            _loc5_ = _loc3_[_loc4_];
            _loc6_ = _loc5_.split("=");
            if(_loc6_.length != 2)
            {
               continue;
            }
            switch(_loc6_[0])
            {
               case "wipeIn":
                  _loc2_.wipeIn = Number(_loc6_[1]);
                  break;
               case "wipeHold":
                  _loc2_.wipeHold = Number(_loc6_[1]);
                  break;
            }
         }
         return _loc2_;
      }
   }
}
