package engine.battle.fsm
{
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import flash.utils.Dictionary;
   
   public interface IBattleTurn
   {
       
      
      function get number() : int;
      
      function get entity() : IBattleEntity;
      
      function get move() : IBattleMove;
      
      function get ability() : BattleAbility;
      
      function set ability(param1:BattleAbility) : void;
      
      function get attackMode() : Boolean;
      
      function set attackMode(param1:Boolean) : void;
      
      function get committed() : Boolean;
      
      function set committed(param1:Boolean) : void;
      
      function notifyTargetsUpdated() : void;
      
      function get inRange() : Dictionary;
      
      function get inRangeTiles() : Dictionary;
      
      function get suspended() : Boolean;
      
      function set suspended(param1:Boolean) : void;
      
      function get timerSecs() : int;
      
      function get complete() : Boolean;
      
      function get numAbilities() : int;
      
      function get turnInteract() : IBattleEntity;
   }
}
