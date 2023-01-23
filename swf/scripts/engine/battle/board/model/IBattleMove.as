package engine.battle.board.model
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.path.PathFloodSolver;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import flash.events.IEventDispatcher;
   
   public interface IBattleMove extends IEventDispatcher
   {
       
      
      function get numSteps() : int;
      
      function getStep(param1:int) : Tile;
      
      function get first() : Tile;
      
      function get last() : Tile;
      
      function hasStep(param1:Tile) : Boolean;
      
      function get executed() : Boolean;
      
      function setExecuted() : void;
      
      function get executing() : Boolean;
      
      function setExecuting() : void;
      
      function get committed() : Boolean;
      
      function setCommitted(param1:String) : void;
      
      function get interrupted() : Boolean;
      
      function setInterrupted() : void;
      
      function get forcedMove() : Boolean;
      
      function set forcedMove(param1:Boolean) : void;
      
      function get changeFacing() : Boolean;
      
      function set changeFacing(param1:Boolean) : void;
      
      function get reactToEntityIntersect() : Boolean;
      
      function set reactToEntityIntersect(param1:Boolean) : void;
      
      function handleIntersectEntity(param1:IBattleEntity) : void;
      
      function trimImpossibleEndpoints() : void;
      
      function get trimmedImpossibleEndpoints() : Vector.<Tile>;
      
      function get trimmedImpossibleResidents() : Vector.<IBattleEntity>;
      
      function getMovementStat() : int;
      
      function get lastTileRect() : TileRect;
      
      function reset(param1:Tile) : void;
      
      function cleanup() : void;
      
      function listenForWillpower() : void;
      
      function setWayPoint(param1:Tile) : void;
      
      function trimStepsToWaypoint(param1:Boolean) : Boolean;
      
      function trimStepsTo(param1:int) : void;
      
      function uncommitMove() : void;
      
      function get entity() : IBattleEntity;
      
      function get flood() : PathFloodSolver;
      
      function set flood(param1:PathFloodSolver) : void;
      
      function get lastFacing() : BattleFacing;
      
      function getStepFacing(param1:int) : BattleFacing;
      
      function addStep(param1:Tile) : void;
      
      function get cleanedup() : Boolean;
      
      function get wayPointTile() : Tile;
      
      function get pathEndBlocked() : Boolean;
      
      function copy(param1:IBattleMove) : void;
      
      function process(param1:Tile, param2:Boolean) : Boolean;
      
      function get wayPointFacing() : BattleFacing;
      
      function get wayPointSteps() : int;
      
      function updateFloods() : void;
      
      function get suppressCommit() : Boolean;
      
      function set suppressCommit(param1:Boolean) : void;
      
      function get waypointBlocked() : Boolean;
      
      function clone() : IBattleMove;
      
      function pathTowardRect(param1:TileRect, param2:Boolean, param3:int, param4:Boolean) : Boolean;
      
      function notifyPlanChanged() : void;
   }
}
