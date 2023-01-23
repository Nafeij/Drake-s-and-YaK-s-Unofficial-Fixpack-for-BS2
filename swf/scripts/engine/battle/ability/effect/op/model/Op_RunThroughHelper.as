package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class Op_RunThroughHelper
   {
       
      
      public function Op_RunThroughHelper()
      {
         super();
      }
      
      private static function _computeMovingRect(param1:TileRect, param2:TileRect) : TileRect
      {
         var _loc4_:TileRect = null;
         var _loc3_:BattleFacing = BattleFacing.findAxialFacingBetweenRects(param1,param2);
         if(!_loc3_)
         {
            return null;
         }
         if(_loc3_ == param1._facing.flip)
         {
            _loc4_ = param1.flip(null);
         }
         else
         {
            _loc4_ = param1.clone();
            _loc4_.facing = _loc3_;
         }
         return _loc4_;
      }
      
      private static function _computeLandingLocation(param1:IBattleBoard, param2:TileRect, param3:TileRect, param4:Boolean) : Tile
      {
         var _loc5_:Tiles = param1.tiles;
         var _loc6_:int = param2.loc.x;
         var _loc7_:int = param2.loc.y;
         var _loc8_:BattleFacing = param2.facing as BattleFacing;
         if(param4)
         {
            switch(_loc8_)
            {
               case BattleFacing.NE:
                  _loc7_ = param3.front - param2.length;
                  break;
               case BattleFacing.SE:
                  _loc6_ = param3.right + param2.tail;
                  break;
               case BattleFacing.NW:
                  _loc6_ = param3.left - param2.width;
                  break;
               case BattleFacing.SW:
                  _loc7_ = param3.back + param2.tail;
            }
         }
         else
         {
            switch(_loc8_)
            {
               case BattleFacing.NE:
                  _loc7_ = param3.back;
                  break;
               case BattleFacing.SE:
                  _loc6_ = param3.left - param2.diameter;
                  break;
               case BattleFacing.NW:
                  _loc6_ = param3.right;
                  break;
               case BattleFacing.SW:
                  _loc7_ = param3.front - param2.diameter;
            }
         }
         var _loc9_:TileLocation = TileLocation.fetch(_loc6_,_loc7_);
         var _loc10_:Tile = param1.tiles.getTile(_loc6_,_loc7_);
         if(Boolean(_loc10_) && !_loc10_.getWalkableFor(null))
         {
            _loc10_ = null;
         }
         return _loc10_;
      }
      
      public static function findLandingTileBefore(param1:IBattleEntity, param2:TileRect, param3:TileRect, param4:Boolean) : Tile
      {
         return findLandingTile(param1,param2,param3,param4,false);
      }
      
      public static function findLandingTileBehind(param1:IBattleEntity, param2:TileRect, param3:TileRect, param4:Boolean) : Tile
      {
         return findLandingTile(param1,param2,param3,param4,true);
      }
      
      public static function findLandingTile(param1:IBattleEntity, param2:TileRect, param3:TileRect, param4:Boolean, param5:Boolean, param6:Boolean = false) : Tile
      {
         var _loc15_:int = 0;
         var _loc16_:Vector.<IBattleEntity> = null;
         var _loc17_:TileRect = null;
         var _loc18_:IBattleEntity = null;
         var _loc7_:IBattleBoard = param1.board;
         var _loc8_:TileRect = _computeMovingRect(param2,param3);
         if(!_loc8_)
         {
            return null;
         }
         var _loc9_:TileLocation = _loc8_.loc;
         var _loc10_:Tiles = _loc7_.tiles;
         var _loc11_:Tile = _computeLandingLocation(_loc7_,_loc8_,param3,param5);
         if(!_loc11_)
         {
            return null;
         }
         var _loc12_:TileLocation = _loc11_.location;
         _loc8_.setLocation(_loc12_);
         var _loc13_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         _loc7_.findAllRectIntersectionEntities(_loc8_,param1,_loc13_);
         if(_loc13_.length > 0 && Boolean(param1.awareOf(_loc13_[0])))
         {
            return null;
         }
         var _loc14_:BattleFacing = _loc8_.facing as BattleFacing;
         if(Boolean(_loc11_) && !param4)
         {
            _loc8_.setLocation(_loc9_);
            _loc15_ = TileRectRange.computeRange(_loc8_,param3);
            _loc15_ = Math.max(0,_loc15_ - 1);
            if(_loc15_ > 0)
            {
               _loc16_ = new Vector.<IBattleEntity>();
               _loc17_ = new TileRect(_loc9_,_loc8_.diameter,_loc8_.diameter,null);
               _loc17_.grow(_loc14_.x * _loc15_,_loc14_.y * _loc15_);
               _loc7_.findAllRectIntersectionEntities(_loc17_,param1,_loc16_);
               if(_loc16_.length > 0)
               {
                  for each(_loc18_ in _loc16_)
                  {
                     if(!param6 || Boolean(param1.awareOf(_loc18_)))
                     {
                        return null;
                     }
                  }
               }
            }
         }
         return _loc11_;
      }
   }
}
