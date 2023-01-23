package engine.entity.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class PartyDefVars extends PartyDef
   {
      
      public static const schema:Object = {
         "name":"PartyDefVars",
         "type":"object",
         "properties":{"ids":{
            "type":"array",
            "items":"string"
         }}
      };
       
      
      public function PartyDefVars(param1:Object, param2:IEntityListDef, param3:ILogger)
      {
         var _loc4_:String = null;
         super(param2);
         EngineJsonDef.validateThrow(param1,schema,param3);
         for each(_loc4_ in param1.ids)
         {
            addMember(_loc4_);
         }
      }
      
      public static function save(param1:IPartyDef) : Object
      {
         var _loc3_:String = null;
         var _loc2_:Object = {};
         _loc2_.ids = [];
         for each(_loc3_ in (param1 as PartyDef).memberIds)
         {
            _loc2_.ids.push(_loc3_);
         }
         return _loc2_;
      }
   }
}
