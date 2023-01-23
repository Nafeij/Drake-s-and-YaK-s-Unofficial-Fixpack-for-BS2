package engine.tile
{
   import engine.core.util.Enum;
   
   public class TileTriggerType extends Enum
   {
      
      public static const NO_TYPE:TileTriggerType = new TileTriggerType("NO_TYPE",enumCtorKey);
      
      public static const SLAGANDBURN_COALS:TileTriggerType = new TileTriggerType("SLAGANDBURN_COALS",enumCtorKey);
       
      
      public function TileTriggerType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
