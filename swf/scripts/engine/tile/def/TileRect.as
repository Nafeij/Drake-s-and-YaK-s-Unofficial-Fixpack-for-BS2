package engine.tile.def
{
   import engine.anim.def.IAnimFacing;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class TileRect
   {
       
      
      public var loc:TileLocation;
      
      public var _localWidth:int;
      
      public var _localLength:int;
      
      public var _facing:IAnimFacing;
      
      public var _cached_d_right:int;
      
      public var _cached_d_left:int;
      
      public var _cached_d_front:int;
      
      public var _cached_d_back:int;
      
      public var center:Point;
      
      public var localCenter:Point;
      
      public var localTail:Point;
      
      public var width:int;
      
      public var length:int;
      
      public var tail:int;
      
      public var diameter:int;
      
      public function TileRect(param1:TileLocation, param2:int, param3:int, param4:IAnimFacing = null)
      {
         this.center = new Point();
         this.localCenter = new Point();
         this.localTail = new Point();
         super();
         this.setup(param1,param2,param3,param4);
      }
      
      public function setup(param1:TileLocation, param2:int, param3:int, param4:IAnimFacing = null) : TileRect
      {
         if(param1 == null)
         {
            param1 = TileLocation.fetch(0,0);
         }
         this._facing = param4;
         this.setLocation(param1);
         this._localWidth = param2;
         this._localLength = param3;
         this.diameter = Math.min(param2,param3);
         this.tail = Math.max(param2,param3) - this.diameter;
         this._cacheFacing();
         return this;
      }
      
      public function copyFrom(param1:TileRect) : TileRect
      {
         this.loc = param1.loc;
         this._facing = param1._facing;
         this._localWidth = param1._localWidth;
         this._localLength = param1._localLength;
         this.diameter = param1.diameter;
         this.tail = param1.tail;
         this._cached_d_right = param1._cached_d_right;
         this._cached_d_left = param1._cached_d_left;
         this._cached_d_front = param1._cached_d_front;
         this._cached_d_back = param1._cached_d_back;
         this.width = param1.width;
         this.length = param1.length;
         this.localTail.setTo(param1.localTail.x,param1.localTail.y);
         this.center.setTo(param1.center.x,param1.center.y);
         this.localCenter.setTo(param1.localCenter.x,param1.localCenter.y);
         return this;
      }
      
      public function setRect(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         if(param3 == this.width && param4 == this.length && param1 == this.loc._x && param2 == this.loc._y)
         {
            return false;
         }
         this.loc = TileLocation.fetch(param1,param2);
         this.width = param3;
         this.length = param4;
         this._localWidth = this.width;
         this._localLength = this.length;
         this._cacheFacing();
         return true;
      }
      
      public function setEdges(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         if(param1 == this.left && param2 == this.front && param3 == this.right && param4 == this.back)
         {
            return false;
         }
         if(param3 == this.right)
         {
            param1 = Math.min(param1,param3 - 1);
         }
         else
         {
            param3 = Math.max(param3,param1 + 1);
         }
         if(param4 == this.back)
         {
            param2 = Math.min(param2,param4 - 1);
         }
         else
         {
            param4 = Math.max(param4,param2 + 1);
         }
         this.loc = TileLocation.fetch(param1,param2);
         this.width = param3 - param1;
         this.length = param4 - param2;
         this._localWidth = this.width;
         this._localLength = this.length;
         this._cacheFacing();
         return true;
      }
      
      public function setSize(param1:int, param2:int) : Boolean
      {
         if(param1 == this.width && param2 == this.length)
         {
            return false;
         }
         this.width = param1;
         this.length = param2;
         this._localWidth = this.width;
         this._localLength = this.length;
         this._cacheFacing();
         return true;
      }
      
      public function resize(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:int = this.left;
         var _loc6_:int = this.right;
         var _loc7_:int = this.front;
         var _loc8_:int = this.back;
         _loc5_ += param1;
         _loc6_ += param2;
         _loc7_ += param3;
         _loc8_ += param4;
         _loc6_ = Math.max(_loc6_,_loc5_ + 1);
         _loc5_ = Math.min(_loc5_,_loc6_ - 1);
         _loc8_ = Math.max(_loc8_,_loc7_ + 1);
         _loc7_ = Math.min(_loc7_,_loc8_ - 1);
         if(_loc7_ != this.front || _loc8_ != this.back || _loc6_ != this.right || _loc5_ != this.left)
         {
            this.loc = TileLocation.fetch(_loc5_,_loc7_);
            this.setSize(_loc6_ - _loc5_,_loc8_ - _loc7_);
            return true;
         }
         return false;
      }
      
      public function growUniform(param1:int) : TileRect
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param1 > 0)
         {
            this._localWidth += param1 * 2;
            this._localLength += param1 * 2;
            this.loc = TileLocation.fetch(this.loc.x - param1,this.loc.y - param1);
         }
         else if(param1 < 0)
         {
            _loc2_ = this._localWidth;
            _loc3_ = this._localLength;
            this._localWidth = Math.max(1,this._localWidth + param1);
            this._localLength = Math.max(1,this._localLength + param1);
            _loc4_ = this._localWidth - _loc2_;
            _loc5_ = this._localLength - _loc3_;
            _loc6_ = this.loc.x;
            _loc7_ = this.loc.y;
            _loc6_ += _loc4_ / 2;
            _loc7_ += _loc5_ / 2;
            this.loc = TileLocation.fetch(_loc6_,_loc7_);
         }
         this._cacheFacing();
         return this;
      }
      
      public function grow(param1:int, param2:int) : TileRect
      {
         if(this._facing)
         {
            throw new IllegalOperationError("Unsupported for facing");
         }
         if(param1 > 0)
         {
            this._localWidth += param1;
            this.width += param1;
         }
         else if(param1 < 0)
         {
            this._localWidth -= param1;
            this.width -= param1;
            this.loc = TileLocation.fetch(this.loc.x + param1,this.loc.y);
         }
         if(param2 > 0)
         {
            this._localLength += param2;
            this.length += param2;
         }
         else if(param2 < 0)
         {
            this._localLength -= param2;
            this.length -= param2;
            this.loc = TileLocation.fetch(this.loc.x,this.loc.y + param2);
         }
         this._cacheFacing();
         return this;
      }
      
      public function setLocation(param1:TileLocation) : TileRect
      {
         if(this.loc == param1)
         {
            return this;
         }
         this.loc = param1;
         this._cacheCenter();
         return this;
      }
      
      public function equals(param1:TileRect) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(this == param1)
         {
            return true;
         }
         if(this.loc == param1.loc && this._localWidth == param1._localWidth && this._localLength == param1._localLength)
         {
            if(this._localWidth != this._localLength)
            {
               return this._facing == param1._facing;
            }
         }
         return false;
      }
      
      public function contains(param1:int, param2:int) : Boolean
      {
         return param1 >= this.left && param1 < this.right && param2 >= this.front && param2 < this.back;
      }
      
      public function get right() : int
      {
         return this.loc._x + this._cached_d_right;
      }
      
      public function get back() : int
      {
         return this.loc._y + this._cached_d_back;
      }
      
      public function get left() : int
      {
         return this.loc._x + this._cached_d_left;
      }
      
      public function get front() : int
      {
         return this.loc._y + this._cached_d_front;
      }
      
      public function get posRight() : int
      {
         return this._cached_d_right;
      }
      
      public function get posBack() : int
      {
         return this._cached_d_back;
      }
      
      public function get posLeft() : int
      {
         return this._cached_d_left;
      }
      
      public function get posFront() : int
      {
         return this._cached_d_front;
      }
      
      public function toString() : String
      {
         return this.loc.toString() + " & " + this._localWidth + "x" + this._localLength + " " + this._facing;
      }
      
      public function clone() : TileRect
      {
         return new TileRect(this.loc,this._localWidth,this._localLength,this._facing);
      }
      
      public function get facing() : IAnimFacing
      {
         return this._facing;
      }
      
      public function set facing(param1:IAnimFacing) : void
      {
         if(this._facing == param1)
         {
            return;
         }
         this._facing = param1;
         this._cacheFacing();
      }
      
      private function _cacheFacing() : void
      {
         this._cached_d_right = !!this._facing ? this._facing.getRight(this._localWidth,this._localLength) : this._localWidth;
         this._cached_d_left = !!this._facing ? this._facing.getLeft(this._localWidth,this._localLength) : 0;
         this._cached_d_front = !!this._facing ? this._facing.getFront(this._localWidth,this._localLength) : 0;
         this._cached_d_back = !!this._facing ? this._facing.getBack(this._localWidth,this._localLength) : this._localLength;
         this.width = this._cached_d_right - this._cached_d_left;
         this.length = this._cached_d_back - this._cached_d_front;
         if(Boolean(this._facing) && Boolean(this.tail))
         {
            this.localTail.setTo(this._facing.deltaX * -1 * this.tail,this._facing.deltaY * -1 * this.tail);
         }
         else
         {
            this.localTail.setTo(0,0);
         }
         this._cacheCenter();
      }
      
      private function _cacheCenter() : void
      {
         var _loc1_:Number = this.diameter / 2;
         this.center.setTo(this.loc._x + _loc1_,this.loc._y + _loc1_);
         if(Boolean(this._facing) && Boolean(this.tail))
         {
            this.localCenter.setTo(_loc1_ + this.localTail.x,_loc1_ + this.localTail.y);
         }
         else
         {
            this.localCenter.setTo(_loc1_,_loc1_);
         }
      }
      
      public function toRectangle(param1:Rectangle = null) : Rectangle
      {
         if(!param1)
         {
            param1 = new Rectangle(this.left,this.front,this.width,this.length);
         }
         else
         {
            param1.setTo(this.left,this.front,this.width,this.length);
         }
         return param1;
      }
      
      public function flip(param1:TileRect = null) : TileRect
      {
         var _loc4_:TileLocation = null;
         if(param1 == this)
         {
            throw new ArgumentError("cant flip yoself");
         }
         if(!param1)
         {
            param1 = new TileRect(this.loc,this._localWidth,this._localLength,this._facing.flip);
         }
         else
         {
            param1.facing = this._facing.flip;
         }
         var _loc2_:int = param1._cached_d_left - this._cached_d_left;
         var _loc3_:int = param1._cached_d_front - this._cached_d_front;
         if(Boolean(_loc2_) || Boolean(_loc3_))
         {
            _loc4_ = TileLocation.fetch(this.loc._x - _loc2_,this.loc._y - _loc3_);
            param1.setLocation(_loc4_);
            param1._cacheFacing();
         }
         return param1;
      }
      
      public function visitAdjacentTileLocations(param1:Function, param2:*, param3:Boolean = true, param4:Boolean = false) : Boolean
      {
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc5_:int = this.left;
         var _loc6_:int = this.front;
         var _loc7_:int = this.right;
         var _loc8_:int = this.back;
         var _loc9_:Boolean = true;
         var _loc10_:Boolean = true;
         if(!param3)
         {
            if(this._localLength != this._localWidth)
            {
               if(this._facing)
               {
                  if(this._facing.deltaX)
                  {
                     _loc10_ = false;
                  }
                  else if(this._facing.deltaY)
                  {
                     _loc9_ = false;
                  }
               }
            }
         }
         if(_loc10_)
         {
            _loc11_ = _loc5_;
            _loc12_ = _loc7_;
            if(param4)
            {
               _loc11_--;
               _loc12_++;
            }
            _loc13_ = _loc11_;
            while(_loc13_ < _loc12_)
            {
               if(param1(_loc13_,_loc6_ - 1,param2))
               {
                  return true;
               }
               if(param1(_loc13_,_loc8_,param2))
               {
                  return true;
               }
               _loc13_++;
            }
         }
         if(_loc9_)
         {
            _loc14_ = _loc6_;
            _loc15_ = _loc8_;
            if(param4)
            {
               if(!_loc10_)
               {
                  _loc14_--;
                  _loc15_++;
               }
            }
            _loc16_ = _loc14_;
            while(_loc16_ < _loc15_)
            {
               if(param1(_loc5_ - 1,_loc16_,param2))
               {
                  return true;
               }
               if(param1(_loc7_,_loc16_,param2))
               {
                  return true;
               }
               _loc16_++;
            }
         }
         return false;
      }
      
      public function visitAdjacentEdgeTileLocations(param1:Function, param2:IAnimFacing, param3:*, param4:Boolean = false) : Boolean
      {
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc5_:int = this.left;
         var _loc6_:int = this.front;
         var _loc7_:int = this.right;
         var _loc8_:int = this.back;
         var _loc9_:Boolean = true;
         var _loc10_:Boolean = true;
         if(param2.deltaX != 0)
         {
            _loc15_ = _loc6_;
            _loc16_ = _loc8_;
            if(param4)
            {
               _loc15_--;
               _loc16_++;
            }
            if(param2.deltaX > 0)
            {
               _loc11_ = _loc7_;
            }
            else
            {
               _loc11_ = _loc5_ - 1;
            }
            _loc12_ = _loc15_;
            while(_loc12_ < _loc16_)
            {
               if(param1(_loc11_,_loc12_,param3))
               {
                  return true;
               }
               _loc12_++;
            }
            return false;
         }
         var _loc13_:int = _loc5_;
         var _loc14_:int = _loc7_;
         if(param4)
         {
            _loc13_--;
            _loc14_++;
         }
         if(param2.deltaY > 0)
         {
            _loc12_ = _loc8_;
         }
         else
         {
            _loc12_ = _loc6_ - 1;
         }
         _loc11_ = _loc13_;
         while(_loc11_ < _loc14_)
         {
            if(param1(_loc11_,_loc12_,param3))
            {
               return true;
            }
            _loc11_++;
         }
         return false;
      }
      
      public function visitAdjacentTileCorners(param1:Function, param2:*) : Boolean
      {
         var _loc3_:int = this.left;
         var _loc4_:int = this.front;
         var _loc5_:int = this.right;
         var _loc6_:int = this.back;
         if(param1(_loc3_ - 1,_loc4_ - 1,param2))
         {
            return true;
         }
         if(param1(_loc3_ - 1,_loc6_,param2))
         {
            return true;
         }
         if(param1(_loc5_,_loc4_ - 1,param2))
         {
            return true;
         }
         if(param1(_loc5_,_loc6_,param2))
         {
            return true;
         }
         return false;
      }
      
      public function collectEnclosedTileLocations(param1:Vector.<TileLocation>) : Boolean
      {
         var _loc7_:int = 0;
         var _loc2_:int = this.left;
         var _loc3_:int = this.front;
         var _loc4_:int = this.right;
         var _loc5_:int = this.back;
         var _loc6_:int = _loc2_;
         while(_loc6_ < _loc4_)
         {
            _loc7_ = _loc3_;
            while(_loc7_ < _loc5_)
            {
               param1.push(TileLocation.fetch(_loc6_,_loc7_));
               _loc7_++;
            }
            _loc6_++;
         }
         return false;
      }
      
      public function visitEnclosedTileLocations(param1:Function, param2:*) : Boolean
      {
         var _loc8_:int = 0;
         var _loc3_:int = this.left;
         var _loc4_:int = this.front;
         var _loc5_:int = this.right;
         var _loc6_:int = this.back;
         var _loc7_:int = _loc3_;
         while(_loc7_ < _loc5_)
         {
            _loc8_ = _loc4_;
            while(_loc8_ < _loc6_)
            {
               if(param1(_loc7_,_loc8_,param2))
               {
                  return true;
               }
               _loc8_++;
            }
            _loc7_++;
         }
         return false;
      }
      
      public function visitAdjacentTileLocationsClockwise(param1:Function, param2:*) : Boolean
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc3_:int = this.left;
         var _loc4_:int = this.front;
         var _loc5_:int = this.right;
         var _loc6_:int = this.back;
         _loc7_ = _loc3_;
         while(_loc7_ < _loc5_)
         {
            if(param1(_loc7_,_loc4_ - 1,param2))
            {
               return true;
            }
            _loc7_++;
         }
         _loc8_ = _loc4_;
         while(_loc8_ < _loc6_)
         {
            if(param1(_loc5_,_loc8_,param2))
            {
               return true;
            }
            _loc8_++;
         }
         _loc7_ = _loc5_ - 1;
         while(_loc7_ >= _loc3_)
         {
            if(param1(_loc7_,_loc6_,param2))
            {
               return true;
            }
            _loc7_--;
         }
         _loc8_ = _loc6_ - 1;
         while(_loc8_ >= _loc4_)
         {
            if(param1(_loc3_ - 1,_loc8_,param2))
            {
               return true;
            }
            _loc8_--;
         }
         return false;
      }
      
      public function testContainsPoint(param1:Number, param2:Number, param3:Boolean = false) : Boolean
      {
         param1 -= this.loc.x;
         param2 -= this.loc.y;
         if(param3)
         {
            return param1 >= 0 && param1 <= this.diameter && param2 >= 0 && param2 <= this.diameter;
         }
         return param1 >= this._cached_d_left && param1 <= this._cached_d_right && param2 >= this._cached_d_front && param2 <= this._cached_d_back;
      }
      
      public function testIntersectsRect(param1:TileRect) : Boolean
      {
         if(param1.left >= this.right)
         {
            return false;
         }
         if(param1.right <= this.left)
         {
            return false;
         }
         if(param1.front >= this.back)
         {
            return false;
         }
         if(param1.back <= this.front)
         {
            return false;
         }
         return true;
      }
      
      public function getDirectionToward(param1:TileRect, param2:Point) : Point
      {
         if(!param2)
         {
            param2 = new Point();
         }
         var _loc3_:int = this.left;
         var _loc4_:int = this.front;
         var _loc5_:int = this.right;
         var _loc6_:int = this.back;
         var _loc7_:int = param1.left;
         var _loc8_:int = param1.front;
         var _loc9_:int = param1.right;
         var _loc10_:int = param1.back;
         if(_loc10_ <= _loc4_)
         {
            param2.y = _loc10_ - _loc4_ - 1;
         }
         else if(_loc8_ >= _loc6_)
         {
            param2.y = _loc8_ - _loc6_ + 1;
         }
         if(_loc9_ <= _loc3_)
         {
            param2.x = _loc9_ - _loc3_ - 1;
         }
         else if(_loc7_ >= _loc5_)
         {
            param2.x = _loc7_ - _loc5_ + 1;
         }
         return param2;
      }
      
      public function get area() : int
      {
         return this._localLength * this._localWidth;
      }
      
      public function toSaveString() : String
      {
         return this.loc.x + " " + this.loc.y + " " + this.width + " " + this.length;
      }
      
      public function translate(param1:int, param2:int) : Boolean
      {
         if(!param1 && !param2)
         {
            return false;
         }
         this.loc = TileLocation.fetch(this.loc.x + param1,this.loc.y + param2);
         this._cacheFacing();
         return true;
      }
   }
}
