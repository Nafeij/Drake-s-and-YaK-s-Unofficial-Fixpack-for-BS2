package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.IHappeningDefProvider;
   import flash.utils.Dictionary;
   
   public class SagaTriggerDefBag
   {
       
      
      public var list:Vector.<SagaTriggerDef>;
      
      public var happenings:IHappeningDefProvider;
      
      public var types:Dictionary;
      
      public function SagaTriggerDefBag(param1:IHappeningDefProvider)
      {
         this.list = new Vector.<SagaTriggerDef>();
         super();
         this.happenings = param1;
      }
      
      public function get hasTriggers() : Boolean
      {
         return Boolean(this.list) && Boolean(this.list.length);
      }
      
      public function hasTriggersForType(param1:SagaTriggerType) : Boolean
      {
         return Boolean(this.types) && Boolean(this.types[param1]);
      }
      
      public function clone() : SagaTriggerDefBag
      {
         var _loc2_:SagaTriggerDef = null;
         var _loc1_:SagaTriggerDefBag = new SagaTriggerDefBag(this.happenings);
         for each(_loc2_ in this.list)
         {
            _loc1_.addTriggerDef(_loc2_.clone());
         }
         return _loc1_;
      }
      
      public function addTriggerDef(param1:SagaTriggerDef, param2:int = -1) : SagaTriggerDef
      {
         if(param2 > -1 && param2 < this.list.length)
         {
            this.list.splice(param2,0,param1);
         }
         else
         {
            this.list.push(param1);
         }
         this.handleTriggerType(param1);
         return param1;
      }
      
      public function removeTriggerDef(param1:SagaTriggerDef) : SagaTriggerDef
      {
         this.unhandleTriggerType(param1);
         var _loc2_:int = this.list.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.list.splice(_loc2_,1);
         }
         return param1;
      }
      
      private function handleTriggerType(param1:SagaTriggerDef) : void
      {
         switch(param1.type)
         {
            case SagaTriggerType.LOCATION:
         }
         if(!this.types)
         {
            this.types = new Dictionary();
         }
         this.types[param1.type] = true;
      }
      
      private function unhandleTriggerType(param1:SagaTriggerDef) : void
      {
         switch(param1.type)
         {
            case SagaTriggerType.LOCATION:
         }
      }
      
      public function getLocationTriggers(param1:String, param2:Vector.<SagaTriggerDef>) : Vector.<SagaTriggerDef>
      {
         var _loc3_:SagaTriggerDef = null;
         for each(_loc3_ in this.list)
         {
            if(_loc3_.type == SagaTriggerType.LOCATION && (!param1 || _loc3_.location == param1))
            {
               if(!param2)
               {
                  param2 = new Vector.<SagaTriggerDef>();
               }
               param2.push(_loc3_);
            }
         }
         return param2;
      }
      
      public function createNewTrigger(param1:HappeningDef, param2:SagaTriggerType = null, param3:int = -1) : SagaTriggerDef
      {
         var _loc4_:SagaTriggerDef = new SagaTriggerDef(param1,this);
         if(param2)
         {
            _loc4_.type = param2;
         }
         return this.addTriggerDef(_loc4_,param3);
      }
      
      public function changeTriggerType(param1:SagaTriggerDef, param2:SagaTriggerType) : void
      {
         this.unhandleTriggerType(param1);
         param1.type = param2;
         this.handleTriggerType(param1);
      }
      
      public function getTriggersByType(param1:SagaTriggerType, param2:Vector.<SagaTriggerDef>, param3:String, param4:String, param5:ILogger) : Vector.<SagaTriggerDef>
      {
         var _loc6_:SagaTriggerDef = null;
         for each(_loc6_ in this.list)
         {
            if(_loc6_.type == param1)
            {
               if(!param3 || _loc6_.varname == param3)
               {
                  if(param4)
                  {
                     if(param5)
                     {
                        param5.info("Triggers were filtered out for " + _loc6_ + " due to " + param4);
                     }
                  }
                  else
                  {
                     if(!param2)
                     {
                        param2 = new Vector.<SagaTriggerDef>();
                     }
                     param2.push(_loc6_);
                  }
               }
            }
         }
         return param2;
      }
   }
}
