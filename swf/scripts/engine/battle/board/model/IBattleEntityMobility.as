package engine.battle.board.model
{
   import engine.core.IUpdateable;
   import engine.tile.Tile;
   import flash.events.IEventDispatcher;
   
   public interface IBattleEntityMobility extends IEventDispatcher, IUpdateable
   {
       
      
      function get entity() : IBattleEntity;
      
      function executeMove(param1:IBattleMove) : void;
      
      function stopMoving(param1:String) : void;
      
      function get moving() : Boolean;
      
      function set moving(param1:Boolean) : void;
      
      function get moved() : Boolean;
      
      function set moved(param1:Boolean) : void;
      
      function get numStepsMoved() : int;
      
      function fastForwardMove() : void;
      
      function handleTrimmedImpossibles() : void;
      
      function get forcedMove() : Boolean;
      
      function get interrupted() : Boolean;
      
      function get previousTileInMove() : Tile;
   }
}
