package engine.anim.def
{
   import engine.core.logging.ILogger;
   import engine.core.logging.Logger;
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class AnimFrames
   {
       
      
      public var _frames:Vector.<AnimFrame>;
      
      public var top:Number = 0;
      
      public var bottom:Number = 0;
      
      public var left:Number = 0;
      
      public var right:Number = 0;
      
      private var _eventsByFrame:Dictionary;
      
      private var _events:Vector.<IAnimEventDef>;
      
      private var _maxFrameSize:Point;
      
      public var children:Vector.<AnimClipChildDef>;
      
      public var clipurl:String;
      
      public var locomotive:Boolean;
      
      public var locomotiveTilesTotal:Number = 0;
      
      public var isMaster:Boolean;
      
      public var isPortrait:Boolean;
      
      public var logger:ILogger;
      
      private var _cachedChildBounds:Boolean;
      
      public function AnimFrames(param1:AnimClipDef, param2:ILogger)
      {
         this._maxFrameSize = new Point();
         super();
         this.clipurl = !!param1 ? param1.url : null;
         this.logger = param2;
      }
      
      public function get frames() : Vector.<AnimFrame>
      {
         return this._frames;
      }
      
      public function get height() : Number
      {
         return this.bottom - this.top;
      }
      
      public function get width() : Number
      {
         return this.right - this.left;
      }
      
      public function addEvent(param1:IAnimEventDef) : void
      {
         var _loc2_:Vector.<IAnimEventDef> = null;
         if(this._eventsByFrame)
         {
            _loc2_ = this._eventsByFrame[param1.frameNumber];
         }
         else
         {
            this._eventsByFrame = new Dictionary();
            this._events = new Vector.<IAnimEventDef>();
         }
         if(!_loc2_)
         {
            _loc2_ = new Vector.<IAnimEventDef>();
            this._eventsByFrame[param1.frameNumber] = _loc2_;
         }
         _loc2_.push(param1);
         this._events.push(param1);
      }
      
      public function hasFrameEvents(param1:int) : Boolean
      {
         var _loc2_:Vector.<IAnimEventDef> = !!this._eventsByFrame ? this._eventsByFrame[param1] : null;
         return Boolean(_loc2_) && Boolean(_loc2_.length);
      }
      
      public function getFrameEvents(param1:int) : Vector.<IAnimEventDef>
      {
         return !!this._eventsByFrame ? this._eventsByFrame[param1] : null;
      }
      
      public function get events() : Vector.<IAnimEventDef>
      {
         return this._events;
      }
      
      public function get numEvents() : int
      {
         return !!this._events ? int(this._events.length) : 0;
      }
      
      public function cleanup() : void
      {
         var _loc1_:int = 0;
         var _loc2_:AnimFrame = null;
         if(this._frames)
         {
            _loc1_ = 0;
            while(_loc1_ < this._frames.length)
            {
               _loc2_ = this._frames[_loc1_];
               if(_loc2_)
               {
                  _loc2_.cleanup();
               }
               _loc1_++;
            }
            this._frames = null;
         }
         this._eventsByFrame = null;
         this._events = null;
      }
      
      public function isSpriteSheeted() : Boolean
      {
         return this._frames != null;
      }
      
      public function getFrame(param1:int) : AnimFrame
      {
         if(param1 < 0 || !this._frames || param1 >= this._frames.length)
         {
            return null;
         }
         return this._frames[param1];
      }
      
      public function toString() : String
      {
         return this.clipurl;
      }
      
      public function get maxFrameSize() : Point
      {
         return this._maxFrameSize;
      }
      
      public function get numChildren() : int
      {
         return !!this.children ? int(this.children.length) : 0;
      }
      
      public function getClipChild(param1:int) : AnimClipChildDef
      {
         return !!this.children ? this.children[param1] : null;
      }
      
      public function getClipChildByName(param1:String) : AnimClipChildDef
      {
         var _loc2_:AnimClipChildDef = null;
         if(this.children)
         {
            for each(_loc2_ in this.children)
            {
               if(_loc2_.name == param1)
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      public function generateVideoFrames() : Array
      {
         var _loc5_:BitmapData = null;
         var _loc6_:AnimFrame = null;
         var _loc7_:BitmapData = null;
         var _loc8_:Matrix = null;
         var _loc9_:Point = null;
         var _loc10_:Rectangle = null;
         if(!this._frames)
         {
            return null;
         }
         var _loc1_:int = this.right - this.left;
         var _loc2_:int = this.bottom - this.top;
         if(_loc1_ == 0 || _loc2_ == 0)
         {
            return null;
         }
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < this._frames.length)
         {
            _loc5_ = new BitmapData(_loc1_,_loc2_,true,0);
            _loc3_.push(_loc5_);
            _loc6_ = this._frames[_loc4_];
            if(_loc6_)
            {
               _loc7_ = _loc6_.addFrameReferenceBmpd();
               if(!_loc7_)
               {
                  _loc6_.releaseFrameReferenceBmpd();
               }
               else
               {
                  _loc8_ = new Matrix();
                  if(_loc6_.offset)
                  {
                     _loc8_.translate(_loc6_.offset.x,_loc6_.offset.y);
                  }
                  _loc9_ = !!_loc6_.offset ? _loc6_.offset.clone() : new Point();
                  _loc9_.x -= this.left;
                  _loc9_.y -= this.top;
                  _loc10_ = new Rectangle(0,0,_loc7_.width,_loc7_.height);
                  _loc5_.copyPixels(_loc7_,_loc10_,_loc9_,null,null,true);
                  _loc6_.releaseFrameReferenceBmpd();
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function setFrame(param1:int, param2:AnimFrame) : void
      {
         this.frames[param1] = param2;
         if(!param2)
         {
            return;
         }
         this.locomotiveTilesTotal = Math.max(param2.locomotiveTiles,this.locomotiveTilesTotal);
         if(!param2.bound)
         {
            return;
         }
         this.top = Math.min(param2.bound.top,this.top);
         this.left = Math.min(param2.bound.left,this.left);
         this.bottom = Math.max(param2.bound.bottom,this.bottom);
         this.right = Math.max(param2.bound.right,this.right);
      }
      
      public function cacheChildBounds() : void
      {
         var _loc2_:AnimFrame = null;
         var _loc3_:Point = null;
         var _loc4_:AnimFrameChild = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:AnimClipChildDef = null;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(this._cachedChildBounds)
         {
            return;
         }
         this._cachedChildBounds = true;
         var _loc1_:int = 0;
         while(_loc1_ < this.frames.length)
         {
            _loc2_ = this.frames[_loc1_];
            if(!_loc2_ || !_loc2_.bound)
            {
               return;
            }
            _loc3_ = new Point();
            for each(_loc4_ in _loc2_.children)
            {
               if(_loc4_ && _loc4_.childIndex >= 0 && _loc4_.visible)
               {
                  _loc5_ = _loc4_.rotation * Math.PI / 180;
                  _loc6_ = Math.cos(_loc5_);
                  _loc7_ = Math.sin(_loc5_);
                  _loc8_ = this.children[_loc4_.childIndex];
                  if(Boolean(_loc8_.clip) && Boolean(_loc8_.clip._aframes))
                  {
                     _loc9_ = 0;
                     while(_loc9_ < 4)
                     {
                        _loc8_.clip._aframes.getBoundsCorner(_loc9_,_loc3_);
                        if(_loc4_.scale)
                        {
                           _loc3_.x *= _loc4_.scale.x;
                           _loc3_.y *= _loc4_.scale.y;
                        }
                        _loc10_ = _loc3_.x * _loc6_ - _loc3_.y * _loc7_;
                        _loc11_ = _loc3_.x * _loc7_ + _loc3_.y * _loc6_;
                        if(_loc4_.position)
                        {
                           _loc10_ += _loc4_.position.x;
                           _loc11_ += _loc4_.position.y;
                        }
                        this.top = Math.min(_loc11_,this.top);
                        this.left = Math.min(_loc10_,this.left);
                        this.bottom = Math.max(_loc11_,this.bottom);
                        this.right = Math.max(_loc10_,this.right);
                        _loc9_++;
                     }
                  }
               }
            }
            _loc1_++;
         }
      }
      
      public function get numBytes() : int
      {
         var _loc3_:AnimFrame = null;
         var _loc4_:int = 0;
         var _loc5_:IAnimEventDef = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._frames.length)
         {
            _loc3_ = this._frames[_loc2_];
            if(_loc3_.frameNum == _loc2_)
            {
               _loc1_ += _loc3_.numBytes;
            }
            _loc2_++;
         }
         if(this._events)
         {
            _loc1_ += this._events.length * 4;
            _loc4_ = 0;
            while(_loc4_ < this._events.length)
            {
               _loc5_ = this._events[_loc4_];
               if(_loc5_)
               {
                  _loc1_ += 8;
                  _loc1_ += _loc5_.numBytes;
               }
               _loc4_++;
            }
         }
         return _loc1_;
      }
      
      public function computeUniqueBmpds() : int
      {
         var _loc3_:AnimFrame = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.frames.length)
         {
            _loc3_ = this.frames[_loc2_];
            if(_loc3_.frameNum == _loc2_)
            {
               if(_loc3_.origBmpdNum >= 0)
               {
                  _loc1_ = Math.max(_loc3_.origBmpdNum + 1,_loc1_);
               }
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function computeUniqueFrames() : int
      {
         var _loc3_:AnimFrame = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.frames.length)
         {
            _loc3_ = this.frames[_loc2_];
            if(_loc3_.frameNum == _loc2_)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function readBytes(param1:ByteArray, param2:int) : void
      {
         var _loc9_:int = 0;
         var _loc10_:AnimEventDef = null;
         var _loc11_:int = 0;
         var _loc12_:AnimClipChildDef = null;
         var _loc13_:int = 0;
         var _loc14_:AnimFrame = null;
         var _loc15_:AnimFrame = null;
         var _loc3_:uint = param1.readUnsignedByte();
         var _loc4_:* = 0 != (_loc3_ & 1);
         var _loc5_:* = 0 != (_loc3_ & 2);
         this.locomotive = 0 != (_loc3_ & 4);
         if(this.locomotive)
         {
            this.locomotiveTilesTotal = param1.readFloat();
         }
         var _loc6_:int = 0;
         if(_loc4_)
         {
            _loc9_ = int(param1.readUnsignedByte());
            _loc6_ = 0;
            while(_loc6_ < _loc9_)
            {
               _loc10_ = new AnimEventDef();
               _loc10_.readBytes(param1);
               this.addEvent(_loc10_);
               _loc6_++;
            }
         }
         if(_loc5_)
         {
            _loc11_ = int(param1.readUnsignedByte());
            this.children = new Vector.<AnimClipChildDef>(_loc11_);
            _loc6_ = 0;
            while(_loc6_ < _loc11_)
            {
               _loc12_ = new AnimClipChildDef();
               _loc12_.readBytes(param1);
               this.children[_loc6_] = _loc12_;
               _loc6_++;
            }
         }
         var _loc7_:int = !!this.children ? int(this.children.length) : 0;
         var _loc8_:int = int(param1.readUnsignedShort());
         if(_loc8_)
         {
            this._frames = new Vector.<AnimFrame>(_loc8_);
            _loc13_ = 0;
            _loc6_ = 0;
            while(_loc6_ < _loc8_)
            {
               _loc14_ = new AnimFrame(this,this.logger);
               _loc14_.readBytes(param1,Logger.instance,_loc13_,_loc7_,param2);
               this.setFrame(_loc6_,_loc14_);
               _loc13_++;
               _loc6_++;
            }
         }
         if(this._frames)
         {
            _loc13_ = 0;
            while(_loc13_ < this._frames.length)
            {
               _loc14_ = this._frames[_loc13_];
               if(_loc14_.frameNum < 0)
               {
                  _loc14_.frameNum = _loc13_;
                  this.setFrame(_loc13_,_loc14_);
                  if(_loc14_.shared)
                  {
                     _loc15_ = this.getFrame(_loc14_.sharedFrom);
                     if(!_loc15_)
                     {
                        throw new ArgumentError("AnimFrames [" + this.clipurl + "] frame " + _loc13_ + " shared from " + _loc14_.sharedFrom + " not found ");
                     }
                     _loc14_.origBmpdNum = _loc15_.origBmpdNum;
                  }
               }
               else if(_loc14_.frameNum != _loc13_)
               {
                  if(_loc14_.frameNum >= this._frames.length)
                  {
                     Logger.instance.error("AnimFrames [" + this.clipurl + "] INVALID frame " + _loc13_);
                     _loc14_.frameNum;
                  }
                  this._frames[_loc13_] = this._frames[_loc14_.frameNum];
               }
               _loc13_++;
            }
         }
      }
      
      public function writeBytes(param1:ByteArray, param2:int) : void
      {
         var _loc5_:AnimEventDef = null;
         var _loc6_:AnimClipChildDef = null;
         var _loc7_:AnimFrame = null;
         var _loc3_:uint = 0;
         _loc3_ |= Boolean(this.events) && Boolean(this.events.length) ? 1 : 0;
         _loc3_ |= Boolean(this.children) && Boolean(this.children.length) ? 2 : 0;
         _loc3_ |= this.locomotive ? 4 : 0;
         param1.writeByte(_loc3_);
         if(this.locomotive)
         {
            param1.writeFloat(this.locomotiveTilesTotal);
         }
         var _loc4_:int = 0;
         if(Boolean(this._events) && Boolean(this._events.length))
         {
            if(this._events.length >= 255)
            {
               throw new ArgumentError("Too many anim events: " + this._events.length);
            }
            param1.writeByte(this._events.length);
            _loc4_ = 0;
            while(_loc4_ < this._events.length)
            {
               _loc5_ = this._events[_loc4_] as AnimEventDef;
               _loc5_.writeBytes(param1);
               _loc4_++;
            }
         }
         if(Boolean(this.children) && Boolean(this.children.length))
         {
            if(this.children.length >= 255)
            {
               throw new ArgumentError("Too many children: " + this.children.length);
            }
            param1.writeByte(this.children.length);
            _loc4_ = 0;
            while(_loc4_ < this.children.length)
            {
               _loc6_ = this.children[_loc4_];
               _loc6_.writeBytes(param1);
               _loc4_++;
            }
         }
         if(Boolean(this._frames) && this._frames.length > 65535)
         {
            throw new ArgumentError("Too many frames: " + this._frames.length);
         }
         param1.writeShort(!!this._frames ? int(this._frames.length) : 0);
         if(this._frames)
         {
            _loc4_ = 0;
            while(_loc4_ < this._frames.length)
            {
               _loc7_ = this._frames[_loc4_];
               _loc7_.writeBytes(param1,_loc4_,Logger.instance,param2);
               _loc4_++;
            }
         }
      }
      
      public function getBoundsCorner(param1:int, param2:Point) : Point
      {
         if(!param2)
         {
            param2 = new Point();
         }
         switch(param1)
         {
            case 0:
               param2.setTo(this.left,this.top);
               break;
            case 1:
               param2.setTo(this.right,this.top);
               break;
            case 2:
               param2.setTo(this.right,this.bottom);
               break;
            case 3:
               param2.setTo(this.left,this.bottom);
         }
         return param2;
      }
   }
}
