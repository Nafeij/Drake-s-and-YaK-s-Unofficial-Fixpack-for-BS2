package engine.battle.board.model
{
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.board.def.ITileTriggerDef;
   import engine.core.logging.ILogger;
   import engine.path.IPathGraph;
   import engine.tile.Tile;
   import engine.tile.TileTrigger;
   import engine.tile.Tiles;
   import engine.tile.def.TileDef;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileWalkableType;
   
   public class BattleBoardTiles extends Tiles
   {
       
      
      public var board:IBattleBoard;
      
      public var logger:ILogger;
      
      public function BattleBoardTiles(param1:IBattleBoard)
      {
         this.board = param1;
         this.logger = param1.logger;
         super(param1.def.walkableTiles,param1.def.unwalkableTiles);
      }
      
      public function cleanup() : void
      {
         super.cleanupTiles();
         this.board = null;
         this.logger = null;
      }
      
      override protected function createTile(param1:int, param2:int, param3:TileWalkableType) : Tile
      {
         return new BattleTile(new TileDef(param1,param2,param3),this);
      }
      
      override protected function createPathGraph() : IPathGraph
      {
         return new BattleBoardPathGraph(this,this.board.logger);
      }
      
      override public function addTrigger(param1:String, param2:ITileTriggerDef, param3:TileRect, param4:Boolean, param5:IEffect, param6:Boolean) : TileTrigger
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("BattleBoardTiles.addTrigger for effect " + param5 + " rect=" + param3);
         }
         var _loc7_:BattleBoard = this.board as BattleBoard;
         var _loc8_:IBattleBoardTriggers = this.board.triggers;
         var _loc9_:BattleBoardTrigger = new BattleBoardTrigger(_loc8_,this,param1,_loc7_,param2,param3,param4,param5,param6);
         _loc8_.addTrigger(_loc9_);
         return _loc9_;
      }
      
      override public function removeTrigger(param1:TileTrigger) : void
      {
         this.board.triggers.removeTrigger(param1 as BattleBoardTrigger);
      }
   }
}
