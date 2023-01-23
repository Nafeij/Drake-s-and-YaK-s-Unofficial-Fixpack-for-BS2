package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SagaBannerDefVars extends SagaBannerDef
   {
      
      public static const schema:Object = {
         "name":"SagaBannerDefVars",
         "type":"object",
         "properties":{
            "lengths_world":{
               "type":"array",
               "items":SagaBannerLengthDefVars.schema
            },
            "lengths_close":{
               "type":"array",
               "items":SagaBannerLengthDefVars.schema
            },
            "hud_name":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function SagaBannerDefVars()
      {
         super();
      }
      
      public static function save(param1:SagaBannerDef) : Object
      {
         var _loc2_:Object = {
            "lengths_world":lengthsToArray(param1.lengths_world),
            "lengths_close":lengthsToArray(param1.lengths_close)
         };
         if(param1.hud_name)
         {
            _loc2_.hud_name = param1.hud_name;
         }
         return _loc2_;
      }
      
      private static function arrayToLengths(param1:Array, param2:Vector.<SagaBannerLengthDef>, param3:ILogger) : void
      {
         var _loc4_:Object = null;
         var _loc5_:SagaBannerLengthDef = null;
         for each(_loc4_ in param1)
         {
            _loc5_ = new SagaBannerLengthDefVars().fromJson(_loc4_,param3);
            param2.push(_loc5_);
         }
      }
      
      private static function lengthsToArray(param1:Vector.<SagaBannerLengthDef>) : Array
      {
         var _loc3_:SagaBannerLengthDef = null;
         var _loc2_:Array = [];
         for each(_loc3_ in param1)
         {
            _loc2_.push(SagaBannerLengthDefVars.save(_loc3_));
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaBannerDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         arrayToLengths(param1.lengths_world,lengths_world,param2);
         arrayToLengths(param1.lengths_close,lengths_close,param2);
         this.hud_name = param1.hud_name;
         return this;
      }
   }
}
