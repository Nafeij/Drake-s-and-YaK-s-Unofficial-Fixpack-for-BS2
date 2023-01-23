package engine.anim.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class AnimMixDefVars extends AnimMixDef
   {
      
      public static const schema:Object = {
         "name":"AnimMixDefVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "mixdefault":{
               "type":"boolean",
               "optional":true
            },
            "entries":{
               "type":"array",
               "items":AnimMixEntryDefVars.schema
            }
         }
      };
       
      
      public function AnimMixDefVars(param1:Object, param2:ILogger)
      {
         var _loc3_:Object = null;
         var _loc4_:AnimMixEntryDef = null;
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         name = param1.name;
         mixdefault = param1.mixdefault;
         for each(_loc3_ in param1.entries)
         {
            _loc4_ = new AnimMixEntryDefVars(_loc3_,param2);
            entries.push(_loc4_);
            totalWeight += _loc4_.weight;
         }
      }
      
      public static function save(param1:AnimMixDef) : Object
      {
         var _loc3_:AnimMixEntryDef = null;
         var _loc4_:Object = null;
         var _loc2_:Object = {
            "name":param1.name,
            "entries":[]
         };
         if(param1.mixdefault)
         {
            _loc2_.start = param1.mixdefault;
         }
         for each(_loc3_ in param1.entries)
         {
            _loc4_ = AnimMixEntryDefVars.save(_loc3_);
            _loc2_.entries.push(_loc4_);
         }
         return _loc2_;
      }
   }
}
