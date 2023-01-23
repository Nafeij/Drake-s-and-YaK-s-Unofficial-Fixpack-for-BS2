package engine.battle.fsm
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.sim.IBattleParty;
   import flash.events.IEventDispatcher;
   
   public interface IBattleTurnOrder extends IEventDispatcher
   {
       
      
      function addEntity(param1:IBattleEntity) : void;
      
      function addParty(param1:IBattleParty) : void;
      
      function bumpToNext(param1:IBattleEntity) : void;
      
      function commencePillaging(param1:Boolean, param2:Boolean) : void;
      
      function getAliveParticipants(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>;
      
      function getAllParticipants(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>;
      
      function moveToLast(param1:IBattleEntity) : void;
      
      function pruneDeadEntities() : int;
      
      function resetTurnOrder() : void;
      
      function turnOrderNextTurn(param1:IBattleEntity) : IBattleEntity;
      
      function get numTeams() : int;
      
      function get pillage() : Boolean;
      
      function removeParty(param1:IBattleParty) : Boolean;
      
      function removeEntity(param1:IBattleEntity) : void;
      
      function get aliveOrder() : Vector.<IBattleEntity>;
      
      function get turnTeams() : Vector.<BattleTurnTeam>;
      
      function get freeTurn() : IBattleEntity;
      
      function set freeTurn(param1:IBattleEntity) : void;
      
      function get activeEntity() : IBattleEntity;
      
      function peekNextEnemy() : IBattleEntity;
      
      function get initialized() : Boolean;
   }
}
