package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class EntitiesMetadataVars extends EntitiesMetadata
   {
      
      public static const schema:Object = {
         "name":"EntitiesMetadataVars",
         "type":"object",
         "properties":{
            "partyTagLimits":{
               "type":"array",
               "optional":true,
               "items":{"properties":{
                  "tag":{"type":"string"},
                  "limit":{"type":"number"}
               }}
            },
            "useBaseUpgradeStat":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function EntitiesMetadataVars(param1:Object, param2:ILogger, param3:Locale)
      {
         var _loc4_:Object = null;
         super(param3);
         EngineJsonDef.validateThrow(param1,schema,param2);
         useBaseUpgradeStat = BooleanVars.parse(param1.useBaseUpgradeStat,useBaseUpgradeStat);
         if(param1.partyTagLimits)
         {
            for each(_loc4_ in param1.partyTagLimits)
            {
               setPartyTagLimit(_loc4_.tag,_loc4_.limit);
            }
         }
      }
      
      public static function save(param1:EntitiesMetadata) : Object
      {
         var _loc2_:Object = {"partyTagLimits":param1.partyTagLimits};
         if(param1.useBaseUpgradeStat)
         {
            _loc2_.useBaseUpgradeStat = true;
         }
         return _loc2_;
      }
   }
}
