package engine.saga
{
   import flash.utils.Dictionary;
   
   public class SagaMetricsEntry
   {
       
      
      public var plus:Dictionary;
      
      public var minus:Dictionary;
      
      public var total:Dictionary;
      
      public function SagaMetricsEntry()
      {
         this.plus = new Dictionary();
         this.minus = new Dictionary();
         this.total = new Dictionary();
         super();
      }
      
      private static function cloneDict(param1:Dictionary, param2:Dictionary) : void
      {
         var _loc3_:* = null;
         for(_loc3_ in param1)
         {
            param2[_loc3_] = param1[_loc3_];
         }
      }
      
      private static function dictionaryToJson(param1:Dictionary) : Object
      {
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc2_:Object = {};
         for(_loc3_ in param1)
         {
            _loc4_ = int(param1[_loc3_]);
            _loc2_[_loc3_] = _loc4_;
         }
         return _loc2_;
      }
      
      public function clone() : SagaMetricsEntry
      {
         var _loc1_:SagaMetricsEntry = new SagaMetricsEntry();
         cloneDict(this.plus,_loc1_.plus);
         cloneDict(this.minus,_loc1_.minus);
         cloneDict(this.total,_loc1_.total);
         return _loc1_;
      }
      
      public function handleVariableChanged(param1:String, param2:int, param3:int) : void
      {
         if(param3 > param2)
         {
            this.incrementDictionary(this.plus,param1,param3 - param2);
         }
         else if(param3 < param2)
         {
            this.incrementDictionary(this.minus,param1,param2 - param3);
         }
         this.total[param1] = param3;
      }
      
      public function setTotal(param1:String, param2:int) : void
      {
         this.total[param1] = param2;
      }
      
      private function incrementDictionary(param1:Dictionary, param2:String, param3:int) : void
      {
         var _loc4_:* = param1[param2];
         if(_loc4_ == undefined)
         {
            _loc4_ = 0;
         }
         param1[param2] = _loc4_ + param3;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {};
         _loc1_["plus"] = dictionaryToJson(this.plus);
         _loc1_["minus"] = dictionaryToJson(this.minus);
         _loc1_["total"] = dictionaryToJson(this.total);
         return _loc1_;
      }
   }
}
