package engine.battle.board.model
{
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import flash.events.IEventDispatcher;
   
   public interface IBattleBoardTriggers extends IEventDispatcher
   {
       
      
      function findClosestEntityHazard(param1:IBattleEntity, param2:TileRect, param3:Boolean, param4:Boolean) : IBattleBoardTrigger;
      
      function findEntityHazardAtRect(param1:IBattleEntity, param2:TileRect, param3:Boolean) : IBattleBoardTrigger;
      
      function addTrigger(param1:IBattleBoardTrigger) : void;
      
      function removeTrigger(param1:IBattleBoardTrigger) : void;
      
      function get board() : IBattleBoard;
      
      function checkTriggers(param1:IBattleEntity, param2:TileRect, param3:Boolean) : void;
      
      function checkPulsingTriggers(param1:IBattleEntity, param2:TileRect) : void;
      
      function checkTrigger(param1:IBattleBoardTrigger) : void;
      
      function clearEntitiesHitThisTurn() : void;
      
      function get triggers() : Vector.<IBattleBoardTrigger>;
      
      function hasTriggerOnTile(param1:Tile, param2:Boolean) : Boolean;
      
      function selectTriggersOnTile(param1:Tile) : void;
      
      function get triggeringEntity() : IBattleEntity;
      
      function get triggeringEntityId() : String;
      
      function get triggering() : IBattleBoardTrigger;
      
      function validate() : void;
      
      function checkTriggerVars() : void;
      
      function getTriggerByUniqueId(param1:String) : IBattleBoardTrigger;
      
      function getTriggerById(param1:String) : IBattleBoardTrigger;
      
      function getTriggerByUniqueIdOrId(param1:String) : IBattleBoardTrigger;
      
      function handleTriggerEnabled(param1:IBattleBoardTrigger) : void;
      
      function get numTriggers() : int;
      
      function updateTurnEntity(param1:IBattleEntity) : void;
   }
}
