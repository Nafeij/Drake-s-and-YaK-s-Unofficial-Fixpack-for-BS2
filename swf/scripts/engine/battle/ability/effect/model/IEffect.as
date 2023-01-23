package engine.battle.ability.effect.model
{
   import engine.battle.ability.effect.def.IEffectDef;
   import engine.battle.ability.effect.op.model.IOp;
   import engine.battle.ability.model.BattleAbilityRetargetInfo;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.expression.ISymbols;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   public interface IEffect extends IEventDispatcher, IEffectTagProvider
   {
       
      
      function casterStartTurn() : Boolean;
      
      function targetStartTurn() : Boolean;
      
      function turnChanged() : Boolean;
      
      function onAbilityExecutingOnTarget(param1:IBattleAbility) : BattleAbilityRetargetInfo;
      
      function get ability() : IBattleAbility;
      
      function get phase() : EffectPhase;
      
      function get tags() : Dictionary;
      
      function cleanup() : void;
      
      function get target() : IBattleEntity;
      
      function remove() : void;
      
      function handleTransferDamage(param1:IEffect, param2:int) : void;
      
      function handleOpUsed(param1:IOp) : void;
      
      function forceExpiration() : void;
      
      function get result() : EffectResult;
      
      function get def() : IEffectDef;
      
      function get symbols() : ISymbols;
   }
}
