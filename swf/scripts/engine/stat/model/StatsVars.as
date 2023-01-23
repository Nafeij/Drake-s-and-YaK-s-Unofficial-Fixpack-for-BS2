package engine.stat.model
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   import engine.stat.def.StatType;
   
   public class StatsVars
   {
      
      public static const schema:Object = {
         "name":"StatVars",
         "properties":{"stats":{
            "type":"array",
            "items":{
               "type":"object",
               "properties":{
                  "stat":"string",
                  "value":"number"
               }
            }
         }}
      };
       
      
      public function StatsVars()
      {
         super();
      }
      
      public static function parse(param1:IStatsProvider, param2:Object, param3:ILogger) : Stats
      {
         var _loc5_:Object = null;
         var _loc6_:StatType = null;
         EngineJsonDef.validateThrow(param2,schema,param3);
         var _loc4_:Stats = new Stats(param1,true);
         for each(_loc5_ in param2.stats)
         {
            if(!(_loc5_.stat == "ABILITY_0" || _loc5_.stat == "RANGE"))
            {
               _loc6_ = Enum.parse(StatType,_loc5_.stat) as StatType;
               _loc4_.addStat(_loc6_,_loc5_.value);
            }
         }
         return _loc4_;
      }
      
      public static function save(param1:Stats) : Object
      {
         var _loc4_:Stat = null;
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(_loc3_ < param1.numStats)
         {
            _loc4_ = param1.getStatByIndex(_loc3_);
            if(!(_loc4_.type == StatType.KILLS && _loc4_.value == 0))
            {
               _loc2_.push({
                  "stat":_loc4_.type.name,
                  "value":_loc4_.value
               });
            }
            _loc3_++;
         }
         return _loc2_;
      }
   }
}
