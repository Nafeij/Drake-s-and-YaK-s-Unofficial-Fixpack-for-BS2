package engine.landscape.def
{
   import flash.display.BitmapData;
   import flash.utils.ByteArray;
   
   public class ClickMask
   {
       
      
      public var mask:ByteArray;
      
      public var width:int;
      
      public var height:int;
      
      public var x:int;
      
      public var y:int;
      
      public function ClickMask()
      {
         super();
      }
      
      private static function _createBmpdHitMask(param1:BitmapData) : ByteArray
      {
         var _loc7_:int = 0;
         var _loc8_:uint = 0;
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:uint = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < param1.height)
         {
            _loc7_ = 0;
            while(_loc7_ < param1.width)
            {
               _loc8_ = param1.getPixel32(_loc7_,_loc5_);
               if((_loc8_ & 4278190080) != 0)
               {
                  _loc3_ |= 1 << _loc4_;
               }
               _loc4_++;
               if(_loc4_ >= 8)
               {
                  _loc2_.writeByte(_loc3_);
                  _loc3_ = 0;
                  _loc4_ = 0;
               }
               _loc7_++;
            }
            _loc5_++;
         }
         if(_loc4_ > 0)
         {
            _loc2_.writeByte(_loc3_);
         }
         var _loc6_:int = Math.ceil(param1.height * param1.width / 8);
         if(_loc2_.length != _loc6_)
         {
            throw new Error("illegal mask creation");
         }
         _loc2_.position = 0;
         return _loc2_;
      }
      
      private static function _createUnionHitMask(param1:int, param2:int, param3:int, param4:int, param5:Vector.<ClickMask>) : ByteArray
      {
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:ClickMask = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc6_:ByteArray = new ByteArray();
         var _loc7_:uint = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         while(_loc9_ < param4)
         {
            _loc11_ = param2 + _loc9_;
            _loc12_ = 0;
            while(_loc12_ < param3)
            {
               _loc13_ = param1 + _loc12_;
               for each(_loc14_ in param5)
               {
                  _loc15_ = _loc11_ - _loc14_.y;
                  _loc16_ = _loc13_ - _loc14_.x;
                  if(_loc14_.testClickMask(_loc16_,_loc15_))
                  {
                     _loc7_ |= 1 << _loc8_;
                     break;
                  }
               }
               _loc8_++;
               if(_loc8_ >= 8)
               {
                  _loc6_.writeByte(_loc7_);
                  _loc7_ = 0;
                  _loc8_ = 0;
               }
               _loc12_++;
            }
            _loc9_++;
         }
         if(_loc8_ > 0)
         {
            _loc6_.writeByte(_loc7_);
         }
         var _loc10_:int = Math.ceil(param4 * param3 / 8);
         if(_loc6_.length != _loc10_)
         {
            throw new Error("illegal mask creation");
         }
         _loc6_.position = 0;
         return _loc6_;
      }
      
      public function fromBitmapData(param1:BitmapData) : ClickMask
      {
         if(param1)
         {
            this.width = param1.width;
            this.height = param1.height;
            this.mask = _createBmpdHitMask(param1);
         }
         return this;
      }
      
      public function toString() : String
      {
         return "@" + this.x + "," + this.y + " : " + this.width + "x" + this.height;
      }
      
      public function union(param1:Vector.<ClickMask>) : ClickMask
      {
         var _loc6_:ClickMask = null;
         var _loc2_:int = 100000;
         var _loc3_:int = -100000;
         var _loc4_:int = 100000;
         var _loc5_:int = -100000;
         for each(_loc6_ in param1)
         {
            _loc2_ = Math.min(_loc6_.x,_loc2_);
            _loc4_ = Math.min(_loc6_.y,_loc4_);
            _loc3_ = Math.max(_loc6_.x + _loc6_.width,_loc3_);
            _loc5_ = Math.max(_loc6_.y + _loc6_.height,_loc5_);
         }
         this.x = _loc2_;
         this.y = _loc4_;
         this.width = _loc3_ - _loc2_;
         this.height = _loc5_ - _loc4_;
         this.mask = _createUnionHitMask(this.x,this.y,this.width,this.height,param1);
         return this;
      }
      
      public function writeData(param1:ByteArray) : void
      {
         param1.writeInt(this.x);
         param1.writeInt(this.y);
         param1.writeInt(this.width);
         param1.writeInt(this.height);
         this.mask.position = 0;
         param1.writeBytes(this.mask);
      }
      
      public function readData(param1:ByteArray) : ClickMask
      {
         this.x = param1.readInt();
         this.y = param1.readInt();
         this.width = param1.readInt();
         this.height = param1.readInt();
         var _loc2_:int = Math.ceil(this.width * this.height / 8);
         this.mask = new ByteArray();
         param1.readBytes(this.mask,0,_loc2_);
         return this;
      }
      
      public function cleanup() : void
      {
         if(this.mask)
         {
            this.mask.clear();
            this.mask = null;
         }
      }
      
      public function clone() : ClickMask
      {
         var _loc1_:ClickMask = new ClickMask();
         _loc1_.mask = new ByteArray();
         _loc1_.mask.readBytes(this.mask);
         _loc1_.width = this.width;
         _loc1_.height = this.height;
         return _loc1_;
      }
      
      public function testClickMask(param1:int, param2:int) : Boolean
      {
         if(!this.mask)
         {
            return false;
         }
         if(param1 < 0 || param1 >= this.width || param2 < 0 || param2 >= this.height)
         {
            return false;
         }
         var _loc3_:int = param2 * this.width + param1;
         var _loc4_:int = _loc3_ / 8;
         var _loc5_:int = _loc3_ % 8;
         if(_loc4_ >= this.mask.length)
         {
            throw new Error("illegal clickMask access");
         }
         this.mask.position = _loc4_;
         var _loc6_:uint = this.mask.readUnsignedByte();
         return (_loc6_ & 1 << _loc5_) != 0;
      }
      
      public function testClickMaskContains(param1:ClickMask, param2:int, param3:int, param4:ClickMaskTestResult) : void
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         param4.reset();
         if(!this.mask || !param1.mask)
         {
            param4.nomask = true;
            return;
         }
         if(param2 > this.width || param2 + param1.width < 0 || param3 > this.height || param3 + param1.height < 0)
         {
            param4.outside = true;
            return;
         }
         if(param2 < 0 || param2 + param1.width > this.width || param3 < 0 || param3 + param1.height > this.height)
         {
         }
         var _loc5_:int = param2;
         var _loc6_:int = param2 + param1.width;
         var _loc7_:int = param3;
         var _loc8_:int = param3 + param1.height;
         var _loc9_:int = _loc5_;
         while(_loc9_ < _loc6_)
         {
            _loc10_ = _loc7_;
            while(_loc10_ < _loc8_)
            {
               _loc11_ = _loc9_ - param2;
               _loc12_ = _loc10_ - param3;
               if(param1.testClickMask(_loc11_,_loc12_))
               {
                  if(!this.testClickMask(_loc9_,_loc10_))
                  {
                     if(param4.partial)
                     {
                        return;
                     }
                  }
                  else
                  {
                     param4.partial = true;
                  }
               }
               _loc10_++;
            }
            _loc9_++;
         }
         if(param4.partial)
         {
            param4.partial = false;
            param4.complete = true;
         }
         else
         {
            param4.outside = true;
         }
      }
   }
}
