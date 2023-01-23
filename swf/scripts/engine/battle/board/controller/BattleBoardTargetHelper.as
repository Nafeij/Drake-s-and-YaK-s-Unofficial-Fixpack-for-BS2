package engine.battle.board.controller
{
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.math.MathUtil;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileRect;
   import flash.geom.Point;
   
   public class BattleBoardTargetHelper
   {
       
      
      public function BattleBoardTargetHelper()
      {
         super();
      }
      
      public static function forwardArc_setupAbility(param1:BattleAbility, param2:Tile) : void
      {
         var _loc3_:TileRect = param1.caster.rect;
         param1._targetSet.setTarget(null);
         var _loc4_:Point = _loc3_.getDirectionToward(param2.rect,null);
         var _loc5_:BattleFacing = BattleFacing.findFacing(_loc4_.x,_loc4_.y);
         _loc3_.visitAdjacentEdgeTileLocations(_visitForwardArcTileHandler_setupAbility,_loc5_,param1,true);
         var _loc6_:IBattleEntity = param2.findResident(null) as IBattleEntity;
         if(_loc6_)
         {
            if(param1.targetSet.hasTarget(_loc6_))
            {
               param1.targetSet.removeTarget(_loc6_,false);
               param1.targetSet.addTarget(_loc6_);
            }
         }
         param1.targetSet.setTile(param2);
      }
      
      private static function _visitForwardArcTileHandler_setupAbility(param1:int, param2:int, param3:BattleAbility) : void
      {
         var _loc5_:IBattleEntity = null;
         var _loc4_:Tile = param3.caster.tiles.getTile(param1,param2);
         if(_loc4_)
         {
            _loc5_ = _loc4_.findResident(param3.caster) as IBattleEntity;
            if(Boolean(_loc5_) && Boolean(_loc5_.attackable))
            {
               if(param3.caster.awareOf(_loc5_))
               {
                  if(!param3.targetSet.hasTarget(_loc5_))
                  {
                     param3.targetSet.addTarget(_loc5_);
                  }
               }
            }
         }
      }
      
      public static function forwardArc_getVictims(param1:IBattleEntity, param2:TileRect, param3:Tile, param4:Vector.<IBattleEntity>) : void
      {
         var _loc10_:int = 0;
         var _loc5_:Tiles = param1.board.tiles;
         var _loc6_:Point = param2.getDirectionToward(param3.rect,null);
         var _loc7_:BattleFacing = BattleFacing.findFacing(_loc6_.x,_loc6_.y);
         var _loc8_:Object = {
            "vv":param4,
            "tiles":_loc5_,
            "caster":param1
         };
         param2.visitAdjacentEdgeTileLocations(_visitForwardArcTileHandler_getVictims,_loc7_,_loc8_,true);
         var _loc9_:IBattleEntity = param3.findResident(null) as IBattleEntity;
         if(_loc9_)
         {
            _loc10_ = param4.indexOf(_loc9_);
            if(_loc10_ >= 0 && _loc10_ < param4.length - 1)
            {
               param4[_loc10_] = param4[param4.length - 1];
               param4[param4.length - 1] = _loc9_;
            }
         }
      }
      
      private static function _visitForwardArcTileHandler_getVictims(param1:int, param2:int, param3:Object) : void
      {
         var _loc8_:IBattleEntity = null;
         var _loc4_:Vector.<IBattleEntity> = param3.vv;
         var _loc5_:Tiles = param3.tiles;
         var _loc6_:IBattleEntity = param3.caster;
         var _loc7_:Tile = _loc5_.getTile(param1,param2);
         if(_loc7_)
         {
            _loc8_ = _loc7_.findResident(_loc6_) as IBattleEntity;
            if(Boolean(_loc8_) && Boolean(_loc8_.attackable))
            {
               if(_loc6_.awareOf(_loc8_))
               {
                  if(_loc4_.indexOf(_loc8_) < 0)
                  {
                     _loc4_.push(_loc8_);
                  }
               }
            }
         }
      }
      
      public static function sortClockwise(param1:IBattleEntity, param2:IBattleEntity, param3:Vector.<IBattleEntity>, param4:Vector.<IBattleEntity>) : void
      {
         var _loc7_:BattleEntity = null;
         var _loc8_:Object = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Object = null;
         if(param3.length == 0)
         {
            return;
         }
         var _loc5_:Number = Math.atan2(Number(param2.centerX) - Number(param1.centerX),Number(param2.centerY) - Number(param1.centerY));
         var _loc6_:Array = [];
         for each(_loc7_ in param3)
         {
            _loc9_ = _loc7_.centerX - Number(param1.centerX);
            _loc10_ = _loc7_.centerY - Number(param1.centerY);
            _loc11_ = Math.atan2(_loc9_,_loc10_);
            _loc11_ -= _loc5_;
            _loc11_ = -_loc11_;
            _loc11_ = MathUtil.radians2Pi(_loc11_);
            _loc12_ = {
               "angle":_loc11_,
               "entity":_loc7_
            };
            _loc6_.push(_loc12_);
         }
         _loc6_.sortOn(["angle"]);
         param4.splice(0,param4.length);
         for each(_loc8_ in _loc6_)
         {
            param4.push(_loc8_.entity);
         }
      }
      
      public static function selectAdjacent(param1:IBattleEntity, param2:TileRect, param3:BattleAbilityTargetRule, param4:Vector.<IBattleEntity>) : void
      {
         var _loc7_:IBattleEntity = null;
         var _loc8_:IBattleEntity = null;
         var _loc5_:Vector.<IBattleEntity> = param1.board.findAllAdjacentEntities(param1,param2,null,true);
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_.length)
         {
            _loc7_ = _loc5_[_loc6_];
            _loc8_ = _loc7_ as IBattleEntity;
            if(_loc8_)
            {
               if(param1.awareOf(_loc8_))
               {
                  if(param3.isValid(param1,param2,_loc8_,null,false))
                  {
                     param4.push(_loc8_);
                  }
               }
            }
            _loc6_++;
         }
      }
   }
}
