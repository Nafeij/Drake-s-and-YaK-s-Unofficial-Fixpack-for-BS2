package engine.battle.board.controller
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleTurn;
   import engine.math.MathUtil;
   import engine.path.PathFloodSolver;
   import engine.scene.SceneControllerConfig;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import engine.tile.def.TileRect;
   import flash.geom.Point;
   
   public class BattleBoardTileTargetHelper
   {
       
      
      public function BattleBoardTileTargetHelper()
      {
         super();
      }
      
      private static function _findMoveTile_Validator(param1:IBattleEntity, param2:BattleMove, param3:TileRect, param4:Tile) : Boolean
      {
         var _loc5_:PathFloodSolver = param2.flood;
         if(param4 == param2.wayPointTile || _loc5_.hasResultKey(param4))
         {
            return true;
         }
         return false;
      }
      
      private static function _findMoveTile_ValidatorDeploy(param1:IBattleEntity, param2:TileLocationArea, param3:TileRect, param4:Tile) : Boolean
      {
         if(!param3)
         {
            if(param2.hasTile(param4.location))
            {
               if(param1.tile == param4 || param4.numResidents == 0)
               {
                  return true;
               }
            }
            return false;
         }
         if(param2.hasTiles(param3))
         {
            if(param1.board.findAllRectIntersectionEntities(param3,param1,null))
            {
               return false;
            }
            return true;
         }
         return false;
      }
      
      private static function _findMoveTile(param1:IBattleEntity, param2:Point, param3:Function, param4:*) : Tile
      {
         var _loc13_:Tile = null;
         var _loc17_:int = 0;
         var _loc18_:TileLocation = null;
         var _loc19_:Tile = null;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:Number = NaN;
         var _loc5_:Number = Number(param1.diameter);
         var _loc6_:BattleBoard = param1.board as BattleBoard;
         if(_loc5_ == 1 || !param2)
         {
            if(param3(param1,param4,null,_loc6_.selectedTile))
            {
               return _loc6_.selectedTile;
            }
            return null;
         }
         var _loc7_:Tile = param1.tile;
         var _loc8_:Tile = _loc6_._selectedTile;
         var _loc9_:Number = _loc5_ / 2;
         var _loc10_:int = -(_loc5_ - 1);
         var _loc11_:TileLocation = _loc8_.location;
         var _loc12_:TileRect = new TileRect(_loc11_,_loc5_,_loc5_);
         var _loc14_:Number = 100000000;
         var _loc15_:Boolean = Boolean(param1.tile) && Boolean(param1.tile.getWalkableFor(param1));
         var _loc16_:int = _loc10_;
         while(_loc16_ <= 0)
         {
            _loc17_ = _loc10_;
            while(_loc17_ <= 0)
            {
               _loc18_ = TileLocation.fetch(_loc11_.x + _loc16_,_loc11_.y + _loc17_);
               _loc19_ = _loc6_.tiles.getTileByLocation(_loc18_);
               if(_loc19_)
               {
                  _loc12_.setLocation(_loc18_);
                  if(param3(param1,param4,_loc12_,_loc19_))
                  {
                     if(_loc19_ != _loc7_)
                     {
                        if(_loc6_.testRectTiles(_loc12_,_loc15_))
                        {
                           _loc20_ = _loc18_.x + _loc9_;
                           _loc21_ = _loc18_.y + _loc9_;
                           _loc22_ = MathUtil.distanceSquared(_loc20_,_loc21_,param2.x,param2.y);
                           if(_loc22_ < _loc14_)
                           {
                              _loc14_ = _loc22_;
                              _loc13_ = _loc19_;
                           }
                        }
                     }
                  }
               }
               _loc17_++;
            }
            _loc16_++;
         }
         return _loc13_;
      }
      
      internal static function _findMoveTileWaypoint(param1:BattleFsm, param2:BattleTurn, param3:Point) : Boolean
      {
         if(!param1 || !param2)
         {
            return false;
         }
         var _loc4_:BattleBoard = param1.board as BattleBoard;
         var _loc5_:Tile = _loc4_._selectedTile;
         if(!_loc5_)
         {
            param2.move.trimStepsToWaypoint(true);
            return false;
         }
         var _loc6_:IBattleEntity = param2.entity;
         var _loc7_:IBattleMove = param2.move;
         var _loc8_:PathFloodSolver = _loc7_.flood;
         if(!_loc8_)
         {
            return false;
         }
         var _loc9_:SceneControllerConfig = SceneControllerConfig.instance;
         if(_loc9_.restrictInput)
         {
            if(_loc7_.wayPointTile == _loc9_.allowMoveTile && !_loc9_.allowWaypointTile)
            {
               return false;
            }
         }
         var _loc10_:Number = Number(_loc6_.diameter);
         var _loc11_:TileLocation = _loc5_.location;
         var _loc12_:Tile = _loc6_.tile;
         var _loc13_:Tile = _findMoveTile(_loc6_,param3,_findMoveTile_Validator,_loc7_);
         if(_loc13_)
         {
            if(_loc13_ == _loc12_)
            {
               _loc7_.trimStepsToWaypoint(true);
               return false;
            }
            if(_loc7_.last != _loc13_)
            {
               _loc7_.process(_loc13_,false);
            }
            return true;
         }
         param2.move.trimStepsToWaypoint(true);
         return false;
      }
      
      internal static function _findMoveTileDeploy(param1:IBattleEntity, param2:TileLocationArea, param3:Point) : Tile
      {
         if(!param1)
         {
            return null;
         }
         var _loc4_:BattleBoard = param1.board as BattleBoard;
         var _loc5_:Tile = _loc4_._selectedTile;
         if(!_loc5_)
         {
            return null;
         }
         var _loc6_:Number = Number(param1.diameter);
         var _loc7_:TileLocation = _loc5_.location;
         var _loc8_:Tile = param1.tile;
         return _findMoveTile(param1,param3,_findMoveTile_ValidatorDeploy,param2);
      }
      
      private static function _tileMatches(param1:Tile, param2:int, param3:Tile) : Boolean
      {
         if(!param3)
         {
            return false;
         }
         if(param1.x < param3.x || param1.y < param3.y)
         {
            return false;
         }
         if(param1.x >= param3.x + param2 || param1.y >= param3.y + param2)
         {
            return false;
         }
         return true;
      }
   }
}
