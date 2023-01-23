package engine.stat.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   
   public class StatModDefVars extends StatModDef
   {
      
      public static const schema:Object = {
         "name":"StatModDefVars",
         "type":"object",
         "properties":{
            "stat":{"type":"string"},
            "amount":{"type":"number"}
         }
      };
       
      
      public function StatModDefVars()
      {
         super();
      }
      
      public static function save(param1:StatModDef) : Object
      {
         return {
            "stat":(!!param1.stat ? param1.stat.name : ""),
            "amount":param1.amount
         };
      }
      
      public function fromJson(param1:Object, param2:ILogger) : StatModDef
      {
         stat = Enum.parse(StatType,param1.stat) as StatType;
         amount = param1.amount;
         return this;
      }
   }
}
