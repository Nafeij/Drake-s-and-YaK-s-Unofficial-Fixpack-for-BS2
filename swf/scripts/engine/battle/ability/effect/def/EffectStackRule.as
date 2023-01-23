package engine.battle.ability.effect.def
{
   import engine.core.util.Enum;
   
   public class EffectStackRule extends Enum
   {
      
      public static const STACK:EffectStackRule = new EffectStackRule("STACK",enumCtorKey);
      
      public static const IGNORE:EffectStackRule = new EffectStackRule("IGNORE",enumCtorKey);
      
      public static const REPLACE:EffectStackRule = new EffectStackRule("REPLACE",enumCtorKey);
      
      public static const REPLACE_LOWER:EffectStackRule = new EffectStackRule("REPLACE_LOWER",enumCtorKey);
      
      public static const REPLACE_LOWER_EQUAL:EffectStackRule = new EffectStackRule("REPLACE_LOWER_EQUAL",enumCtorKey);
       
      
      public function EffectStackRule(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
