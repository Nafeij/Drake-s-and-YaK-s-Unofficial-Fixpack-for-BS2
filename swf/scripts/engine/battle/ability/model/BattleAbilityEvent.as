package engine.battle.ability.model
{
   import engine.battle.ability.effect.model.IEffect;
   import flash.events.Event;
   
   public class BattleAbilityEvent extends Event
   {
      
      public static const ABILITY_PRE_COMPLETE:String = "BattleAbilityEvent.ABILITY_PRE_COMPLETE";
      
      public static const ABILITY_POST_COMPLETE:String = "BattleAbilityEvent.ABILITY_POST_COMPLETE";
      
      public static const ABILITY_AND_CHILDREN_COMPLETE:String = "BattleAbilityEvent.ABILITY_AND_CHILDREN_COMPLETE";
      
      public static const FINAL_COMPLETE:String = "BattleAbilityEvent.FINAL_COMPLETE";
      
      public static const FINAL_COMPLETE_MANAGED:String = "BattleAbilityEvent.FINAL_COMPLETE_MANAGED";
      
      public static const EXECUTING:String = "BattleAbilityEvent.EXECUTING";
      
      public static const INCOMPLETES_EMPTY:String = "BattleAbilityEvent.INCOMPLETES_EMPTY";
      
      public static const PERSISTED_ADDED:String = "BattleAbilityEvent.PERSISTED_ADDED";
      
      public static const PERSISTED_REMOVED:String = "BattleAbilityEvent.PERSISTED_ADDED";
      
      public static const PERSISTED_USED:String = "BattleAbilityEvent.PERSISTED_USED";
       
      
      public var ability:IBattleAbility;
      
      public var effect:IEffect;
      
      public function BattleAbilityEvent(param1:String, param2:IBattleAbility, param3:IEffect)
      {
         super(param1,false,false);
         this.ability = param2;
         this.effect = param3;
      }
   }
}
