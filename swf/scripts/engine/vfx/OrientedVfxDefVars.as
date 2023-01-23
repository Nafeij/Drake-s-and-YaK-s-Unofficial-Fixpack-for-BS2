package engine.vfx
{
   import engine.anim.def.IAnimFacing;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class OrientedVfxDefVars extends OrientedVfxDef
   {
      
      public static const schema:Object = {
         "name":"OrientedVfxDefVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "fallback":{"type":"string"},
            "facings":{
               "type":"array",
               "items":{"properties":{
                  "facing":{"type":"string"},
                  "vfx":{"type":"string"}
               }}
            }
         }
      };
       
      
      public function OrientedVfxDefVars(param1:Object, param2:Class, param3:ILogger)
      {
         var _loc4_:Object = null;
         var _loc5_:IAnimFacing = null;
         var _loc6_:String = null;
         var _loc7_:IAnimFacing = null;
         super();
         EngineJsonDef.validateThrow(param1,schema,param3);
         name = param1.name;
         for each(_loc4_ in param1.facings)
         {
            _loc6_ = _loc4_.vfx;
            _loc7_ = Enum.parse(param2,_loc4_.facing) as IAnimFacing;
            addVfx(_loc7_,_loc6_);
         }
         _loc5_ = Enum.parse(param2,param1.fallback) as IAnimFacing;
         setFallback(_loc5_);
      }
      
      public static function save(param1:OrientedVfxDef) : Object
      {
         var _loc3_:* = null;
         var _loc4_:IAnimFacing = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc2_:Object = {
            "name":param1.name,
            "fallback":param1.fallback.name,
            "facings":[]
         };
         for(_loc3_ in param1.vfxByFacing)
         {
            _loc4_ = _loc3_ as IAnimFacing;
            _loc5_ = param1.vfxByFacing[_loc4_];
            _loc6_ = {
               "facing":_loc4_.name,
               "vfx":_loc5_
            };
            _loc2_.facings.push(_loc6_);
         }
         return _loc2_;
      }
   }
}
