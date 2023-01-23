package engine.entity
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class UnitStatCostsVars extends UnitStatCosts
   {
      
      public static const schema:Object = {
         "name":"UnitStatCostsVars",
         "type":"object",
         "properties":{
            "stats":{
               "type":"array",
               "items":"number"
            },
            "promotes":{
               "type":"array",
               "items":"number"
            },
            "killsToPromote":{
               "type":"array",
               "items":"number"
            },
            "abilityLevels":{
               "type":"array",
               "items":"number"
            },
            "rename":{"type":"number"},
            "variation":{"type":"number"},
            "roster_row_cost":{"type":"number"},
            "max_num_roster_rows":{"type":"number"},
            "roster_slots_per_row":{"type":"number"},
            "allow_remove_stat_points":{
               "type":"boolean",
               "optional":true
            },
            "titleRenownCosts":{
               "type":"array",
               "items":"number"
            }
         }
      };
       
      
      public function UnitStatCostsVars(param1:Object, param2:ILogger)
      {
         var _loc3_:* = undefined;
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         var _loc6_:* = undefined;
         var _loc7_:* = undefined;
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc3_ in param1.stats)
         {
            stats.push(_loc3_);
         }
         for each(_loc4_ in param1.promotes)
         {
            promotes.push(_loc4_);
         }
         for each(_loc5_ in param1.killsToPromote)
         {
            killsToPromote.push(_loc5_);
         }
         for each(_loc6_ in param1.abilityLevels)
         {
            abilityLevels.push(_loc6_);
         }
         for each(_loc7_ in param1.titleRenownCosts)
         {
            titleRenownCosts.push(_loc7_);
         }
         rename = param1.rename;
         variation = param1.variation;
         allowRemoveStatPoints = BooleanVars.parse(param1.allow_remove_stat_points,allowRemoveStatPoints);
         roster_row_cost = param1.roster_row_cost;
         max_num_roster_rows = param1.max_num_roster_rows;
         roster_slots_per_row = param1.roster_slots_per_row;
      }
   }
}
