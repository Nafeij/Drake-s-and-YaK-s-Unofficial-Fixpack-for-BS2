package engine.saga.action
{
   import engine.battle.board.model.IBattleBoard;
   import engine.core.util.Enum;
   import engine.saga.Saga;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileWalkableType;
   
   public class Action_BattleWalkable extends Action
   {
       
      
      public function Action_BattleWalkable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:TileWalkableType = null;
         var _loc8_:TileLocation = null;
         var _loc9_:Tile = null;
         var _loc1_:String = def.anchor;
         var _loc2_:* = def.varvalue != 0;
         var _loc3_:* = def.varvalue < 0;
         if(Boolean(def.param) && !_loc3_)
         {
            _loc4_ = Enum.parse(TileWalkableType,def.param,false,logger) as TileWalkableType;
         }
         if(!_loc4_)
         {
            _loc4_ = _loc2_ ? TileWalkableType.WALKABLE : TileWalkableType.NOT_WALKABLE;
         }
         var _loc5_:Vector.<TileLocation> = Action_BattleUnitMove.parseTilesList(_loc1_,saga);
         if(!_loc5_.length)
         {
            throw new ArgumentError("no tiles in anchor [" + _loc1_ + "]");
         }
         var _loc6_:IBattleBoard = saga.getBattleBoard();
         var _loc7_:Tiles = _loc6_.tiles;
         for each(_loc8_ in _loc5_)
         {
            _loc9_ = _loc7_.getTile(_loc8_._x,_loc8_._y);
            if(!_loc9_)
            {
               logger.error("no such tile at " + _loc8_);
            }
            if(_loc3_)
            {
               _loc4_ = _loc4_ == TileWalkableType.NOT_WALKABLE ? TileWalkableType.WALKABLE : TileWalkableType.NOT_WALKABLE;
            }
            _loc9_.setWalkableType(_loc4_);
         }
         _loc6_.notifyWalkableChanged();
         end();
      }
   }
}
