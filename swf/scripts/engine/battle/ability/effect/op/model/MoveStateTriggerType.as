package engine.battle.ability.effect.op.model
{
   import engine.core.util.Enum;
   
   public class MoveStateTriggerType extends Enum
   {
      
      public static const EXECUTING:MoveStateTriggerType = new MoveStateTriggerType("EXECUTING",enumCtorKey);
      
      public static const FINISHING:MoveStateTriggerType = new MoveStateTriggerType("FINISHING",enumCtorKey);
       
      
      public function MoveStateTriggerType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
