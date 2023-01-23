package engine.battle.ability.effect.model
{
   import engine.core.util.Enum;
   
   public class EffectRemoveReason extends Enum
   {
      
      public static const DEFAULT:EffectRemoveReason = new EffectRemoveReason("DEFAULT",enumCtorKey);
      
      public static const CASTER_DEATH:EffectRemoveReason = new EffectRemoveReason("CASTER_DEATH",enumCtorKey);
      
      public static const TARGET_DEATH:EffectRemoveReason = new EffectRemoveReason("TARGET_DEATH",enumCtorKey);
      
      public static const USE_COUNT:EffectRemoveReason = new EffectRemoveReason("USE_COUNT",enumCtorKey);
      
      public static const CASTER_DURATION:EffectRemoveReason = new EffectRemoveReason("CASTER_DURATION",enumCtorKey);
      
      public static const TARGET_DURATION:EffectRemoveReason = new EffectRemoveReason("TARGET_DURATION",enumCtorKey);
      
      public static const CLEANUP:EffectRemoveReason = new EffectRemoveReason("CLEANUP",enumCtorKey);
      
      public static const LINKED_EFFECT:EffectRemoveReason = new EffectRemoveReason("LINKED_EFFECT",enumCtorKey);
      
      public static const FORCED_EXPIRATION:EffectRemoveReason = new EffectRemoveReason("FORCED_EXPIRATION",enumCtorKey);
      
      public static const ANY:EffectRemoveReason = new EffectRemoveReason("ANY",enumCtorKey);
      
      public static const TURN_CHANGED_DURATION:EffectRemoveReason = new EffectRemoveReason("TURN_CHANGED_DURATION",enumCtorKey);
       
      
      public function EffectRemoveReason(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
