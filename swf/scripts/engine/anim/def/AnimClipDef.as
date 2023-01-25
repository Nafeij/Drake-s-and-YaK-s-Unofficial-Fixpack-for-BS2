package engine.anim.def
{
   import com.stoicstudio.platform.Platform;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import flash.utils.ByteArray;
   
   public class AnimClipDef implements IAnimClipDef
   {
      
      public static var playbackMod:Number = 1;
      
      public static var oo_playbackMod:Number = 1;
      
      private static const INSTANCE_BYTES:int = 18 * 4;
      
      public static var REQUIRE_PNG:Boolean;
       
      
      public var _id:String;
      
      public var _url:String;
      
      public var _offsetY:Number = 0;
      
      public var _offsetX:Number = 0;
      
      public var _looping:Boolean;
      
      public var _scale:Number = 1;
      
      public var _durationMs:int;
      
      public var _numFrames:int;
      
      public var _fps:int;
      
      public var _aframes:AnimFrames;
      
      public var _highQuality:Boolean;
      
      public var hasSheet:Boolean;
      
      public var pngEncoded:Boolean;
      
      public var generateFramesSkip:int;
      
      public var shrunkenScale:Number = 1;
      
      public var locomotiveTilesTotal:Number = 0;
      
      private var logger:ILogger;
      
      private var pngLoaderWaits:int = 0;
      
      private var pngLoaderWaiting:Boolean;
      
      public var consumptionCompleteCallback:Function;
      
      public var consumptionComplete:Boolean;
      
      private var useCompression:Boolean;
      
      public function AnimClipDef(param1:ILogger)
      {
         super();
         this.logger = param1;
      }
      
      public static function setPlaybackMod(param1:Number) : void
      {
         playbackMod = param1;
         oo_playbackMod = 1 / param1;
      }
      
      public function get numBytes() : int
      {
         var _loc1_:int = INSTANCE_BYTES;
         _loc1_ += !!this._id ? this._id.length : 0;
         _loc1_ += !!this._url ? this._url.length : 0;
         if(this._aframes)
         {
            _loc1_ += this._aframes.numBytes;
         }
         return _loc1_;
      }
      
      public function get aframes() : AnimFrames
      {
         return this._aframes;
      }
      
      public function get scale() : Number
      {
         return this._scale;
      }
      
      public function consumeSheet(param1:ByteArray, param2:int, param3:ILogger, param4:Boolean, param5:Boolean, param6:Function) : void
      {
         var _loc10_:int = 0;
         var _loc11_:AnimFrame = null;
         var _loc12_:AnimFrame = null;
         this.consumptionComplete = false;
         var _loc7_:Number = 1;
         var _loc8_:Number = 1;
         var _loc9_:int = param2;
         if(REQUIRE_PNG && !this.pngEncoded)
         {
            throw new ArgumentError("PNG Anims required");
         }
         if(Boolean(this._aframes) && Boolean(this._aframes.frames))
         {
            _loc10_ = 0;
            while(_loc10_ < this._aframes.frames.length)
            {
               _loc11_ = this._aframes.frames[_loc10_];
               if(!_loc11_.hasConsumedSheet && _loc11_.frameNum == _loc10_)
               {
                  if(!_loc11_.shared)
                  {
                     if(this.pngEncoded)
                     {
                        ++this.pngLoaderWaits;
                     }
                     _loc11_.consumeSheet(param1,param2,_loc7_,_loc8_,param4,this.pngEncoded,param5,this.pngLoaderWaitCallback,param3);
                     _loc9_ = Math.max(_loc9_,param1.position);
                     _loc7_ = _loc11_.reductionScaleX;
                     _loc8_ = _loc11_.reductionScaleY;
                  }
                  else
                  {
                     _loc12_ = this._aframes.frames[_loc11_.sharedFrom];
                     ++_loc12_.shares;
                     _loc11_.sharedFrame = _loc12_;
                     _loc11_.reductionScaleX = _loc12_.reductionScaleX;
                     _loc11_.reductionScaleY = _loc12_.reductionScaleY;
                  }
               }
               _loc10_++;
            }
         }
         param1.position = _loc9_;
         if(this.pngEncoded)
         {
            this.pngLoaderWaiting = true;
            this.checkPngLoaderWaiting();
            if(this.pngLoaderWaiting)
            {
               this.consumptionCompleteCallback = param6;
            }
            else
            {
               this.consumptionComplete = true;
            }
         }
         else
         {
            this.consumptionComplete = true;
         }
      }
      
      private function pngLoaderWaitCallback(param1:AnimFrame) : void
      {
         --this.pngLoaderWaits;
         this.checkPngLoaderWaiting();
      }
      
      private function checkPngLoaderWaiting() : void
      {
         var _loc1_:Function = null;
         if(!this.pngLoaderWaiting)
         {
            return;
         }
         if(this.pngLoaderWaits == 0)
         {
            this.pngLoaderWaiting = false;
            _loc1_ = this.consumptionCompleteCallback;
            this.consumptionCompleteCallback = null;
            if(_loc1_ != null)
            {
               _loc1_(this);
            }
         }
      }
      
      public function consumeReducedSheet(param1:ByteArray, param2:int, param3:ILogger) : Boolean
      {
         var _loc5_:AnimFrame = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:AnimFrame = null;
         if(REQUIRE_PNG)
         {
            throw new ArgumentError("PNG Anims required");
         }
         param1.position = param2;
         var _loc4_:int = param1.readInt() + param2;
         var _loc6_:int = int(param1.position);
         while(_loc6_ < _loc4_)
         {
            param1.position = _loc6_;
            _loc10_ = param1.readInt();
            _loc11_ = param1.readInt();
            _loc12_ = param1.readInt();
            _loc13_ = param1.readInt();
            _loc14_ = param1.readInt();
            _loc6_ = int(param1.position);
            _loc5_ = this._aframes.frames[_loc10_];
            _loc5_.actualSheetBmpdWidth = _loc13_;
            _loc5_.actualSheetBmpdHeight = _loc14_;
            _loc5_.consumeReducedSheet(param1,_loc4_ + _loc11_,_loc12_);
            _loc5_.addFrameReferenceTexture();
            _loc5_.releaseFrameReferenceTexture();
         }
         var _loc7_:Number = Platform.qualityTextures;
         var _loc8_:Number = Platform.qualityTextures;
         var _loc9_:int = 0;
         while(_loc9_ < this._aframes.frames.length)
         {
            _loc5_ = this._aframes.frames[_loc9_];
            if(_loc5_)
            {
               if(_loc5_.shared && _loc5_.sharedFrom >= 0)
               {
                  _loc15_ = this._aframes.frames[_loc5_.sharedFrom];
                  ++_loc15_.shares;
                  _loc5_.sharedFrame = _loc15_;
                  _loc5_.reductionScaleX = _loc15_.reductionScaleX;
                  _loc5_.reductionScaleY = _loc15_.reductionScaleY;
               }
            }
            _loc9_++;
         }
         return true;
      }
      
      public function set scale(param1:Number) : void
      {
         this._scale = param1;
      }
      
      public function setup(param1:int, param2:int) : void
      {
         this._numFrames = param1;
         this._fps = param2;
         if(this._fps > 0)
         {
            this._durationMs = 1000 * this._numFrames / this._fps;
         }
         else
         {
            this._durationMs = 1;
         }
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
      }
      
      public function get durationMs() : int
      {
         return this._durationMs * playbackMod;
      }
      
      public function set durationMs(param1:int) : void
      {
         this._durationMs = param1;
      }
      
      public function get fps() : int
      {
         return this._fps * oo_playbackMod;
      }
      
      public function set fps(param1:int) : void
      {
         this._fps = param1;
      }
      
      public function set numFrames(param1:int) : void
      {
         this._numFrames = param1;
      }
      
      public function get numFrames() : int
      {
         return this._numFrames;
      }
      
      public function get numEvents() : int
      {
         return !!this._aframes ? this._aframes.numEvents : 0;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function set url(param1:String) : void
      {
         this._url = param1;
         if(this._aframes)
         {
            this._aframes.clipurl = this._url;
         }
      }
      
      public function get movieClipUrl() : String
      {
         var _loc1_:String = StringUtil.getFolder(this.url);
         return _loc1_ + ".swf/" + this.id;
      }
      
      public function get offsetY() : Number
      {
         return this._offsetY;
      }
      
      public function get offsetX() : Number
      {
         return this._offsetX;
      }
      
      public function get looping() : Boolean
      {
         return this._looping;
      }
      
      public function set looping(param1:Boolean) : void
      {
         this._looping = param1;
      }
      
      public function cleanup() : void
      {
         if(this._aframes)
         {
            this._aframes.cleanup();
            this._aframes = null;
         }
      }
      
      public function isSpriteSheeted() : Boolean
      {
         return this._aframes.frames != null;
      }
      
      public function toString() : String
      {
         return "[id=" + this._id + ", url=" + this._url + ", frames=" + this._numFrames + "]";
      }
      
      public function get highQuality() : Boolean
      {
         return this._highQuality;
      }
      
      public function reduceSheet() : ByteArray
      {
         var _loc5_:AnimFrame = null;
         var _loc6_:int = 0;
         if(Platform.qualityTextures >= 1)
         {
            return null;
         }
         var _loc1_:ByteArray = new ByteArray();
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:int = 0;
         while(_loc3_ < this.aframes.frames.length)
         {
            _loc5_ = this.aframes.frames[_loc3_];
            if(_loc5_.frameNum == _loc3_ && !_loc5_.shared)
            {
               if(_loc5_._compressedBitmapData)
               {
                  _loc1_.writeInt(_loc5_.frameNum);
                  _loc6_ = int(_loc2_.length);
                  _loc1_.writeInt(_loc6_);
                  _loc5_._compressedBitmapData.position = 0;
                  _loc2_.writeBytes(_loc5_._compressedBitmapData);
                  _loc1_.writeInt(_loc2_.length - _loc6_);
                  _loc1_.writeInt(_loc5_.actualSheetBmpdWidth);
                  _loc1_.writeInt(_loc5_.actualSheetBmpdHeight);
               }
            }
            _loc3_++;
         }
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.writeInt(_loc1_.length + 4);
         _loc4_.writeBytes(_loc1_);
         _loc4_.writeBytes(_loc2_);
         _loc2_.clear();
         _loc2_ = null;
         _loc1_.clear();
         _loc1_ = null;
         return _loc4_;
      }
      
      public function readBytes(param1:ByteArray) : AnimClipDef
      {
         var _loc2_:int = int(param1.position);
         this._id = param1.readUTF();
         this._url = param1.readUTF();
         var _loc3_:uint = param1.readUnsignedByte();
         this.looping = 0 != (_loc3_ & 1);
         this.hasSheet = 0 != (_loc3_ & 2);
         this._highQuality = 0 != (_loc3_ & 4);
         this.pngEncoded = 0 != (_loc3_ & 8);
         var _loc4_:* = 0 != (_loc3_ & 16);
         var _loc5_:* = 0 != (_loc3_ & 32);
         var _loc6_:* = 0 != (_loc3_ & 64);
         var _loc7_:* = 0 != (_loc3_ & 128);
         if(this._url.indexOf(".portrait/") > 0)
         {
            this.looping = true;
         }
         if(_loc4_)
         {
            this._scale = param1.readFloat();
         }
         if(_loc5_)
         {
            this._offsetX = param1.readFloat();
         }
         if(_loc6_)
         {
            this._offsetY = param1.readFloat();
         }
         if(_loc7_)
         {
            this.shrunkenScale = param1.readFloat();
         }
         var _loc8_:int = int(param1.readUnsignedShort());
         var _loc9_:int = int(param1.readUnsignedByte());
         this.setup(_loc8_,_loc9_);
         this._aframes = new AnimFrames(this,this.logger);
         this._aframes.readBytes(param1,_loc2_);
         this.locomotiveTilesTotal = this._aframes.locomotiveTilesTotal;
         if(this.locomotiveTilesTotal)
         {
            this.setup(this._numFrames,this._fps);
         }
         return this;
      }
      
      public function writeBytes(param1:ByteArray) : void
      {
         var _loc2_:int = int(param1.position);
         param1.writeUTF(!!this._id ? this._id : "");
         param1.writeUTF(!!this._url ? this._url : "");
         var _loc3_:uint = 0;
         _loc3_ |= this.looping ? 1 : 0;
         _loc3_ |= this.hasSheet ? 2 : 0;
         _loc3_ |= this._highQuality ? 4 : 0;
         _loc3_ |= this.pngEncoded ? 8 : 0;
         _loc3_ |= this._scale != 1 ? 16 : 0;
         _loc3_ |= this._offsetX != 0 ? 32 : 0;
         _loc3_ |= this._offsetY != 0 ? 64 : 0;
         _loc3_ |= this.shrunkenScale != 1 ? 128 : 0;
         param1.writeByte(_loc3_);
         if(this._scale != 1)
         {
            param1.writeFloat(this._scale);
         }
         if(this._offsetX != 0)
         {
            param1.writeFloat(this._offsetX);
         }
         if(this._offsetY != 0)
         {
            param1.writeFloat(this._offsetY);
         }
         if(this.shrunkenScale != 1)
         {
            param1.writeFloat(this.shrunkenScale);
         }
         param1.writeShort(this._numFrames);
         param1.writeByte(this._fps);
         this._aframes.writeBytes(param1,_loc2_);
      }
   }
}
