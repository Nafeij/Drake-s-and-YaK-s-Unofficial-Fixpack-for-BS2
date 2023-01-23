package engine.stat.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   
   public class StatRangeVars
   {
      
      public static const schema:Object = {
         "name":"StatRangeVars",
         "type":"object",
         "properties":{
            "stat":{"type":"string"},
            "min":{"type":"number"},
            "max":{"type":"number"}
         }
      };
       
      
      public function StatRangeVars()
      {
         super();
      }
      
      public static function parseInto(param1:StatRanges, param2:Object, param3:ILogger) : StatRange
      {
         if(param2.stat == "RANGE" || param2.stat == "ABILITY_0")
         {
            return null;
         }
         var _loc4_:StatType = Enum.parse(StatType,param2.stat) as StatType;
         var _loc5_:int = int(param2.min);
         var _loc6_:int = int(param2.max);
         return param1.addStatRange(_loc4_,_loc5_,_loc6_);
      }
      
      public static function save(param1:StatRange) : Object
      {
         return {
            "stat":param1.type.name,
            "min":param1.min,
            "max":param1.max
         };
      }
   }
}
