package engine.battle.ability.model
{
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.effect.model.IEffect;
   import engine.core.logging.ILogger;
   import engine.expression.ISymbols;
   import engine.math.Rng;
   import flash.events.IEventDispatcher;
   
   public interface IBattleAbilityManager extends IEventDispatcher
   {
       
      
      function get symbols() : ISymbols;
      
      function notifyPersistedAbilityEffectAdded(param1:IBattleAbility, param2:IEffect) : void;
      
      function notifyPersistedAbilityEffectRemoved(param1:IBattleAbility, param2:IEffect) : void;
      
      function onAbilityExecuting(param1:IBattleAbility) : void;
      
      function onAbilityPreComplete(param1:IBattleAbility) : void;
      
      function onAbilityPostComplete(param1:IBattleAbility) : void;
      
      function onAbilityFinalComplete(param1:IBattleAbility) : void;
      
      function onAbilityAndChildrenComplete(param1:IBattleAbility) : void;
      
      function get lastId() : int;
      
      function get lastExecutedId() : int;
      
      function get numIncompleteAbilities() : int;
      
      function get lastIncompleteTicker() : int;
      
      function get rng() : Rng;
      
      function get isFaking() : Boolean;
      
      function get getLogger() : ILogger;
      
      function get getFactory() : IBattleAbilityDefFactory;
      
      function setFaking(param1:Boolean) : void;
      
      function handleStartTurn() : void;
      
      function forceCompleteAbilities() : void;
      
      function get nextExecutedId() : int;
      
      function get debugIncompletes() : String;
   }
}
