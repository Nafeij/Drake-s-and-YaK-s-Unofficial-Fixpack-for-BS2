package engine.battle.ability.effect.def
{
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import flash.utils.Dictionary;
   
   public class EffectDefPersistence
   {
       
      
      public var numUses:int;
      
      public var casterDuration:int;
      
      public var targetDuration:int;
      
      public var turnChangedDuration:int;
      
      public var durationOnTurnStart:Boolean = true;
      
      public var stack:EffectStackRule;
      
      public var linkedEffectName:String;
      
      public var expireOnDeath:Boolean;
      
      public var expireOnDeathCaster:Boolean;
      
      public var expireOnDeathTarget:Boolean;
      
      public var expireAbility:String;
      
      public var expireAbilityResponseCaster:BattleAbilityResponseTargetType;
      
      public var expireAbilityResponseTarget:BattleAbilityResponseTargetType;
      
      public var expireAbilityResponseCasterRequireAlive:Boolean = true;
      
      public var expireAbilityResponseTargetRequireAlive:Boolean = true;
      
      public var expireAbilityReasons:Dictionary;
      
      public var expireAbilityReasonsArray:Array;
      
      public function EffectDefPersistence()
      {
         this.expireAbilityResponseCaster = BattleAbilityResponseTargetType.CASTER;
         this.expireAbilityResponseTarget = BattleAbilityResponseTargetType.NONE;
         super();
      }
   }
}
