package engine.battle.ability.effect.model
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbilityRetargetInfo;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import flash.events.IEventDispatcher;
   
   public interface IPersistedEffects extends IEffectTagProvider, IEventDispatcher
   {
       
      
      function get effects() : Vector.<IEffect>;
      
      function addCastedEffect(param1:IEffect) : AddEffectResponse;
      
      function addEffect(param1:IEffect) : AddEffectResponse;
      
      function findCastedChildEffects(param1:IBattleAbility, param2:IBattleEntity) : IEffect;
      
      function handleEndTurn() : void;
      
      function handleTransferDamage(param1:IEffect, param2:int) : void;
      
      function handleStartTurn() : void;
      
      function hasEffect(param1:IEffect) : Boolean;
      
      function hasCastedEffect(param1:IEffect) : Boolean;
      
      function onCasterEffectPhaseChange(param1:IEffect) : void;
      
      function onTargetEffectPhaseChange(param1:IEffect) : void;
      
      function onAbilityExecutingOnTarget(param1:IBattleAbility) : BattleAbilityRetargetInfo;
      
      function removeTag(param1:EffectTag) : void;
      
      function addTag(param1:EffectTag) : void;
      
      function clearTag(param1:EffectTag) : void;
      
      function handleTargetDeath() : void;
      
      function getBattleAbilitiesByDef(param1:IBattleAbilityDef) : Vector.<IBattleAbility>;
      
      function hasBattleAbilitiesByDef(param1:IBattleAbilityDef) : Boolean;
      
      function getDebugTagInfo() : String;
   }
}
