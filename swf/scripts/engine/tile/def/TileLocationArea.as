package engine.tile.def
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class TileLocationArea
   {
       
      
      public var rect:TileRect;
      
      public var locations:Dictionary;
      
      public var sorted:Array;
      
      public var numTiles:int;
      
      public function TileLocationArea()
      {
         this.locations = new Dictionary();
         this.sorted = [];
         super();
      }
      
      public function clear() : void
      {
         this.locations = new Dictionary();
         this.sorted.splice(0,this.sorted.length);
         this.numTiles = 0;
         this.rect = null;
      }
      
      public function clone() : TileLocationArea
      {
         var _loc2_:TileLocation = null;
         var _loc1_:TileLocationArea = new TileLocationArea();
         _loc1_.rect = !!this.rect ? this.rect.clone() : null;
         for each(_loc2_ in this.locations)
         {
            _loc1_.locations[_loc2_] = _loc2_;
         }
         _loc1_.sorted = this.sorted.concat();
         return _loc1_;
      }
      
      public function addArea(param1:TileLocationArea) : void
      {
         var _loc2_:TileLocation = null;
         for each(_loc2_ in param1.locations)
         {
            this.addTile(_loc2_);
         }
      }
      
      public function addTilePos(param1:int, param2:int) : Boolean
      {
         return this.addTile(TileLocation.fetch(param1,param2));
      }
      
      public function addTile(param1:TileLocation) : Boolean
      {
         if(this.locations[param1] != param1)
         {
            ++this.numTiles;
            this.locations[param1] = param1;
            return true;
         }
         return false;
      }
      
      public function removeTile(param1:TileLocation) : Boolean
      {
         if(this.locations[param1])
         {
            --this.numTiles;
            delete this.locations[param1];
            return true;
         }
         return false;
      }
      
      public function toggleTile(param1:TileLocation) : Boolean
      {
         if(this.hasTile(param1))
         {
            this.removeTile(param1);
            return false;
         }
         this.addTile(param1);
         return true;
      }
      
      public function hasTile(param1:TileLocation) : Boolean
      {
         return param1 in this.locations;
      }
      
      private function _visitTileForInvalidity(param1:int, param2:int, param3:*) : Boolean
      {
         var _loc4_:TileLocation = TileLocation.fetch(param1,param2);
         if(this.locations[_loc4_] == undefined)
         {
            return true;
         }
         return false;
      }
      
      public function hasTiles(param1:TileRect) : Boolean
      {
         return !param1.visitEnclosedTileLocations(this._visitTileForInvalidity,null);
      }
      
      public function fit() : void
      {
         var _loc3_:TileLocation = null;
         var _loc4_:TileLocation = null;
         var _loc1_:Point = new Point(Number.MAX_VALUE,Number.MAX_VALUE);
         var _loc2_:Point = new Point(-Number.MAX_VALUE,-Number.MAX_VALUE);
         for each(_loc3_ in this.locations)
         {
            _loc1_.x = Math.min(_loc3_.x,_loc1_.x);
            _loc1_.y = Math.min(_loc3_.y,_loc1_.y);
            _loc2_.x = Math.max(_loc3_.x,_loc2_.x);
            _loc2_.y = Math.max(_loc3_.y,_loc2_.y);
         }
         _loc4_ = TileLocation.fetch(_loc1_.x,_loc1_.y);
         this.rect = new TileRect(_loc4_,1 + _loc2_.x - _loc1_.x,1 + _loc2_.y - _loc1_.y);
      }
      
      public function sortByDistance(param1:TileLocation) : void
      {
         var toward:TileLocation = param1;
         this.sorted.sort(function(param1:TileLocation, param2:TileLocation):Number
         {
            var _loc3_:int = TileLocation.manhattanDistance(param1.x,param1.y,toward.x,toward.y);
            var _loc4_:int = TileLocation.manhattanDistance(param2.x,param2.y,toward.x,toward.y);
            return _loc3_ - _loc4_;
         });
      }
      
      public function resetSorted() : void
      {
         var _loc1_:TileLocation = null;
         this.sorted.splice(0,this.sorted.length);
         for each(_loc1_ in this.locations)
         {
            this.sorted.push(_loc1_);
         }
         this.sortUniform();
      }
      
      public function sortUniform() : void
      {
         this.sorted.sort(function(param1:TileLocation, param2:TileLocation):Number
         {
            var _loc3_:int = param1.y - param2.y;
            if(_loc3_ == 0)
            {
               return param1.x - param2.x;
            }
            return _loc3_;
         });
      }
      
      public function sortByRow(param1:TileLocation, param2:Boolean) : void
      {
         var fa:int;
         var cdx:int;
         var cdy:int;
         var axis:Point = null;
         var len:int = 0;
         var xlen:Number = NaN;
         var ylen:Number = NaN;
         var toward:TileLocation = param1;
         var front:Boolean = param2;
         if(!this.rect)
         {
            throw new IllegalOperationError("Cannot sort without a rect");
         }
         fa = front ? 1 : -1;
         cdx = Math.abs(this.rect.center.x - toward.x);
         cdy = Math.abs(this.rect.center.y - toward.y);
         if(cdx > cdy)
         {
            axis = new Point(fa,0);
            len = this.rect.diameter;
         }
         else
         {
            axis = new Point(0,fa);
            len = this.rect.diameter;
         }
         xlen = 1 + axis.x * len;
         ylen = 1 + axis.y * len;
         this.sorted.sort(function(param1:TileLocation, param2:TileLocation):Number
         {
            var _loc3_:int = Math.abs(param1.x - toward.x) * xlen + Math.abs(param1.y - toward.y) * ylen;
            var _loc4_:int = Math.abs(param2.x - toward.x) * xlen + Math.abs(param2.y - toward.y) * ylen;
            return _loc3_ - _loc4_;
         });
      }
      
      public function removeSortedRectSize(param1:TileLocation, param2:int, param3:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param2)
         {
            _loc5_ = 0;
            while(_loc5_ < param3)
            {
               _loc6_ = param1.x + _loc4_;
               _loc7_ = param1.y + _loc5_;
               _loc8_ = this.sorted.indexOf(TileLocation.fetch(_loc6_,_loc7_));
               if(_loc8_ >= 0)
               {
                  this.sorted.splice(_loc8_,1);
               }
               _loc5_++;
            }
            _loc4_++;
         }
      }
      
      public function removeSortedRect(param1:TileRect) : void
      {
         param1.visitEnclosedTileLocations(this._visitRemoveSortedRect,null);
      }
      
      private function _visitRemoveSortedRect(param1:int, param2:int, param3:*) : void
      {
         var _loc4_:int = this.sorted.indexOf(TileLocation.fetch(param1,param2));
         if(_loc4_ >= 0)
         {
            this.sorted.splice(_loc4_,1);
         }
      }
      
      public function computeBoundary() : Rectangle
      {
         var _loc2_:TileLocation = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Rectangle = null;
         var _loc1_:Rectangle = new Rectangle();
         for each(_loc2_ in this.locations)
         {
            _loc3_ = _loc2_.x - _loc2_.y;
            _loc4_ = _loc2_.x + _loc2_.y;
            _loc5_ = _loc3_ - 1;
            _loc6_ = _loc3_ + 1;
            _loc7_ = _loc4_;
            _loc8_ = _loc4_ + 2;
            _loc9_ = new Rectangle(_loc5_,_loc7_,_loc6_ - _loc5_,_loc8_ - _loc7_);
            _loc1_ = _loc1_.union(_loc9_);
         }
         return _loc1_;
      }
      
      public function composeRects() : Vector.<TileRect>
      {
         var _loc3_:TileRect = null;
         if(!this.rect)
         {
            this.fit();
         }
         var _loc1_:Vector.<TileRect> = new Vector.<TileRect>();
         var _loc2_:Vector.<TileRect> = new Vector.<TileRect>();
         _loc1_.push(this.rect);
         while(_loc1_.length)
         {
            _loc3_ = _loc1_.pop();
            if(!this.splitRect(_loc3_,_loc1_))
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      private function splitRect(param1:TileRect, param2:Vector.<TileRect>) : Boolean
      {
         if(param1.width == 1 && param1.length == 1)
         {
            return false;
         }
         if(param1.visitEnclosedTileLocations(this._visitSplitRect,{
            "open":param2,
            "rect":param1
         }))
         {
            return true;
         }
         return false;
      }
      
      private function _visitSplitRect(param1:int, param2:int, param3:Object) : Boolean
      {
         var _loc4_:TileLocation = TileLocation.fetch(param1,param2);
         if(this.locations[_loc4_])
         {
            return false;
         }
         var _loc5_:Vector.<TileRect> = param3.open;
         var _loc6_:TileRect = param3.rect;
         if(param1 > _loc6_.left)
         {
            this._makeOpen(_loc5_,_loc6_.left,_loc6_.front,param1 - _loc6_.left,param2 + 1 - _loc6_.front);
         }
         if(param2 > _loc6_.front)
         {
            this._makeOpen(_loc5_,param1,_loc6_.front,_loc6_.right - param1,param2 - _loc6_.front);
         }
         if(param2 < _loc6_.back - 1)
         {
            this._makeOpen(_loc5_,0,param2 + 1,param1 + 1 - _loc6_.left,_loc6_.back - param2 - 1);
         }
         if(param1 < _loc6_.right - 1)
         {
            this._makeOpen(_loc5_,param1 + 1,param2,_loc6_.right - param1 - 1,_loc6_.back - param2);
         }
         return true;
      }
      
      private function _makeOpen(param1:Vector.<TileRect>, param2:int, param3:int, param4:int, param5:int) : void
      {
         if(param4 <= 0 || param5 <= 0)
         {
            throw new IllegalOperationError("bad size");
         }
         var _loc6_:TileLocation = TileLocation.fetch(param2,param3);
         var _loc7_:TileRect = new TileRect(_loc6_,param4,param5);
         param1.push(_loc7_);
      }
   }
}
