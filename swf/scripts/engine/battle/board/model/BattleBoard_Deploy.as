package engine.battle.board.model
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.def.BattleDeploymentAreas;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import engine.tile.def.TileRect;
   import flash.geom.Point;
   
   public class BattleBoard_Deploy
   {
       
      
      public var board:IBattleBoard;
      
      public function BattleBoard_Deploy(param1:IBattleBoard)
      {
         super();
         this.board = param1;
      }
      
      public function attemptDeploy(param1:IBattleEntity, param2:BattleFacing, param3:TileLocationArea, param4:TileLocation) : Boolean
      {
         if(Boolean(param2) && this.canDeploy(param1,param2,param3,param4))
         {
            param1.setPos(param4._x,param4._y);
            param1.facing = param2;
            param1.deploymentReady = true;
            return true;
         }
         if(this.canDeploy(param1,null,param3,param4))
         {
            param1.setPos(param4._x,param4._y);
            param1.deploymentReady = true;
            return true;
         }
         return false;
      }
      
      public function attemptDeployRect(param1:IBattleEntity, param2:TileLocationArea, param3:TileRect) : Boolean
      {
         if(!this.canDeployRect(param1,param2,param3))
         {
            return false;
         }
         param1.setPosFromTileRect(param3);
         param1.deploymentReady = true;
         this.board.logger.i("SPWN","Deployed " + param1.name + " to " + param3.loc.toString());
         return true;
      }
      
      public function canDeployEitherWay(param1:IBattleEntity, param2:BattleFacing, param3:TileLocationArea, param4:TileLocation) : Boolean
      {
         if(this.canDeploy(param1,param2,param3,param4))
         {
            return true;
         }
         if(Boolean(param2) && param1.facing != param2)
         {
            if(param1.localLength != param1.localWidth)
            {
               if(this.canDeploy(param1,null,param3,param4))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function canDeploy(param1:IBattleEntity, param2:BattleFacing, param3:TileLocationArea, param4:TileLocation) : Boolean
      {
         if(!param4)
         {
            return false;
         }
         var _loc5_:TileRect = param1.rect.clone();
         _loc5_.facing = param2;
         _loc5_.setLocation(param4);
         var _loc6_:Boolean = this.board.spatial.findAllRectIntersectionEntities(_loc5_,param1,null);
         if(_loc6_)
         {
            return false;
         }
         if(_loc5_.visitEnclosedTileLocations(this._visitCannotDeploy,param3))
         {
            return false;
         }
         return true;
      }
      
      public function canDeployRect(param1:IBattleEntity, param2:TileLocationArea, param3:TileRect) : Boolean
      {
         if(!param3)
         {
            return false;
         }
         var _loc4_:Boolean = this.board.spatial.findAllRectIntersectionEntities(param3,param1,null);
         if(_loc4_)
         {
            return false;
         }
         if(param3.visitEnclosedTileLocations(this._visitCannotDeploy,param2))
         {
            return false;
         }
         return true;
      }
      
      private function _visitCannotDeploy(param1:int, param2:int, param3:TileLocationArea) : Boolean
      {
         var _loc4_:TileLocation = TileLocation.fetch(param1,param2);
         var _loc5_:Tile = this.board.tiles.getTileByLocation(_loc4_);
         if(!_loc5_)
         {
            return true;
         }
         if(!param3.hasTile(_loc4_))
         {
            return true;
         }
         return false;
      }
      
      public function findNextDeploymentTile(param1:IBattleEntity, param2:BattleDeploymentAreas, param3:TileLocation, param4:Point) : Tile
      {
         var _loc13_:TileLocation = null;
         var _loc14_:Boolean = false;
         var _loc15_:BattleFacing = null;
         var _loc5_:TileLocationArea = param2.area;
         if(!_loc5_ || !_loc5_.numTiles)
         {
            return null;
         }
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:TileRect = _loc5_.rect;
         _loc6_ = Math.min(_loc6_,_loc10_.left);
         _loc9_ = Math.min(_loc9_,_loc10_.front);
         _loc7_ = Math.max(_loc7_,_loc10_.right);
         _loc8_ = Math.max(_loc8_,_loc10_.back);
         var _loc11_:TileRect = param1.rect.clone();
         var _loc12_:int = 1;
         while(true)
         {
            _loc13_ = TileLocation.fetch(param3.x + param4.x * _loc12_,param3.y + param4.y * _loc12_);
            _loc14_ = false;
            if(_loc13_.x >= _loc7_ || _loc13_.y >= _loc8_ || _loc13_.x < _loc6_ || _loc13_.y < _loc9_)
            {
               break;
            }
            _loc14_ = true;
            _loc11_.setLocation(_loc13_);
            _loc15_ = param2.getLocationFacing(_loc13_);
            _loc11_.facing = _loc15_;
            if(_loc5_.hasTiles(_loc11_))
            {
               if(this.canDeployEitherWay(param1,_loc15_,_loc5_,_loc13_))
               {
                  return this.board.tiles.getTileByLocation(_loc13_);
               }
            }
            if(!_loc14_)
            {
               return null;
            }
            _loc12_++;
         }
         return null;
      }
      
      public function findNearestDeploymentLocation(param1:IBattleEntity, param2:BattleDeploymentAreas, param3:TileLocation) : TileLocation
      {
         var tr:TileRect;
         var sorted:Array;
         var loc:TileLocation = null;
         var i:int = 0;
         var locSorted:TileLocation = null;
         var c:IBattleEntity = param1;
         var areas:BattleDeploymentAreas = param2;
         var tloc:TileLocation = param3;
         var area:TileLocationArea = areas.area;
         if(!area || !area.numTiles)
         {
            return tloc;
         }
         tr = c.rect.clone();
         if(this.canDeployHere(tr,c,areas,tloc))
         {
            return tloc;
         }
         sorted = [];
         sorted.splice(0,sorted.length);
         for each(loc in area.locations)
         {
            sorted.push(loc);
         }
         sorted.sort(function(param1:TileLocation, param2:TileLocation):Number
         {
            var _loc3_:int = TileLocation.manhattanDistance(param1.x,param1.y,tloc.x,tloc.y);
            var _loc4_:int = TileLocation.manhattanDistance(param2.x,param2.y,tloc.x,tloc.y);
            return _loc3_ - _loc4_;
         });
         i = 0;
         while(i < sorted.length)
         {
            locSorted = sorted[i];
            if(this.canDeployHere(tr,c,areas,locSorted))
            {
               return locSorted;
            }
            i++;
         }
         return tloc;
      }
      
      private function canDeployHere(param1:TileRect, param2:IBattleEntity, param3:BattleDeploymentAreas, param4:TileLocation) : Boolean
      {
         param1.setLocation(param4);
         var _loc5_:BattleFacing = param3.getLocationFacing(param4);
         param1.facing = _loc5_;
         if(param3.area.hasTiles(param1))
         {
            if(this.canDeployEitherWay(param2,_loc5_,param3.area,param4))
            {
               return true;
            }
         }
         return false;
      }
   }
}
