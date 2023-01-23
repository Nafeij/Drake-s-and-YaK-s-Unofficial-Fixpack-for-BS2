package engine.saga
{
   import engine.core.logging.ILogger;
   
   public class SagaBucketEnt
   {
      
      public static const schema:Object = {
         "name":"SagaBucketEnt",
         "type":"object",
         "properties":{
            "entityId":{"type":"string"},
            "weight":{
               "type":"number",
               "optional":true
            },
            "min":{
               "type":"number",
               "optional":true
            },
            "max":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public var entityId:String;
      
      public var weight:Number = 0;
      
      public var min:int;
      
      public var max:int;
      
      public function SagaBucketEnt()
      {
         super();
      }
      
      public function toString() : String
      {
         return this.entityId;
      }
      
      public function setEntityId(param1:String) : SagaBucketEnt
      {
         this.entityId = param1;
         return this;
      }
      
      public function setMin(param1:int) : SagaBucketEnt
      {
         this.min = param1;
         return this;
      }
      
      public function setRules(param1:Number, param2:int, param3:int) : SagaBucketEnt
      {
         this.weight = param1;
         this.min = param2;
         this.max = param3;
         return this;
      }
      
      public function clone() : SagaBucketEnt
      {
         var _loc1_:SagaBucketEnt = new SagaBucketEnt();
         _loc1_.entityId = this.entityId;
         _loc1_.weight = this.weight;
         _loc1_.min = this.min;
         _loc1_.max = this.max;
         return _loc1_;
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:SagaBucket) : SagaBucketEnt
      {
         this.entityId = param1.entityId;
         if(!this.entityId)
         {
            param2.error("Invalid entityId on SagaBucketEnt");
         }
         if(param1.weight != undefined)
         {
            this.weight = param1.weight;
         }
         if(param1.min != undefined)
         {
            this.min = param1.min;
         }
         if(param1.max != undefined)
         {
            this.max = param1.max;
         }
         if(this.max > 0 && this.max < this.min)
         {
            param2.error("Invalid max (" + this.max + ") < min (" + this.min + ") on " + this + " from " + param3);
         }
         if(this.max < 0 || this.min < 0)
         {
            param2.error("invalid negative min/max " + this.min + "/" + this.max + " on " + this + " from " + param3);
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {"entityId":this.entityId};
         if(Boolean(this.weight) && this.weight != 1)
         {
            _loc1_.weight = this.weight;
         }
         if(this.min != 0)
         {
            _loc1_.min = this.min;
         }
         if(this.max)
         {
            _loc1_.max = this.max;
         }
         return _loc1_;
      }
   }
}
