package engine.battle.ability.effect.model
{
   import engine.core.util.Enum;
   
   public class EffectResult extends Enum
   {
      
      public static const OK:EffectResult = new EffectResult("OK",enumCtorKey);
      
      public static const FAIL:EffectResult = new EffectResult("FAIL",enumCtorKey);
      
      public static const MISS:EffectResult = new EffectResult("MISS",enumCtorKey);
       
      
      public function EffectResult(param1:String, param2:Object)
      {
         super(param1,param2);
      }
      
      public function combineUp(param1:EffectResult) : EffectResult
      {
         if(this == OK || param1 == OK)
         {
            return OK;
         }
         return this;
      }
   }
}
