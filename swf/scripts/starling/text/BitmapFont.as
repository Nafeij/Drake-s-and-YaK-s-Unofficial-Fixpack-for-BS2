package starling.text
{
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.display.Image;
   import starling.display.QuadBatch;
   import starling.display.Sprite;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   import starling.utils.HAlign;
   import starling.utils.VAlign;
   import starling.utils.cleanMasterString;
   
   public class BitmapFont
   {
      
      public static const NATIVE_SIZE:int = -1;
      
      public static const MINI:String = "mini";
      
      private static const CHAR_SPACE:int = 32;
      
      private static const CHAR_TAB:int = 9;
      
      private static const CHAR_NEWLINE:int = 10;
      
      private static const CHAR_CARRIAGE_RETURN:int = 13;
      
      private static var sLines:Array = [];
       
      
      private var mTexture:Texture;
      
      private var mChars:Dictionary;
      
      private var mName:String;
      
      private var mSize:Number;
      
      private var mLineHeight:Number;
      
      private var mBaseline:Number;
      
      private var mOffsetX:Number;
      
      private var mOffsetY:Number;
      
      private var mHelperImage:Image;
      
      public function BitmapFont(param1:Texture = null, param2:XML = null)
      {
         super();
         if(param1 == null && param2 == null)
         {
            param1 = MiniBitmapFont.texture;
            param2 = MiniBitmapFont.xml;
         }
         else if(param1 != null && param2 == null)
         {
            throw new ArgumentError("fontXml cannot be null!");
         }
         this.mName = "unknown";
         this.mLineHeight = this.mSize = this.mBaseline = 14;
         this.mOffsetX = this.mOffsetY = 0;
         this.mTexture = param1;
         this.mChars = new Dictionary();
         this.mHelperImage = new Image(param1);
         this.parseFontXml(param2);
      }
      
      public function dispose() : void
      {
         if(this.mTexture)
         {
            this.mTexture.dispose();
         }
      }
      
      private function parseFontXml(param1:XML) : void
      {
         var _loc6_:XML = null;
         var _loc7_:XML = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Rectangle = null;
         var _loc13_:Texture = null;
         var _loc14_:BitmapChar = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:Number = NaN;
         var _loc2_:Number = this.mTexture.scale;
         var _loc3_:Rectangle = this.mTexture.frame;
         var _loc4_:Number = !!_loc3_ ? _loc3_.x : 0;
         var _loc5_:Number = !!_loc3_ ? _loc3_.y : 0;
         this.mName = cleanMasterString(param1.info.@face);
         this.mSize = parseFloat(param1.info.@size) / _loc2_;
         this.mLineHeight = parseFloat(param1.common.@lineHeight) / _loc2_;
         this.mBaseline = parseFloat(param1.common.@base) / _loc2_;
         if(param1.info.@smooth.toString() == "0")
         {
            this.smoothing = TextureSmoothing.NONE;
         }
         if(this.mSize <= 0)
         {
            this.mSize = this.mSize == 0 ? 16 : this.mSize * -1;
         }
         for each(_loc6_ in param1.chars.char)
         {
            _loc8_ = parseInt(_loc6_.@id);
            _loc9_ = parseFloat(_loc6_.@xoffset) / _loc2_;
            _loc10_ = parseFloat(_loc6_.@yoffset) / _loc2_;
            _loc11_ = parseFloat(_loc6_.@xadvance) / _loc2_;
            _loc12_ = new Rectangle();
            _loc12_.x = parseFloat(_loc6_.@x) / _loc2_ + _loc4_;
            _loc12_.y = parseFloat(_loc6_.@y) / _loc2_ + _loc5_;
            _loc12_.width = parseFloat(_loc6_.@width) / _loc2_;
            _loc12_.height = parseFloat(_loc6_.@height) / _loc2_;
            _loc13_ = Texture.fromTexture(this,this.mTexture,_loc12_);
            _loc14_ = new BitmapChar(_loc8_,_loc13_,_loc9_,_loc10_,_loc11_);
            this.addChar(_loc8_,_loc14_);
         }
         for each(_loc7_ in param1.kernings.kerning)
         {
            _loc15_ = parseInt(_loc7_.@first);
            _loc16_ = parseInt(_loc7_.@second);
            _loc17_ = parseFloat(_loc7_.@amount) / _loc2_;
            if(_loc16_ in this.mChars)
            {
               this.getChar(_loc16_).addKerning(_loc15_,_loc17_);
            }
         }
      }
      
      public function getChar(param1:int) : BitmapChar
      {
         return this.mChars[param1];
      }
      
      public function addChar(param1:int, param2:BitmapChar) : void
      {
         this.mChars[param1] = param2;
      }
      
      public function getCharIDs(param1:Vector.<int> = null) : Vector.<int>
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            param1 = new Vector.<int>(0);
         }
         for(_loc2_ in this.mChars)
         {
            param1[param1.length] = int(_loc2_);
         }
         return param1;
      }
      
      public function hasChars(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         if(param1 == null)
         {
            return true;
         }
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = param1.charCodeAt(_loc4_);
            if(_loc2_ != CHAR_SPACE && _loc2_ != CHAR_TAB && _loc2_ != CHAR_NEWLINE && _loc2_ != CHAR_CARRIAGE_RETURN && this.getChar(_loc2_) == null)
            {
               return false;
            }
            _loc4_++;
         }
         return true;
      }
      
      public function createSprite(param1:Number, param2:Number, param3:String, param4:Number = -1, param5:uint = 16777215, param6:String = "center", param7:String = "center", param8:Boolean = true, param9:Boolean = true) : Sprite
      {
         var _loc14_:CharLocation = null;
         var _loc15_:Image = null;
         var _loc10_:Vector.<CharLocation> = this.arrangeChars(param1,param2,param3,param4,param6,param7,param8,param9);
         var _loc11_:int = int(_loc10_.length);
         var _loc12_:Sprite = new Sprite();
         var _loc13_:int = 0;
         while(_loc13_ < _loc11_)
         {
            _loc14_ = _loc10_[_loc13_];
            _loc15_ = _loc14_.char.createImage();
            _loc15_.x = _loc14_.x;
            _loc15_.y = _loc14_.y;
            _loc15_.scaleX = _loc15_.scaleY = _loc14_.scale;
            _loc15_.color = param5;
            _loc12_.addChild(_loc15_);
            _loc13_++;
         }
         CharLocation.rechargePool();
         return _loc12_;
      }
      
      public function fillQuadBatch(param1:QuadBatch, param2:Number, param3:Number, param4:String, param5:Number = -1, param6:uint = 16777215, param7:String = "center", param8:String = "center", param9:Boolean = true, param10:Boolean = true, param11:Number = 0) : void
      {
         var _loc15_:CharLocation = null;
         var _loc12_:Vector.<CharLocation> = this.arrangeChars(param2,param3,param4,param5,param7,param8,param9,param10,param11);
         var _loc13_:int = int(_loc12_.length);
         this.mHelperImage.color = param6;
         var _loc14_:int = 0;
         while(_loc14_ < _loc13_)
         {
            _loc15_ = _loc12_[_loc14_];
            this.mHelperImage.texture = _loc15_.char.texture;
            this.mHelperImage.readjustSize();
            this.mHelperImage.x = _loc15_.x;
            this.mHelperImage.y = _loc15_.y;
            this.mHelperImage.scaleX = this.mHelperImage.scaleY = _loc15_.scale;
            param1.addImage(this.mHelperImage);
            _loc14_++;
         }
         CharLocation.rechargePool();
      }
      
      private function arrangeChars(param1:Number, param2:Number, param3:String, param4:Number = -1, param5:String = "center", param6:String = "center", param7:Boolean = true, param8:Boolean = true, param9:Number = 0) : Vector.<CharLocation>
      {
         var _loc11_:CharLocation = null;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Vector.<CharLocation> = null;
         var _loc26_:int = 0;
         var _loc27_:Boolean = false;
         var _loc28_:int = 0;
         var _loc29_:BitmapChar = null;
         var _loc30_:int = 0;
         var _loc31_:int = 0;
         var _loc32_:Vector.<CharLocation> = null;
         var _loc33_:int = 0;
         var _loc34_:CharLocation = null;
         var _loc35_:Number = NaN;
         var _loc36_:int = 0;
         if(param3 == null || param3.length == 0)
         {
            return CharLocation.vectorFromPool();
         }
         if(param4 < 0)
         {
            param4 *= -this.mSize;
         }
         var _loc10_:Boolean = false;
         while(!_loc10_)
         {
            sLines.length = 0;
            _loc15_ = param4 / this.mSize;
            _loc13_ = param1 / _loc15_;
            _loc14_ = param2 / _loc15_;
            if(this.mLineHeight <= _loc14_)
            {
               _loc21_ = -1;
               _loc22_ = -1;
               _loc23_ = 0;
               _loc24_ = 0;
               _loc25_ = CharLocation.vectorFromPool();
               _loc12_ = param3.length;
               _loc26_ = 0;
               while(_loc26_ < _loc12_)
               {
                  _loc27_ = false;
                  _loc28_ = param3.charCodeAt(_loc26_);
                  _loc29_ = this.getChar(_loc28_);
                  if(_loc28_ == CHAR_NEWLINE || _loc28_ == CHAR_CARRIAGE_RETURN)
                  {
                     _loc27_ = true;
                  }
                  else if(_loc29_ != null)
                  {
                     if(_loc28_ == CHAR_SPACE || _loc28_ == CHAR_TAB)
                     {
                        _loc21_ = _loc26_;
                     }
                     if(param8)
                     {
                        _loc23_ += _loc29_.getKerning(_loc22_);
                     }
                     _loc11_ = CharLocation.instanceFromPool(_loc29_);
                     _loc11_.x = _loc23_ + _loc29_.xOffset;
                     _loc11_.y = _loc24_ + _loc29_.yOffset;
                     _loc25_[_loc25_.length] = _loc11_;
                     _loc23_ += _loc29_.xAdvance;
                     _loc22_ = _loc28_;
                     if(_loc11_.x + _loc29_.width > _loc13_)
                     {
                        if(param7 && _loc21_ == -1)
                        {
                           break;
                        }
                        _loc30_ = _loc21_ == -1 ? 1 : _loc26_ - _loc21_;
                        _loc31_ = _loc25_.length - _loc30_;
                        _loc25_.splice(_loc31_,_loc30_);
                        if(_loc25_.length == 0)
                        {
                           break;
                        }
                        _loc26_ -= _loc30_;
                        _loc27_ = true;
                     }
                  }
                  if(_loc26_ == _loc12_ - 1)
                  {
                     sLines[sLines.length] = _loc25_;
                     _loc10_ = true;
                  }
                  else if(_loc27_)
                  {
                     sLines[sLines.length] = _loc25_;
                     if(_loc21_ == _loc26_)
                     {
                        _loc25_.pop();
                     }
                     if(_loc24_ + param9 + 2 * this.mLineHeight > _loc14_)
                     {
                        break;
                     }
                     _loc25_ = CharLocation.vectorFromPool();
                     _loc23_ = 0;
                     _loc24_ += this.mLineHeight + param9;
                     _loc21_ = -1;
                     _loc22_ = -1;
                  }
                  _loc26_++;
               }
            }
            if(param7 && !_loc10_ && param4 > 3)
            {
               param4--;
            }
            else
            {
               _loc10_ = true;
            }
         }
         var _loc16_:Vector.<CharLocation> = CharLocation.vectorFromPool();
         var _loc17_:int = int(sLines.length);
         var _loc18_:Number = _loc24_ + this.mLineHeight;
         var _loc19_:int = 0;
         if(param6 == VAlign.BOTTOM)
         {
            _loc19_ = _loc14_ - _loc18_;
         }
         else if(param6 == VAlign.CENTER)
         {
            _loc19_ = (_loc14_ - _loc18_) / 2;
         }
         var _loc20_:int = 0;
         while(_loc20_ < _loc17_)
         {
            _loc32_ = sLines[_loc20_];
            _loc12_ = int(_loc32_.length);
            if(_loc12_ != 0)
            {
               _loc33_ = 0;
               _loc34_ = _loc32_[_loc32_.length - 1];
               _loc35_ = _loc34_.x - _loc34_.char.xOffset + _loc34_.char.xAdvance;
               if(param5 == HAlign.RIGHT)
               {
                  _loc33_ = _loc13_ - _loc35_;
               }
               else if(param5 == HAlign.CENTER)
               {
                  _loc33_ = (_loc13_ - _loc35_) / 2;
               }
               _loc36_ = 0;
               while(_loc36_ < _loc12_)
               {
                  _loc11_ = _loc32_[_loc36_];
                  _loc11_.x = _loc15_ * (_loc11_.x + _loc33_ + this.mOffsetX);
                  _loc11_.y = _loc15_ * (_loc11_.y + _loc19_ + this.mOffsetY);
                  _loc11_.scale = _loc15_;
                  if(_loc11_.char.width > 0 && _loc11_.char.height > 0)
                  {
                     _loc16_[_loc16_.length] = _loc11_;
                  }
                  _loc36_++;
               }
            }
            _loc20_++;
         }
         return _loc16_;
      }
      
      public function get name() : String
      {
         return this.mName;
      }
      
      public function get size() : Number
      {
         return this.mSize;
      }
      
      public function get lineHeight() : Number
      {
         return this.mLineHeight;
      }
      
      public function set lineHeight(param1:Number) : void
      {
         this.mLineHeight = param1;
      }
      
      public function get smoothing() : String
      {
         return this.mHelperImage.smoothing;
      }
      
      public function set smoothing(param1:String) : void
      {
         this.mHelperImage.smoothing = param1;
      }
      
      public function get baseline() : Number
      {
         return this.mBaseline;
      }
      
      public function set baseline(param1:Number) : void
      {
         this.mBaseline = param1;
      }
      
      public function get offsetX() : Number
      {
         return this.mOffsetX;
      }
      
      public function set offsetX(param1:Number) : void
      {
         this.mOffsetX = param1;
      }
      
      public function get offsetY() : Number
      {
         return this.mOffsetY;
      }
      
      public function set offsetY(param1:Number) : void
      {
         this.mOffsetY = param1;
      }
      
      public function get texture() : Texture
      {
         return this.mTexture;
      }
   }
}

import starling.text.BitmapChar;

class CharLocation
{
   
   private static var sInstancePool:Vector.<CharLocation> = new Vector.<CharLocation>(0);
   
   private static var sVectorPool:Array = [];
   
   private static var sInstanceLoan:Vector.<CharLocation> = new Vector.<CharLocation>(0);
   
   private static var sVectorLoan:Array = [];
    
   
   public var char:BitmapChar;
   
   public var scale:Number;
   
   public var x:Number;
   
   public var y:Number;
   
   public function CharLocation(param1:BitmapChar)
   {
      super();
      this.reset(param1);
   }
   
   public static function instanceFromPool(param1:BitmapChar) : CharLocation
   {
      var _loc2_:CharLocation = sInstancePool.length > 0 ? sInstancePool.pop() : new CharLocation(param1);
      _loc2_.reset(param1);
      sInstanceLoan[sInstanceLoan.length] = _loc2_;
      return _loc2_;
   }
   
   public static function vectorFromPool() : Vector.<CharLocation>
   {
      var _loc1_:Vector.<CharLocation> = sVectorPool.length > 0 ? sVectorPool.pop() : new Vector.<CharLocation>(0);
      _loc1_.length = 0;
      sVectorLoan[sVectorLoan.length] = _loc1_;
      return _loc1_;
   }
   
   public static function rechargePool() : void
   {
      var _loc1_:CharLocation = null;
      var _loc2_:Vector.<CharLocation> = null;
      while(sInstanceLoan.length > 0)
      {
         _loc1_ = sInstanceLoan.pop();
         _loc1_.char = null;
         sInstancePool[sInstancePool.length] = _loc1_;
      }
      while(sVectorLoan.length > 0)
      {
         _loc2_ = sVectorLoan.pop();
         _loc2_.length = 0;
         sVectorPool[sVectorPool.length] = _loc2_;
      }
   }
   
   private function reset(param1:BitmapChar) : CharLocation
   {
      this.char = param1;
      return this;
   }
}
