package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.math.Rng;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   
   public class Op_KnockbackHelper
   {
       
      
      public function Op_KnockbackHelper()
      {
         super();
      }
      
      public static function getKnockbackStopTile(param1:IBattleAbilityDef, param2:IBattleEntity, param3:TileRect, param4:IBattleEntity, param5:Boolean) : Tile
      {
         if(!param4.alive)
         {
            return null;
         }
         var _loc6_:int = param1.maxResultDistance;
         var _loc7_:int = int(param4.stats.getValue(StatType.KNOCKBACK_DEFERRED));
         if(_loc7_)
         {
            param4.logger.info("using KNOCKBACK_DEFERRED " + _loc7_ + " on target " + param4);
            _loc6_ += _loc7_;
         }
         var _loc8_:int = Number(param4.centerX) - param3.center.x;
         var _loc9_:int = Number(param4.centerY) - param3.center.y;
         if(Math.abs(_loc8_) > Math.abs(_loc9_))
         {
            _loc9_ = 0;
            if(_loc8_ > 0)
            {
               _loc8_ = 1;
            }
            else
            {
               _loc8_ = -1;
            }
         }
         else
         {
            _loc8_ = 0;
            if(_loc9_ > 0)
            {
               _loc9_ = 1;
            }
            else
            {
               _loc9_ = -1;
            }
         }
         return getStopTile(param4,_loc8_,_loc9_,_loc6_,param5);
      }
      
      public static function getStopTile(param1:IBattleEntity, param2:int, param3:int, param4:int, param5:Boolean) : Tile
      {
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:TileLocation = null;
         var _loc17_:Tile = null;
         var _loc6_:IBattleBoard = param1.board;
         var _loc7_:Tiles = _loc6_.tiles;
         var _loc8_:Tile = param1.tile;
         var _loc9_:int = _loc8_.x;
         var _loc10_:int = _loc8_.y;
         var _loc11_:TileRect = param1.rect.clone();
         var _loc12_:Tile = null;
         var _loc13_:int = 1;
         while(_loc13_ <= param4)
         {
            _loc14_ = param2 * _loc13_;
            _loc15_ = param3 * _loc13_;
            _loc16_ = TileLocation.fetch(_loc9_ + _loc14_,_loc10_ + _loc15_);
            _loc17_ = _loc7_.getTileByLocation(_loc16_);
            if(!_loc17_)
            {
               break;
            }
            _loc11_.setLocation(_loc16_);
            if(_loc11_.visitEnclosedTileLocations(_visitStopTileLocations,param1))
            {
               if(!param5)
               {
                  break;
               }
            }
            else
            {
               _loc12_ = _loc17_;
            }
            _loc13_++;
         }
         return _loc12_;
      }
      
      public static function getRandomDirectionCasterRect(param1:IBattleEntity, param2:Rng) : TileRect
      {
         var _loc6_:TileLocation = null;
         var _loc3_:IBattleBoard = param1.board;
         var _loc4_:Tiles = _loc3_.tiles;
         var _loc5_:int = param2.nextMinMax(0,3);
         switch(_loc5_)
         {
            case 0:
               _loc6_ = TileLocation.fetch(param1.centerX + 1,param1.centerY);
               break;
            case 1:
               _loc6_ = TileLocation.fetch(param1.centerX - 1,param1.centerY);
               break;
            case 2:
               _loc6_ = TileLocation.fetch(param1.centerX,param1.centerY + 1);
               break;
            default:
               _loc6_ = TileLocation.fetch(param1.centerX,param1.centerY - 1);
         }
         var _loc7_:Tile = _loc4_.getTileByLocation(_loc6_);
         return !!_loc7_ ? _loc7_.rect : null;
      }
      
      private static function _visitStopTileLocations(param1:int, param2:int, param3:IBattleEntity) : Boolean
      {
         var _loc4_:Tile = param3.board.tiles.getTile(param1,param2);
         if(!_loc4_ || !_loc4_.getWalkableFor(param3) && !param3.rect.contains(param1,param2))
         {
            return true;
         }
         var _loc5_:IBattleEntity = param3.board.findEntityOnTile(param1,param2,true,param3);
         return _loc5_ != null;
      }
   }
}
