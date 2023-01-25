package engine.anim.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class OrientedAnimsDefVars extends OrientedAnimsDef
   {
      
      public static const schema:Object = {
         "name":"OrientedAnimsDefVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "fallback":{"type":"string"},
            "flipsFacing":{
               "type":"boolean",
               "optional":true
            },
            "facings":{
               "type":"array",
               "items":{"properties":{
                  "facing":{"type":"string"},
                  "anim":{"type":"string"}
               }}
            }
         }
      };
       
      
      public function OrientedAnimsDefVars(param1:Object, param2:Class, param3:ILogger)
      {
         var _loc4_:Object = null;
         var _loc5_:IAnimFacing = null;
         var _loc6_:String = null;
         var _loc7_:IAnimFacing = null;
         super();
         EngineJsonDef.validateThrow(param1,schema,param3);
         name = param1.name;
         flipsFacing = param1.flipsFacing;
         for each(_loc4_ in param1.facings)
         {
            _loc6_ = String(_loc4_.anim);
            _loc7_ = Enum.parse(param2,_loc4_.facing) as IAnimFacing;
            addAnim(_loc7_,_loc6_);
         }
         _loc5_ = Enum.parse(param2,param1.fallback) as IAnimFacing;
         setFallback(_loc5_);
      }
      
      public static function save(param1:OrientedAnimsDef) : Object
      {
         var _loc3_:Object = null;
         var _loc4_:IAnimFacing = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc2_:Object = {
            "name":param1.name,
            "fallback":param1.fallback.name,
            "facings":[]
         };
         for(_loc3_ in param1.animsByFacing)
         {
            _loc4_ = _loc3_ as IAnimFacing;
            _loc5_ = String(param1.animsByFacing[_loc4_]);
            _loc6_ = {
               "facing":_loc4_.name,
               "anim":_loc5_
            };
            _loc2_.facings.push(_loc6_);
         }
         if(param1.flipsFacing)
         {
            _loc2_.flipsFacing = param1.flipsFacing;
         }
         return _loc2_;
      }
   }
}
