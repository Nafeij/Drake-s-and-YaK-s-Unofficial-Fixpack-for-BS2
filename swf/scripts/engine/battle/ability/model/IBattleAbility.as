package engine.battle.ability.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.def.IEffectDef;
   import engine.battle.ability.effect.model.EffectRemoveReason;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.IEffectTagProvider;
   import engine.battle.board.model.IBattleEntity;
   import flash.events.IEventDispatcher;
   
   public interface IBattleAbility extends IEventDispatcher, IEffectTagProvider
   {
       
      
      function get targetSet() : BattleTargetSet;
      
      function get def() : BattleAbilityDef;
      
      function get caster() : IBattleEntity;
      
      function get executed() : Boolean;
      
      function get executing() : Boolean;
      
      function get completed() : Boolean;
      
      function get finalCompleted() : Boolean;
      
      function execute(param1:Function) : void;
      
      function addChildAbility(param1:IBattleAbility) : void;
      
      function addChildAbilityCallback(param1:IBattleAbility, param2:Function) : void;
      
      function get parent() : IBattleAbility;
      
      function set parent(param1:IBattleAbility) : void;
      
      function get root() : IBattleAbility;
      
      function checkCompletion() : void;
      
      function onEffectPhaseChange(param1:IEffect) : void;
      
      function getEffectByDef(param1:IEffectDef) : IEffect;
      
      function getEffectByName(param1:String) : IEffect;
      
      function get manager() : IBattleAbilityManager;
      
      function get fake() : Boolean;
      
      function get executedId() : int;
      
      function removeAllEffects(param1:EffectRemoveReason) : void;
      
      function onEffectUnblocked(param1:IEffect) : void;
      
      function get getId() : int;
      
      function cleanup() : void;
   }
}
