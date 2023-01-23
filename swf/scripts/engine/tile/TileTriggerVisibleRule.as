package engine.tile
{
   import engine.core.util.Enum;
   
   public class TileTriggerVisibleRule extends Enum
   {
      
      public static const NONE:TileTriggerVisibleRule = new TileTriggerVisibleRule("NONE",enumCtorKey);
      
      public static const ANY:TileTriggerVisibleRule = new TileTriggerVisibleRule("ANY",enumCtorKey);
      
      public static const FRIENDLY:TileTriggerVisibleRule = new TileTriggerVisibleRule("FRIENDLY",enumCtorKey);
      
      public static const ENEMY:TileTriggerVisibleRule = new TileTriggerVisibleRule("ENEMY",enumCtorKey);
       
      
      public function TileTriggerVisibleRule(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
