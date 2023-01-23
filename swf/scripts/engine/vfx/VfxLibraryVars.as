package engine.vfx
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class VfxLibraryVars extends VfxLibrary
   {
      
      public static const schema:Object = {
         "name":"VfxLibraryVars",
         "type":"object",
         "properties":{
            "inherits":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "orientedVfx":{
               "type":"array",
               "items":OrientedVfxDefVars.schema,
               "optional":true
            },
            "effects":{
               "type":"array",
               "items":VfxDefVars.schema,
               "optional":true
            }
         }
      };
       
      
      public function VfxLibraryVars(param1:String, param2:Object, param3:ILogger)
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:OrientedVfxDefVars = null;
         var _loc8_:VfxDefVars = null;
         super(param1,param3);
         EngineJsonDef.validateThrow(param2,schema,param3);
         for each(_loc4_ in param2.inherits)
         {
            inheritUrls.push(_loc4_);
         }
         if(param2.orientedVfx != undefined && param2.orientedVfx.length > 0)
         {
            for each(_loc6_ in param2.orientedVfx)
            {
               _loc7_ = new OrientedVfxDefVars(_loc6_,BattleFacing,param3);
               addOrientedVfxDef(_loc7_);
            }
         }
         for each(_loc5_ in param2.effects)
         {
            _loc8_ = new VfxDefVars(_loc5_,param3,this);
            addVfxDef(_loc8_);
         }
         if(vfxDefs.length == 0 && inheritUrls.length == 0)
         {
            throw new ArgumentError("No effects or inherits, surely a mistake.");
         }
      }
      
      public static function save(param1:VfxLibrary) : Object
      {
         var _loc3_:VfxDef = null;
         var _loc4_:String = null;
         var _loc5_:OrientedVfxDef = null;
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc2_:Object = {
            "orientedVfx":[],
            "effects":[],
            "inherits":[]
         };
         if(param1.orientedVfxDefs.length > 0)
         {
            for each(_loc5_ in param1.orientedVfxDefs)
            {
               _loc6_ = OrientedVfxDefVars.save(_loc5_);
               _loc2_.orientedVfx.push(_loc6_);
            }
         }
         for each(_loc3_ in param1.vfxDefs)
         {
            _loc7_ = VfxDefVars.save(_loc3_);
            _loc2_.effects.push(_loc7_);
         }
         for each(_loc4_ in param1.inheritUrls)
         {
            _loc2_.inherits.push(_loc4_);
         }
         return _loc2_;
      }
   }
}
