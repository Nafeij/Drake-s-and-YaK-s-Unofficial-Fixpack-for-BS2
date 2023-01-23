package engine.battle
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.sim.TileDiamond;
   import engine.math.MathUtil;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.geom.Rectangle;
   
   public class BattleUtilFunctions
   {
       
      
      public function BattleUtilFunctions()
      {
         super();
      }
      
      public static function getTileAvailableBehindAtDist(param1:TileRect, param2:IBattleEntity, param3:int) : Tile
      {
         var _loc10_:IBattleBoard = null;
         var _loc11_:Tile = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:TileRect = param2.rect;
         var _loc8_:Rectangle = new Rectangle(param1.loc.x,param1.loc.y,param1.width,param1.length);
         var _loc9_:Rectangle = new Rectangle(_loc7_.loc.x,_loc7_.loc.y,_loc7_.width,_loc7_.length);
         _loc8_.right += 1000;
         if(_loc9_.intersects(_loc8_) == true)
         {
            _loc4_ = _loc9_.left + param3;
            _loc5_ = _loc9_.top;
            _loc6_ = true;
         }
         else
         {
            _loc8_ = new Rectangle(param1.loc.x,param1.loc.y,param1.width,param1.length);
            _loc8_.left -= 1000;
            if(_loc9_.intersects(_loc8_) == true)
            {
               _loc4_ = _loc9_.left - param3;
               _loc5_ = _loc9_.top;
               _loc6_ = true;
            }
            else
            {
               _loc8_ = new Rectangle(param1.loc.x,param1.loc.y,param1.width,param1.length);
               _loc8_.top -= 1000;
               if(_loc9_.intersects(_loc8_) == true)
               {
                  _loc4_ = _loc9_.left;
                  _loc5_ = _loc9_.top - param3;
                  _loc6_ = true;
               }
               else
               {
                  _loc8_ = new Rectangle(param1.loc.x,param1.loc.y,param1.width,param1.length);
                  _loc8_.bottom += 1000;
                  if(_loc9_.intersects(_loc8_) == true)
                  {
                     _loc4_ = _loc9_.left;
                     _loc5_ = _loc9_.top + param3;
                     _loc6_ = true;
                  }
               }
            }
         }
         if(_loc6_ == true)
         {
            _loc10_ = param2.board;
            _loc11_ = _loc10_.tiles.getTile(_loc4_,_loc5_);
            if(_loc11_ != null)
            {
               if(isTileAvailable(_loc11_,param2) == true)
               {
                  if(!param2.isLocalRect(2,2))
                  {
                     return _loc11_;
                  }
                  if(isTileAvailable(_loc10_.tiles.getTile(_loc4_ + 1,_loc5_),param2) == true && isTileAvailable(_loc10_.tiles.getTile(_loc4_,_loc5_ + 1),param2) == true && isTileAvailable(_loc10_.tiles.getTile(_loc4_ + 1,_loc5_ + 1),param2) == true)
                  {
                     return _loc11_;
                  }
               }
            }
         }
         return null;
      }
      
      public static function axialPathClearOfBlockers(param1:IBattleEntity, param2:TileRect, param3:int, param4:int) : Boolean
      {
         var _loc12_:Tile = null;
         var _loc5_:Tiles = param1.board.tiles;
         var _loc6_:int = param2.loc._x;
         var _loc7_:int = param2.loc._y;
         var _loc8_:* = _loc7_ == param4;
         var _loc9_:int = _loc8_ ? param3 - _loc6_ : param4 - _loc7_;
         var _loc10_:int = _loc9_ > 0 ? 1 : -1;
         var _loc11_:int = _loc10_;
         while(_loc9_ != 0)
         {
            _loc12_ = null;
            if(_loc8_)
            {
               _loc12_ = _loc5_.getTile(_loc6_ + _loc11_,_loc7_);
            }
            else
            {
               _loc12_ = _loc5_.getTile(_loc6_,_loc7_ + _loc11_);
            }
            if(_loc12_ == null)
            {
               return false;
            }
            if(param1.isLocalRect(2,2))
            {
               if(_loc5_.getTile(_loc12_.x + 1,_loc12_.y) == null || _loc5_.getTile(_loc12_.x,_loc12_.y + 1) == null || _loc5_.getTile(_loc12_.x + 1,_loc12_.y + 1) == null)
               {
                  return false;
               }
            }
            _loc11_ += _loc10_;
            _loc9_ -= _loc10_;
         }
         return true;
      }
      
      public static function isAxialEntity2Entity(param1:TileRect, param2:IBattleEntity) : Boolean
      {
         var _loc3_:TileRect = null;
         if(param1 != null && param2 != null)
         {
            _loc3_ = param2.rect;
            return isAxialRect2Rect(param1,_loc3_);
         }
         return false;
      }
      
      public static function isAxialEntity2Tile(param1:TileRect, param2:Tile) : Boolean
      {
         var _loc3_:TileRect = null;
         if(param1 != null && param2 != null)
         {
            _loc3_ = param2.rect;
            return isAxialRect2Rect(param1,_loc3_);
         }
         return false;
      }
      
      public static function isAxialRect2Rect(param1:TileRect, param2:TileRect) : Boolean
      {
         if(param1 == param2)
         {
            return false;
         }
         var _loc3_:int = param1.loc.x;
         var _loc4_:int = _loc3_ + param1.diameter;
         var _loc5_:int = param1.loc.y;
         var _loc6_:int = _loc5_ + param1.diameter;
         var _loc7_:int = param2.left;
         var _loc8_:int = param2.right;
         var _loc9_:int = param2.front;
         var _loc10_:int = param2.back;
         if(_loc3_ < _loc8_ && _loc4_ > _loc7_)
         {
            return true;
         }
         if(_loc5_ < _loc10_ && _loc6_ > _loc9_)
         {
            return true;
         }
         return false;
      }
      
      private static function isTileAvailable(param1:Tile, param2:IBattleEntity = null) : Boolean
      {
         var _loc3_:ITileResident = null;
         var _loc4_:IBattleEntity = null;
         if(param1 != null)
         {
            for each(_loc3_ in param1.residents)
            {
               if(_loc3_ is IBattleEntity)
               {
                  if(param2 == null || param2 != _loc3_)
                  {
                     _loc4_ = _loc3_ as IBattleEntity;
                     if(_loc4_.alive == true)
                     {
                        return false;
                     }
                  }
               }
            }
            return true;
         }
         return false;
      }
      
      public static function getTileAvailableBehind(param1:TileRect, param2:IBattleEntity) : Tile
      {
         var _loc10_:IBattleBoard = null;
         var _loc11_:Tiles = null;
         var _loc12_:Tile = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:TileRect = param1;
         var _loc7_:TileRect = param2.rect;
         var _loc8_:Rectangle = new Rectangle(_loc6_.loc.x,_loc6_.loc.y,_loc6_.width,_loc6_.length);
         var _loc9_:Rectangle = new Rectangle(_loc7_.loc.x,_loc7_.loc.y,_loc7_.width,_loc7_.length);
         _loc8_.right += 1000;
         if(_loc9_.intersects(_loc8_) == true)
         {
            _loc3_ = _loc9_.left + param2.boardWidth;
            _loc4_ = _loc8_.top;
            _loc5_ = true;
         }
         else
         {
            _loc8_ = new Rectangle(_loc6_.loc.x,_loc6_.loc.y,_loc6_.width,_loc6_.length);
            _loc8_.left -= 1000;
            if(_loc9_.intersects(_loc8_) == true)
            {
               _loc3_ = _loc9_.left - _loc6_.width;
               _loc4_ = _loc8_.top;
               _loc5_ = true;
            }
            else
            {
               _loc8_ = new Rectangle(_loc6_.loc.x,_loc6_.loc.y,_loc6_.width,_loc6_.length);
               _loc8_.top -= 1000;
               if(_loc9_.intersects(_loc8_) == true)
               {
                  _loc3_ = _loc8_.left;
                  _loc4_ = _loc9_.top - _loc6_.width;
                  _loc5_ = true;
               }
               else
               {
                  _loc8_ = new Rectangle(_loc6_.loc.x,_loc6_.loc.y,_loc6_.width,_loc6_.length);
                  _loc8_.bottom += 1000;
                  if(_loc9_.intersects(_loc8_) == true)
                  {
                     _loc3_ = _loc8_.left;
                     _loc4_ = _loc9_.top + param2.boardWidth;
                     _loc5_ = true;
                  }
               }
            }
         }
         if(_loc5_ == true)
         {
            _loc10_ = param2.board;
            _loc11_ = _loc10_.tiles;
            _loc12_ = _loc11_.getTile(_loc3_,_loc4_);
            if(_loc12_ != null)
            {
               if(isTileAvailable(_loc12_) == true)
               {
                  if(_loc6_.width != 2)
                  {
                     return _loc12_;
                  }
                  if(isTileAvailable(_loc11_.getTile(_loc3_ + 1,_loc4_)) == true && isTileAvailable(_loc11_.getTile(_loc3_,_loc4_ + 1)) == true && isTileAvailable(_loc11_.getTile(_loc3_ + 1,_loc4_ + 1)) == true)
                  {
                     return _loc12_;
                  }
               }
            }
         }
         return null;
      }
      
      public static function selectRandomTiles(param1:IBattleBoard, param2:TileRect, param3:BattleAbilityDef, param4:Vector.<TileLocation>, param5:int) : void
      {
         var _loc8_:TileLocation = null;
         var _loc9_:Tile = null;
         var _loc10_:int = 0;
         var _loc11_:uint = 0;
         var _loc6_:TileDiamond = new TileDiamond(param1.tiles,param2,param3.minResultDistance,param3.maxResultDistance,null,0);
         var _loc7_:Vector.<TileLocation> = new Vector.<TileLocation>();
         for each(_loc8_ in _loc6_.hugs)
         {
            if(param3.targetRule == BattleAbilityTargetRule.TILE_EMPTY_RANDOM)
            {
               _loc9_ = param1.tiles.getTileByLocation(_loc8_);
               if(_loc9_.findResident(null))
               {
                  continue;
               }
               if(param1.triggers.hasTriggerOnTile(_loc9_,true))
               {
                  continue;
               }
            }
            _loc7_.push(_loc8_);
         }
         if(_loc7_.length > param5)
         {
            _loc10_ = 0;
            while(_loc10_ < param5)
            {
               _loc11_ = MathUtil.randomInt(0,_loc7_.length - 1);
               _loc8_ = _loc7_[_loc11_];
               param4.push(_loc8_);
               _loc7_.splice(_loc11_,1);
               _loc10_++;
            }
         }
         else
         {
            for each(_loc8_ in _loc7_)
            {
               param4.push(_loc8_);
            }
         }
      }
   }
}
