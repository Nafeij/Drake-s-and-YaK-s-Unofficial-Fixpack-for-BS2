package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SagaBucketVars extends SagaBucket
   {
      
      public static const schema:Object = {
         "name":"SagaBucketVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "ents":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "shitlistId":{
               "type":"string",
               "optional":true
            },
            "xents":{
               "type":"array",
               "items":SagaBucketEnt.schema,
               "optional":true
            }
         }
      };
       
      
      public function SagaBucketVars()
      {
         super();
      }
      
      public static function save(param1:SagaBucket) : Object
      {
         var _loc3_:SagaBucketEnt = null;
         var _loc2_:Object = {
            "name":param1.name,
            "xents":[]
         };
         if(param1.shitlistId)
         {
            _loc2_.shitlistId = param1.shitlistId;
         }
         for each(_loc3_ in param1._ents)
         {
            _loc2_.xents.push(_loc3_.toJson());
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaBucketVars
      {
         var _loc3_:Object = null;
         var _loc4_:SagaBucketEnt = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.name = param1.name;
         if(param1.ents)
         {
            for each(_loc3_ in param1.ents)
            {
               _loc4_ = new SagaBucketEnt().setEntityId(_loc3_ as String);
               if(!addEntity(_loc4_,false))
               {
                  param2.error("Unable to add entity to bucket, perhaps a duplicate? [" + _loc4_ + "]");
               }
            }
         }
         if(param1.xents)
         {
            for each(_loc3_ in param1.xents)
            {
               _loc4_ = new SagaBucketEnt().fromJson(_loc3_,param2,this);
               if(!addEntity(_loc4_,false))
               {
                  param2.error("Unable to add entity to bucket, perhaps a duplicate? [" + _loc4_ + "]");
               }
            }
         }
         shitlistId = param1.shitlistId;
         _updateMinRequirements();
         return this;
      }
   }
}
