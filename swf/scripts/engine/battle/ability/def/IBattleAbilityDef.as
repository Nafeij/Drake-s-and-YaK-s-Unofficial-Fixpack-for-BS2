package engine.battle.ability.def
{
   import engine.ability.IAbilityDef;
   import engine.battle.ability.effect.def.EffectTagReqs;
   import engine.battle.ability.effect.def.IEffectDef;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.stat.model.IStatsProvider;
   import engine.stat.model.Stats;
   
   public interface IBattleAbilityDef extends IAbilityDef
   {
       
      
      function getIBattleAbilityDefLevel(param1:int) : IBattleAbilityDef;
      
      function get effects() : Vector.<IEffectDef>;
      
      function get targetDelay() : int;
      
      function get targetCount() : int;
      
      function get minResultDistance() : int;
      
      function get maxResultDistance() : int;
      
      function get targetRule() : BattleAbilityTargetRule;
      
      function checkCasterExecutionConditions(param1:IBattleEntity, param2:ILogger, param3:Boolean) : Boolean;
      
      function rangeMin(param1:IStatsProvider) : int;
      
      function rangeMax(param1:IStatsProvider) : int;
      
      function get rotationRule() : BattleAbilityRotationRule;
      
      function get targetRotationRule() : BattleAbilityTargetRotationRule;
      
      function get conditions() : AbilityExecutionConditions;
      
      function get requiresGuaranteedHit() : Boolean;
      
      function get tag() : BattleAbilityTag;
      
      function getAiPositionalRule() : BattleAbilityAiPositionalRuleType;
      
      function getAiTargetRule() : BattleAbilityAiTargetRuleType;
      
      function getMaxMove() : int;
      
      function getCasterEffectTagReqs() : EffectTagReqs;
      
      function getTargetEffectTagReqs() : EffectTagReqs;
      
      function getRangeType() : BattleAbilityRangeType;
      
      function checkTargetExecutionConditions(param1:IBattleEntity, param2:ILogger, param3:Boolean) : Boolean;
      
      function checkTargetStatRanges(param1:Stats) : Boolean;
      
      function getAiRulesAbility() : IBattleAbilityDef;
      
      function getBattleAbilityDefLevel(param1:int) : IBattleAbilityDef;
      
      function getTileTargetUrl() : String;
   }
}
