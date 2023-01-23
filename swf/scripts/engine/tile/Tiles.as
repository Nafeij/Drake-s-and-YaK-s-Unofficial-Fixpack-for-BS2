package engine.tile
{
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.board.def.ITileTriggerDef;
   import engine.path.IPath;
   import engine.path.IPathGraph;
   import engine.tile.def.TileDef;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileWalkableType;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class Tiles extends EventDispatcher
   {
      
      private static var lastTransientBlockageId:int = 0;
      
      private static var transientBlockages:Dictionary = new Dictionary();
       
      
      public var tiles:Vector.<Tile>;
      
      public var tilesByLocation:Dictionary;
      
      public var pathGraph:IPathGraph;
      
      private var entityPositions:Dictionary;
      
      private var nodeBlockedCheckers:Dictionary;
      
      private var nodeHazardCheckers:Dictionary;
      
      public var flyText:String;
      
      public var flyTextColor:uint;
      
      public var flyTextTile:Tile;
      
      public var flyTextFontName:String;
      
      public var flyTextFontSize:int;
      
      public function Tiles(param1:TileLocationArea, param2:TileLocationArea)
      {
         var _loc3_:Tile = null;
         var _loc4_:TileLocation = null;
         this.tiles = new Vector.<Tile>();
         this.tilesByLocation = new Dictionary();
         this.entityPositions = new Dictionary();
         this.nodeBlockedCheckers = new Dictionary(true);
         this.nodeHazardCheckers = new Dictionary(true);
         super();
         for each(_loc4_ in param1.locations)
         {
            if(this.getTileByLocation(_loc4_))
            {
               throw new ArgumentError("Already exists: " + _loc4_);
            }
            _loc3_ = this.createTile(_loc4_.x,_loc4_.y,TileWalkableType.WALKABLE);
            this.tilesByLocation[_loc4_] = _loc3_;
            this.tiles.push(_loc3_);
         }
         for each(_loc4_ in param2.locations)
         {
            if(this.getTileByLocation(_loc4_))
            {
               throw new ArgumentError("Already exists: " + _loc4_);
            }
            _loc3_ = this.createTile(_loc4_.x,_loc4_.y,TileWalkableType.NOT_WALKABLE);
            this.tilesByLocation[_loc4_] = _loc3_;
            this.tiles.push(_loc3_);
         }
         this.pathGraph = this.createPathGraph();
      }
      
      public static function addTransientBlockage(param1:TileRect, param2:ITileResident) : int
      {
         var _loc3_:int = int(++lastTransientBlockageId);
         var _loc4_:Object = {
            "tileRect":param1,
            "entity":param2
         };
         transientBlockages[_loc3_] = _loc4_;
         return _loc3_;
      }
      
      public static function removeTransientBlockage(param1:int) : void
      {
         delete transientBlockages[param1];
      }
      
      public function cleanupTiles() : void
      {
         var _loc1_:Tile = null;
         this.pathGraph.cleanup();
         this.pathGraph = null;
         for each(_loc1_ in this.tiles)
         {
            _loc1_.cleanup();
         }
         this.tiles = null;
         this.tilesByLocation = null;
         this.entityPositions = null;
      }
      
      protected function createTile(param1:int, param2:int, param3:TileWalkableType) : Tile
      {
         return new Tile(new TileDef(param1,param2,param3),this);
      }
      
      public function isEdge(param1:int, param2:int, param3:int) : Boolean
      {
         if(!this.getTile(param1 - 1,param2 + 0) || !this.getTile(param1 + 0,param2 - 1) || !this.getTile(param1 + param3,param2 + 0) || !this.getTile(param1 + 0,param2 + param3))
         {
            return true;
         }
         return false;
      }
      
      public function canFit(param1:int, param2:int, param3:int, param4:Boolean) : Boolean
      {
         var _loc6_:int = 0;
         var _loc7_:Tile = null;
         var _loc5_:int = 0;
         while(_loc5_ < param3)
         {
            _loc6_ = 0;
            while(_loc6_ < param3)
            {
               _loc7_ = this.getTile(param1 + _loc5_,param2 + _loc6_);
               if(!_loc7_)
               {
                  return false;
               }
               if(param4)
               {
                  if(_loc7_.numResidents > 0)
                  {
                     return false;
                  }
               }
               _loc6_++;
            }
            _loc5_++;
         }
         return true;
      }
      
      public function collectEdges(param1:Vector.<Tile>, param2:int, param3:Boolean) : Vector.<Tile>
      {
         var _loc4_:Tile = null;
         var _loc5_:TileLocation = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(!param1)
         {
            param1 = new Vector.<Tile>();
         }
         for each(_loc4_ in this.tiles)
         {
            if(_loc4_.getWalkableFor(null))
            {
               _loc5_ = _loc4_.location;
               _loc6_ = _loc5_.x;
               _loc7_ = _loc5_.y;
               if(this.isEdge(_loc6_,_loc7_,param2))
               {
                  if(this.canFit(_loc6_,_loc7_,param2,param3))
                  {
                     param1.push(_loc4_);
                  }
               }
            }
         }
         return param1;
      }
      
      protected function createPathGraph() : IPathGraph
      {
         return null;
      }
      
      public function addTrigger(param1:String, param2:ITileTriggerDef, param3:TileRect, param4:Boolean, param5:IEffect, param6:Boolean) : TileTrigger
      {
         return null;
      }
      
      public function removeTrigger(param1:TileTrigger) : void
      {
      }
      
      private function updateEntityTiles(param1:ITileResident, param2:Rectangle, param3:Boolean) : void
      {
         var _loc9_:int = 0;
         var _loc10_:Tile = null;
         var _loc4_:int = param2.left;
         var _loc5_:int = param2.right;
         var _loc6_:int = param2.top;
         var _loc7_:int = param2.bottom;
         var _loc8_:int = _loc4_;
         while(_loc8_ < _loc5_)
         {
            _loc9_ = _loc6_;
            while(_loc9_ < _loc7_)
            {
               _loc10_ = this.getTile(_loc8_,_loc9_);
               if(_loc10_)
               {
                  if(!param3)
                  {
                     _loc10_.removeResident(param1);
                  }
                  else
                  {
                     _loc10_.addResident(param1);
                  }
               }
               _loc9_++;
            }
            _loc8_++;
         }
      }
      
      final public function blockTilesForEntity(param1:ITileResident) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:Rectangle = this.entityPositions[param1];
         if(_loc2_)
         {
            this.updateEntityTiles(param1,_loc2_,false);
         }
         else
         {
            _loc2_ = new Rectangle();
         }
         if(param1.tiles != this)
         {
            return;
         }
         var _loc3_:TileRect = param1.rect;
         if(_loc3_)
         {
            _loc2_ = _loc3_.toRectangle(_loc2_);
            this.updateEntityTiles(param1,_loc2_,true);
            this.entityPositions[param1] = _loc2_;
         }
      }
      
      public function hasTilesForRect(param1:TileRect) : Boolean
      {
         return !param1.visitEnclosedTileLocations(this._checkMissingTile,null);
      }
      
      private function _checkMissingTile(param1:int, param2:int, param3:*) : Boolean
      {
         return this.getTile(param1,param2) == null;
      }
      
      public function getTileByLocation(param1:TileLocation) : Tile
      {
         return !!param1 ? this.tilesByLocation[param1] : null;
      }
      
      public function getTile(param1:int, param2:int) : Tile
      {
         var _loc3_:TileLocation = TileLocation.fetch(param1,param2);
         return this.getTileByLocation(_loc3_);
      }
      
      public function getPath(param1:ITileResident, param2:int, param3:int) : IPath
      {
         var _loc4_:Tile = param1.tile;
         var _loc5_:Tile = this.getTile(param2,param3);
         if(_loc4_ == _loc5_ || _loc4_ == null || _loc5_ == null)
         {
            return null;
         }
         var _loc6_:NodeBlockedChecker_Tiles = this.getNodeBlockedChecker(param1);
         var _loc7_:NodeHazardChecker_Tiles = this.getNodeHazardChecker(param1);
         return this.pathGraph.getPath(_loc4_,_loc5_,_loc6_.nodeBlockedFunc,_loc7_.nodeHazardFunc);
      }
      
      private function getNodeBlockedChecker(param1:ITileResident) : NodeBlockedChecker_Tiles
      {
         var _loc2_:NodeBlockedChecker_Tiles = this.nodeBlockedCheckers[param1];
         if(!_loc2_)
         {
            _loc2_ = new NodeBlockedChecker_Tiles(this,param1);
            this.nodeBlockedCheckers[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      private function getNodeHazardChecker(param1:ITileResident) : NodeHazardChecker_Tiles
      {
         var _loc2_:NodeHazardChecker_Tiles = this.nodeHazardCheckers[param1];
         if(!_loc2_)
         {
            _loc2_ = new NodeHazardChecker_Tiles(this,param1);
            this.nodeHazardCheckers[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public function isTileBlockedForEntity(param1:ITileResident, param2:Tile, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false, param6:Vector.<ITileResident> = null) : Boolean
      {
         var _loc11_:TileLocation = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:Tile = null;
         var _loc17_:ITileResident = null;
         var _loc18_:Object = null;
         var _loc19_:ITileResident = null;
         var _loc20_:TileRect = null;
         var _loc21_:ITileResident = null;
         var _loc7_:Tile = param1.tile;
         var _loc8_:int = param1.diameter;
         var _loc9_:int = param2.x;
         var _loc10_:int = param2.y;
         var _loc12_:int = 0;
         while(_loc12_ < _loc8_)
         {
            _loc13_ = 0;
            while(_loc13_ < _loc8_)
            {
               _loc14_ = _loc9_ + _loc12_;
               _loc15_ = _loc10_ + _loc13_;
               _loc11_ = TileLocation.fetch(_loc14_,_loc15_);
               _loc16_ = !!_loc11_ ? this.tilesByLocation[_loc11_] : null;
               if(_loc16_ == null)
               {
                  return true;
               }
               if(!param5)
               {
                  if(Boolean(_loc7_) && _loc7_.getWalkableFor(param1))
                  {
                     if(!_loc16_.getWalkableFor(param1))
                     {
                        return true;
                     }
                  }
               }
               for each(_loc17_ in _loc16_.residents)
               {
                  _loc19_ = _loc16_.residents[_loc17_];
                  if(this._checkBlockage(param1,_loc19_,param3,param4))
                  {
                     if(param6)
                     {
                        param6.push(_loc19_);
                     }
                     return true;
                  }
               }
               for each(_loc18_ in transientBlockages)
               {
                  _loc20_ = _loc18_.tileRect;
                  _loc21_ = _loc18_.entity;
                  if(_loc20_.contains(_loc14_,_loc15_))
                  {
                     if(this._checkBlockage(param1,_loc21_,param3,param4))
                     {
                        if(param6)
                        {
                           param6.push(_loc21_);
                        }
                        return true;
                     }
                  }
               }
               _loc13_++;
            }
            _loc12_++;
         }
         return false;
      }
      
      private function _checkBlockage(param1:ITileResident, param2:ITileResident, param3:Boolean, param4:Boolean) : Boolean
      {
         if(param2.nonexistant || param2 == param1)
         {
            return false;
         }
         if(!param4 || param2.visible || param1.awareOf(param2))
         {
            if(!param3)
            {
               return true;
            }
            if(!param1.canPass(param2))
            {
               return true;
            }
         }
         return false;
      }
      
      public function emitFlyText(param1:Tile, param2:String, param3:uint, param4:String, param5:int) : void
      {
         this.flyTextTile = param1;
         this.flyText = param2;
         this.flyTextColor = param3;
         this.flyTextFontName = param4;
         this.flyTextFontSize = param5;
         dispatchEvent(new TilesEvent(TilesEvent.TILE_FLYTEXT));
      }
   }
}

import engine.path.IPathGraphNode;
import engine.tile.ITileResident;
import engine.tile.Tile;
import engine.tile.Tiles;

class NodeBlockedChecker_Tiles
{
    
   
   public var entity:ITileResident;
   
   public var tiles:Tiles;
   
   public function NodeBlockedChecker_Tiles(param1:Tiles, param2:ITileResident)
   {
      super();
      this.entity = param2;
      this.tiles = param1;
   }
   
   public function nodeBlockedFunc(param1:IPathGraphNode) : Boolean
   {
      var _loc2_:Tile = param1.key as Tile;
      return this.tiles.isTileBlockedForEntity(this.entity,_loc2_);
   }
}

import engine.path.IPathGraphNode;
import engine.tile.ITileResident;
import engine.tile.Tiles;

class NodeHazardChecker_Tiles
{
    
   
   public var entity:ITileResident;
   
   public var tiles:Tiles;
   
   public function NodeHazardChecker_Tiles(param1:Tiles, param2:ITileResident)
   {
      super();
      this.entity = param2;
      this.tiles = param1;
   }
   
   public function nodeHazardFunc(param1:IPathGraphNode) : Number
   {
      return 0;
   }
}
