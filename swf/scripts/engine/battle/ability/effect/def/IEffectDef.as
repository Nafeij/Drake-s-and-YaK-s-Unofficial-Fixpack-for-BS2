package engine.battle.ability.effect.def
{
   import engine.battle.ability.def.AbilityExecutionConditions;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.ability.phantasm.def.ChainPhantasmsDef;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import flash.utils.Dictionary;
   
   public interface IEffectDef
   {
       
      
      function hasTag(param1:EffectTag) : Boolean;
      
      function getChainPhantasmsForResult(param1:EffectResult) : ChainPhantasmsDef;
      
      function get phantasms() : Vector.<ChainPhantasmsDef>;
      
      function get conditions() : Vector.<EffectDefConditions>;
      
      function get executionConditions() : AbilityExecutionConditions;
      
      function checkEffectConditionsAbility(param1:IBattleAbility, param2:IBattleEntity, param3:Boolean, param4:AbilityReason) : Boolean;
      
      function checkEffectConditionsAbilityDef(param1:IBattleAbilityDef, param2:IBattleEntity, param3:IBattleEntity, param4:Boolean, param5:AbilityReason) : Boolean;
      
      function checkEffectConditions(param1:IBattleAbility, param2:IBattleAbilityDef, param3:IBattleEntity, param4:IBattleEntity, param5:Boolean, param6:AbilityReason) : Boolean;
      
      function get persistent() : EffectDefPersistence;
      
      function get ops() : Vector.<EffectDefOp>;
      
      function get name() : String;
      
      function get tags() : Dictionary;
      
      function get targetCasterFirst() : Boolean;
      
      function get targetCasterLast() : Boolean;
      
      function get logger() : ILogger;
      
      function get noValidateAbility() : Boolean;
   }
}
