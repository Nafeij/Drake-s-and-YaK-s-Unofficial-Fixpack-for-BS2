package engine.anim.def
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.logging.ILogger;
   import engine.core.logging.Logger;
   import engine.core.render.PngEncoderUtil;
   import engine.core.util.AppInfo;
   import engine.core.util.BitmapUtil;
   import engine.core.util.StringUtil;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.StageQuality;
   import flash.display3D.Context3DTextureFormat;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import starling.textures.Texture;
   
   public class AnimFrame
   {
      
      private static const INSTANCE_BYTES:int = 29 * 4;
      
      public static var COMPRESSED_FRAMES:Boolean = false;
      
      public static var _funcWriteFileBytes:Function;
      
      public static var AUTOEXPORT_FRAMES:Boolean = false;
      
      public static var AUTOCROP_ENABLED:Boolean = true;
      
      public static var AUTOCROP_DEBUG:Boolean = false;
      
      public static var orphanedTextures:Vector.<Texture> = new Vector.<Texture>();
      
      private static var _byteArrayDecompressionBuffer:ByteArray = new ByteArray();
      
      private static var _byteArrayDecompressionBuffersMax:int = 0;
      
      private static var _oldByteArrayDecompressionBuffer:int = 0;
      
      private static var _rect:Rectangle = new Rectangle();
      
      private static var _textureDebugDumped:Boolean;
      
      public static var BYTE_ARRAY_DECOMPRESSION_BUFFER_SOFT_LIMIT:int = 5 * (1 << 20);
      
      public static var COMPRESSION_SIZE_THRESHOLD_PIXELS:int = 128 * 128;
      
      private static var _ccbuffer:ByteArray = new ByteArray();
       
      
      private var bmpd:BitmapData;
      
      private var texture:Texture;
      
      public var offset:Point;
      
      public var bound:Rectangle;
      
      public var shared:Boolean;
      
      public var sharedFrom:int = -1;
      
      public var sharedFrame:AnimFrame;
      
      public var frameNum:int = -1;
      
      public var origBmpdNum:int;
      
      public var sheetBufferPosition:int = -1;
      
      public var sheetBufferSize:int;
      
      public var sheetBmpdWidth:int;
      
      public var sheetBmpdHeight:int;
      
      public var children:Vector.<AnimFrameChild>;
      
      public var shares:int;
      
      public var _compressedBitmapData:ByteArray;
      
      private var _refcountBmpd:int;
      
      private var _refcountTexture:int;
      
      public var hasConsumedSheet:Boolean;
      
      public var reductionScaleX:Number = 1;
      
      public var reductionScaleY:Number = 1;
      
      public var frames:AnimFrames;
      
      public var locomotiveTiles:Number = 0;
      
      public var logger:ILogger;
      
      private var _waiting_onPngLoadComplete:Boolean;
      
      public var actualSheetBmpdWidth:int;
      
      public var actualSheetBmpdHeight:int;
      
      private var pngLoader:Loader;
      
      private var pngLoadedCallback:Function;
      
      private var useCompression:Boolean = false;
      
      public function AnimFrame(param1:AnimFrames, param2:ILogger)
      {
         super();
         this.frames = param1;
         this.logger = param2;
      }
      
      public static function gotoFrameRecursive(param1:MovieClip, param2:int) : void
      {
         var _loc4_:MovieClip = null;
         param1.gotoAndStop(1 + param2 % param1.framesLoaded);
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_) as MovieClip;
            if(_loc4_)
            {
               gotoFrameRecursive(_loc4_,param2);
            }
            _loc3_++;
         }
      }
      
      public static function cropBitmapData(param1:BitmapData, param2:Point) : BitmapData
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:Boolean = false;
         var _loc10_:Rectangle = null;
         var _loc11_:BitmapData = null;
         param2.setTo(0,0);
         var _loc8_:int = param1.width - 1;
         var _loc9_:int = param1.height - 1;
         _loc3_ = 0;
         _loc7_ = false;
         while(_loc3_ < param1.width - 1 && !_loc7_)
         {
            param2.x = _loc3_;
            _loc4_ = 0;
            while(_loc4_ < param1.height)
            {
               _loc5_ = param1.getPixel32(_loc3_,_loc4_);
               _loc6_ = _loc5_ & 4278190080;
               if(_loc6_)
               {
                  _loc7_ = true;
                  break;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         _loc4_ = 0;
         _loc7_ = false;
         while(_loc4_ < param1.height - 1 && !_loc7_)
         {
            param2.y = _loc4_;
            _loc3_ = param2.x;
            while(_loc3_ < param1.width)
            {
               _loc5_ = param1.getPixel32(_loc3_,_loc4_);
               _loc6_ = _loc5_ & 4278190080;
               if(_loc6_)
               {
                  _loc7_ = true;
                  break;
               }
               _loc3_++;
            }
            _loc4_++;
         }
         _loc3_ = param1.width - 1;
         _loc7_ = false;
         while(_loc3_ > param2.x && !_loc7_)
         {
            _loc8_ = _loc3_;
            _loc4_ = param2.y;
            while(_loc4_ < param1.height)
            {
               _loc5_ = param1.getPixel32(_loc3_,_loc4_);
               _loc6_ = _loc5_ & 4278190080;
               if(_loc6_)
               {
                  _loc7_ = true;
                  break;
               }
               _loc4_++;
            }
            _loc3_--;
         }
         _loc4_ = param1.height - 1;
         _loc7_ = false;
         while(_loc4_ > param2.y && !_loc7_)
         {
            _loc9_ = _loc4_;
            _loc3_ = param2.x;
            while(_loc3_ <= _loc8_)
            {
               _loc5_ = param1.getPixel32(_loc3_,_loc4_);
               _loc6_ = _loc5_ & 4278190080;
               if(_loc6_)
               {
                  _loc7_ = true;
                  break;
               }
               _loc3_++;
            }
            _loc4_--;
         }
         if(param2.x != 0 || param2.y != 0 || _loc9_ != param1.height - 1 || _loc8_ != param1.width - 1)
         {
            _loc10_ = new Rectangle(param2.x,param2.y,_loc8_ - param2.x + 1,_loc9_ - param2.y + 1);
            _loc11_ = new BitmapData(_loc10_.width,_loc10_.height,true,0);
            _loc11_.copyPixels(param1,_loc10_,new Point(),null,null,true);
            return _loc11_;
         }
         return null;
      }
      
      public static function findRegistrationMovieClip(param1:MovieClip) : MovieClip
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:MovieClip = null;
         var _loc5_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            _loc3_ = param1.getChildAt(_loc2_);
            _loc4_ = _loc3_ as MovieClip;
            if(_loc4_)
            {
               _loc5_ = getQualifiedClassName(_loc4_);
               if(_loc5_ == "registration")
               {
                  return _loc4_;
               }
            }
            _loc2_++;
         }
         return null;
      }
      
      public static function findRegistrationMovieClipPoint(param1:MovieClip) : Point
      {
         var _loc2_:MovieClip = findRegistrationMovieClip(param1);
         if(_loc2_)
         {
            return new Point(_loc2_.x,_loc2_.y);
         }
         return null;
      }
      
      private static function setFrame(param1:MovieClip, param2:int) : void
      {
         var _loc4_:MovieClip = null;
         if(!param1)
         {
            return;
         }
         param1.gotoAndStop(param2 + 1);
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_) as MovieClip;
            if(_loc4_)
            {
               setFrame(_loc4_,param2);
            }
            _loc3_++;
         }
      }
      
      public static function debugDumpOrphanedTextures(param1:ILogger) : void
      {
         var _loc2_:Texture = null;
         param1.info("AnimFrame.debugDumpOrphanedTextures");
         for each(_loc2_ in orphanedTextures)
         {
            param1.info("   " + _loc2_.toString());
         }
      }
      
      public static function purgeOrphanedTextures(param1:ILogger) : void
      {
         var _loc2_:Texture = null;
         if(Platform.suspended || !PlatformStarling.isContextValid)
         {
            return;
         }
         if(orphanedTextures.length)
         {
            for each(_loc2_ in orphanedTextures)
            {
               _loc2_.dispose();
            }
            param1.info("AnimFrame.purgeOrphanedTextures purged " + orphanedTextures.length);
            orphanedTextures.splice(0,orphanedTextures.length);
         }
      }
      
      public function get numBytes() : int
      {
         var _loc2_:int = 0;
         var _loc3_:AnimFrameChild = null;
         var _loc1_:int = INSTANCE_BYTES;
         if(this.children)
         {
            _loc1_ += this.children.length * 4;
            _loc2_ = 0;
            while(_loc2_ < this.children.length)
            {
               _loc3_ = this.children[_loc2_];
               if(_loc3_)
               {
                  _loc1_ += _loc3_.numBytes;
               }
               _loc2_++;
            }
         }
         if(this._compressedBitmapData)
         {
            _loc1_ += this._compressedBitmapData.length * 4;
         }
         if(Boolean(this.bmpd) && !this.shared)
         {
            _loc1_ += this.bmpd.width * this.bmpd.height * 4;
         }
         return _loc1_;
      }
      
      public function toString() : String
      {
         return "[AnimFrame f=" + this.frameNum + " sf=" + this.sharedFrom + " bmpd=" + (!!this.bmpd ? "1" : "0") + " fs=" + this.frames + "]";
      }
      
      public function create(param1:AnimFrames, param2:MovieClip, param3:int, param4:Object, param5:ILogger, param6:Number) : void
      {
         var _loc11_:Matrix = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:String = null;
         var _loc15_:Point = null;
         var _loc16_:int = 0;
         var _loc17_:BitmapData = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:AnimFrameChild = null;
         this.frameNum = param3;
         param4.autocrop_savings_pixels = 0;
         gotoFrameRecursive(param2,param3);
         var _loc7_:int = this.createChildren(param1,param2,param3,param6);
         var _loc8_:Boolean = this.checkLocoRegistration(param2,param5);
         if(_loc8_ && param1.frames.length == param3 - 1)
         {
            return;
         }
         var _loc9_:Rectangle = param2.getBounds(param2);
         var _loc10_:Rectangle = _loc9_;
         if(_loc10_ && !_loc10_.isEmpty() && param2.numChildren > _loc7_)
         {
            _loc10_.x *= param2.scaleX;
            _loc10_.y *= param2.scaleY;
            _loc10_.width *= param2.scaleX;
            _loc10_.height *= param2.scaleY;
            _loc10_.left = Math.floor(_loc10_.left) - 1;
            _loc10_.top = Math.floor(_loc10_.top) - 1;
            _loc10_.width = Math.ceil(_loc10_.width) + 1;
            _loc10_.height = Math.floor(_loc10_.height) + 1;
            this.bmpd = new BitmapData(_loc10_.width,_loc10_.height,true,0);
            _loc11_ = new Matrix();
            _loc12_ = _loc10_.x;
            _loc13_ = _loc10_.y;
            _loc11_.scale(param2.scaleX,param2.scaleY);
            _loc11_.translate(-_loc12_,-_loc13_);
            _loc14_ = StageQuality.BEST;
            BitmapUtil.drawWithQuality(this.bmpd,param2,_loc11_,null,null,null,true,_loc14_);
            if(AUTOCROP_ENABLED)
            {
               _loc15_ = new Point();
               _loc16_ = getTimer();
               _loc17_ = cropBitmapData(this.bmpd,_loc15_);
               _loc18_ = getTimer() - _loc16_;
               if(_loc17_)
               {
                  _loc19_ = this.bmpd.width * this.bmpd.height - _loc17_.width * _loc17_.height;
                  if(AUTOCROP_DEBUG && Logger.instance.isDebugEnabled)
                  {
                     Logger.instance.debug(">>>> AnimFrame reduced frame " + " " + param3 + " " + this.bmpd.width + "x" + this.bmpd.height + " to " + _loc17_.width + "x" + _loc17_.height + " by " + _loc19_ + " pixels in " + _loc18_ + " ms");
                  }
                  param4.autocrop_savings_pixels += _loc19_;
                  _loc12_ += _loc15_.x;
                  _loc13_ += _loc15_.y;
                  this.bmpd.dispose();
                  this.bmpd = _loc17_;
                  _loc9_.width = _loc17_.width;
                  _loc9_.height = _loc17_.height;
                  _loc9_.x += _loc15_.x;
                  _loc9_.y += _loc15_.y;
               }
            }
            this.actualSheetBmpdWidth = this.bmpd.width;
            this.actualSheetBmpdHeight = this.bmpd.height;
            if(Boolean(_loc12_) || Boolean(_loc13_))
            {
               if(!this.offset)
               {
                  this.offset = new Point();
               }
               this.offset.x += _loc12_;
               this.offset.y += _loc13_;
               this.offset.x = Math.round(this.offset.x * 100) / 100;
               this.offset.y = Math.round(this.offset.y * 100) / 100;
            }
            if(AUTOEXPORT_FRAMES)
            {
               this._autoexportFrames(param1);
            }
         }
         _loc9_.x = Math.round(_loc9_.x * 100) / 100;
         _loc9_.y = Math.round(_loc9_.y * 100) / 100;
         _loc9_.width = Math.round(_loc9_.width * 100) / 100;
         _loc9_.height = Math.round(_loc9_.height * 100) / 100;
         this.bound = _loc9_;
         if(this.children)
         {
            for each(_loc20_ in this.children)
            {
               if(Boolean(_loc20_) && Boolean(_loc20_.mc))
               {
                  _loc20_.mc.visible = _loc20_.visible;
               }
            }
         }
      }
      
      private function _autoexportFrames(param1:AnimFrames) : void
      {
         var _loc3_:ByteArray = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:* = null;
         if(param1.isPortrait)
         {
            return;
         }
         var _loc2_:Boolean = param1.hasFrameEvents(this.frameNum);
         if(this.frameNum == 0 && param1.isMaster || _loc2_)
         {
            _loc3_ = PngEncoderUtil.pngEncode(this.bmpd,true);
            _loc4_ = param1.clipurl.lastIndexOf("/");
            _loc5_ = param1.clipurl.lastIndexOf("/",_loc4_ - 1);
            _loc6_ = param1.clipurl.substring(_loc5_ + 1);
            _loc7_ = _loc6_.replace(".anim/","_");
            _loc7_ = StringUtil.stripSuffix(_loc7_,".clip");
            if(_loc2_)
            {
               _loc7_ += "_" + this.frameNum;
            }
            _loc8_ = "/tmp/character_masters/" + _loc7_ + ".png";
            this.logger.info("SAVING FRAME [" + _loc8_ + "]");
            _funcWriteFileBytes(_loc8_,_loc3_,this.logger);
            _loc3_.clear();
         }
      }
      
      public function equalsChildren(param1:AnimFrame) : Boolean
      {
         var _loc3_:AnimFrameChild = null;
         var _loc4_:AnimFrameChild = null;
         if(!this.children && !param1.children)
         {
            return true;
         }
         if(this.children == null != (param1.children == null))
         {
            return false;
         }
         if(this.children.length != param1.children.length)
         {
            return false;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.children.length)
         {
            _loc3_ = this.children[_loc2_];
            _loc4_ = param1.children[_loc2_];
            if(!(_loc3_ == null && _loc4_ == null))
            {
               if(_loc3_ == null || _loc4_ == null)
               {
                  return false;
               }
               if(!_loc3_.equals(_loc4_))
               {
                  return false;
               }
            }
            _loc2_++;
         }
         return true;
      }
      
      private function checkLocoRegistration(param1:MovieClip, param2:ILogger) : Boolean
      {
         if(!this.frames.locomotive)
         {
            return false;
         }
         var _loc3_:Point = findRegistrationMovieClipPoint(param1);
         if(!_loc3_)
         {
            throw new IllegalOperationError("Frames " + this.frames + " number " + param1.currentFrame + " no registration for loco");
         }
         this.locomotiveTiles = param1.scaleX * _loc3_.x / 64;
         if(!this.offset)
         {
            this.offset = new Point();
         }
         this.offset.x -= _loc3_.x * param1.scaleX;
         this.offset.y -= _loc3_.y * param1.scaleY;
         return true;
      }
      
      private function createChildren(param1:AnimFrames, param2:MovieClip, param3:int, param4:Number) : int
      {
         var _loc6_:AnimClipChildDef = null;
         var _loc7_:MovieClip = null;
         var _loc8_:AnimFrameChild = null;
         if(!param1.children || param1.children.length == 0)
         {
            return 0;
         }
         this.children = new Vector.<AnimFrameChild>();
         var _loc5_:int = 0;
         for each(_loc6_ in param1.children)
         {
            _loc5_ = this.children.length;
            _loc7_ = param2.getChildByName(_loc6_.name) as MovieClip;
            if(!_loc7_)
            {
               this.children.push(null);
            }
            else
            {
               _loc8_ = new AnimFrameChild().fromMovieClip(_loc6_,_loc7_,param3,this.children.length,param4);
               _loc7_.visible = false;
               this.children.push(_loc8_);
            }
         }
         return param1.children.length;
      }
      
      public function cleanup() : void
      {
         if(this._waiting_onPngLoadComplete)
         {
            this._waiting_onPngLoadComplete = false;
            TweenMax.killDelayedCallsTo(this.onPngLoadComplete);
         }
         if(this._compressedBitmapData)
         {
            this._compressedBitmapData.clear();
            this._compressedBitmapData = null;
         }
         if(this.shared)
         {
            if(Boolean(this.bmpd) || Boolean(this.texture))
            {
            }
         }
         if(Boolean(this.bmpd) && !this.shared)
         {
            this.bmpd.dispose();
         }
         if(this.pngLoader)
         {
            this.pngLoader.unload();
            this.pngLoader = null;
         }
         this.pngLoadedCallback = null;
         if(Boolean(this.texture) && !this.shared)
         {
            this.texture.root.onRestore = null;
            if(PlatformStarling.isContextValid)
            {
               this.texture.dispose();
            }
            else if(!AppInfo.terminating)
            {
               this.logger.info("AnimFrame.cleanup orphaning texture " + this);
               orphanedTextures.push(this.texture);
            }
         }
         this.texture = null;
         this.bmpd = null;
         this.offset = null;
         this.children = null;
      }
      
      public function releaseFrameReferenceBmpd() : void
      {
         if(this._refcountBmpd <= 0)
         {
            throw new ArgumentError("Too many releaseFrameReferenceBmpd on " + this);
         }
         --this._refcountBmpd;
         if(this.sharedFrame)
         {
            this.sharedFrame.releaseFrameReferenceBmpd();
            return;
         }
         if(this._refcountBmpd == 0)
         {
            if(Boolean(this.bmpd) && Boolean(this._compressedBitmapData))
            {
               this.bmpd.dispose();
               this.bmpd = null;
            }
         }
      }
      
      public function releaseFrameReferenceTexture() : void
      {
         if(this._refcountTexture <= 0)
         {
            throw new ArgumentError("Too many releaseFrameReferenceTexture on " + this);
         }
         --this._refcountTexture;
         if(this.sharedFrame)
         {
            this.sharedFrame.releaseFrameReferenceTexture();
            return;
         }
         if(this._refcountTexture == 0)
         {
            if(Boolean(this.texture) && Boolean(this._compressedBitmapData))
            {
               this.texture.root.onRestore = null;
               if(!Platform.suspended)
               {
                  this.texture.dispose();
               }
               else if(!AppInfo.terminating)
               {
                  this.logger.info("AnimFrame.releaseFrameReferenceTexture orphaning texture for " + this);
                  orphanedTextures.push(this.texture);
               }
               this.texture = null;
            }
         }
      }
      
      public function addFrameReferenceBmpd() : BitmapData
      {
         ++this._refcountBmpd;
         if(this.sharedFrame)
         {
            return this.sharedFrame.addFrameReferenceBmpd();
         }
         if(!this.bmpd && Boolean(this._compressedBitmapData))
         {
            this.updateDecompressionBuffer();
            this.bmpd = new BitmapData(this.actualSheetBmpdWidth,this.actualSheetBmpdHeight,true,0);
            _rect.setTo(0,0,this.bmpd.width,this.bmpd.height);
            this.bmpd.setPixels(_rect,_byteArrayDecompressionBuffer);
         }
         return this.bmpd;
      }
      
      public function addFrameReferenceTexture() : Texture
      {
         var bbb:BitmapData = null;
         var cn:String = null;
         ++this._refcountTexture;
         if(this.sharedFrame)
         {
            return this.sharedFrame.addFrameReferenceTexture();
         }
         if(!this.texture)
         {
            try
            {
               if(this._compressedBitmapData)
               {
                  if(this.sheetBmpdHeight > 2048 || this.sheetBmpdHeight > 2048)
                  {
                     return null;
                  }
                  this.updateDecompressionBuffer();
                  bbb = new BitmapData(this.actualSheetBmpdWidth,this.actualSheetBmpdHeight,true,0);
                  _rect.setTo(0,0,bbb.width,bbb.height);
                  bbb.setPixels(_rect,_byteArrayDecompressionBuffer);
                  this.texture = Texture.fromBitmapData(this,bbb,false,false,1,Context3DTextureFormat.BGRA);
                  this.texture.root.onRestore = this.textureRestoreHandler;
                  bbb.dispose();
               }
               else if(this.bmpd)
               {
                  _rect.setTo(0,0,this.bmpd.width,this.bmpd.height);
                  this.texture = Texture.fromBitmapData(this,this.bmpd,false,false,1,Context3DTextureFormat.BGRA);
                  this.texture.root.onRestore = this.textureRestoreHandler;
               }
            }
            catch(e:Error)
            {
               cn = !!_compressedBitmapData ? "(-COMPRESSED-)" : "(uncompressed)";
               logger.error("Failed to create " + cn + " texture " + _rect + " (orphans=" + orphanedTextures.length + ") for " + this + " " + frames + ":\n" + e.getStackTrace());
               if(!_textureDebugDumped)
               {
                  _textureDebugDumped = true;
                  logger.error(Texture.debugDump());
               }
               purgeOrphanedTextures(logger);
            }
         }
         return this.texture;
      }
      
      private function updateDecompressionBuffer() : void
      {
         if(_byteArrayDecompressionBuffersMax > BYTE_ARRAY_DECOMPRESSION_BUFFER_SOFT_LIMIT && _byteArrayDecompressionBuffersMax > this._compressedBitmapData.length * 100)
         {
            _byteArrayDecompressionBuffer.clear();
            _byteArrayDecompressionBuffersMax = 0;
         }
         else
         {
            _byteArrayDecompressionBuffer.length = 0;
         }
         _byteArrayDecompressionBuffer.writeBytes(this._compressedBitmapData);
         _byteArrayDecompressionBuffer.length = this._compressedBitmapData.length;
         _byteArrayDecompressionBuffer.uncompress();
         if(_byteArrayDecompressionBuffer.length > _byteArrayDecompressionBuffersMax)
         {
            _byteArrayDecompressionBuffersMax = _byteArrayDecompressionBuffer.length;
         }
      }
      
      private function textureRestoreHandler() : void
      {
         var _loc1_:BitmapData = null;
         if(this.texture)
         {
            if(this.bmpd)
            {
               this.texture.root.uploadBitmapData(this.bmpd);
            }
            else
            {
               this.updateDecompressionBuffer();
               _loc1_ = new BitmapData(this.actualSheetBmpdWidth,this.actualSheetBmpdHeight,true,0);
               _rect.setTo(0,0,_loc1_.width,_loc1_.height);
               _loc1_.setPixels(_rect,_byteArrayDecompressionBuffer);
               this.texture.root.uploadBitmapData(_loc1_);
               _loc1_.dispose();
            }
         }
      }
      
      private function checkPixelCompressionThreshold(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = param1 * param2;
         if(_loc3_ >= COMPRESSION_SIZE_THRESHOLD_PIXELS)
         {
            if(this.logger.isDebugEnabled)
            {
            }
            return true;
         }
         return false;
      }
      
      public function consumeSheet(param1:ByteArray, param2:int, param3:Number, param4:Number, param5:Boolean, param6:Boolean, param7:Boolean, param8:Function, param9:ILogger) : void
      {
         var _loc10_:LoaderContext = null;
         if(this.hasConsumedSheet)
         {
            throw new IllegalOperationError("Already consumed sheet: " + this);
         }
         if(this.frames.clipurl.indexOf("common/character/dredge/eyeless.anim/attack_ne") == 0)
         {
            this.frames = this.frames;
         }
         if(!this.useCompression && param7 && COMPRESSED_FRAMES)
         {
            this.useCompression = this.checkPixelCompressionThreshold(this.sheetBmpdWidth,this.sheetBmpdHeight);
         }
         this.reductionScaleX = param3;
         this.reductionScaleY = param4;
         this.pngLoadedCallback = param8;
         this.hasConsumedSheet = true;
         if(this.sheetBmpdWidth <= 0 || this.sheetBmpdHeight <= 0 || this.sheetBufferPosition < 0 || this.sheetBufferSize <= 0)
         {
            if(param6)
            {
               this._waiting_onPngLoadComplete = true;
               TweenMax.delayedCall(0,this.onPngLoadComplete,[null]);
            }
            return;
         }
         if(this.useCompression && !param6)
         {
            this.actualSheetBmpdWidth = this.sheetBmpdWidth;
            this.actualSheetBmpdHeight = this.sheetBmpdHeight;
            this._compressedBitmapData = new ByteArray();
            this._compressedBitmapData.writeBytes(param1,param2 + this.sheetBufferPosition,this.sheetBufferSize);
            param1.position = param2 + this.sheetBufferPosition + this.sheetBufferSize;
            if(Platform.qualityTextures == 1)
            {
               return;
            }
         }
         _byteArrayDecompressionBuffer.position = 0;
         _byteArrayDecompressionBuffer.writeBytes(param1,param2 + this.sheetBufferPosition,this.sheetBufferSize);
         _byteArrayDecompressionBuffer.length = this.sheetBufferSize;
         param1.position = param2 + this.sheetBufferPosition + this.sheetBufferSize;
         if(param6)
         {
            _byteArrayDecompressionBuffer.position = 0;
            _loc10_ = new LoaderContext(false,null,null);
            this.pngLoader = new Loader();
            this.pngLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onPngLoadComplete);
            this.pngLoader.loadBytes(_byteArrayDecompressionBuffer,_loc10_);
         }
         else
         {
            _byteArrayDecompressionBuffer.uncompress();
            this.bmpd = new BitmapData(this.sheetBmpdWidth,this.sheetBmpdHeight,true,0);
            _rect.setTo(0,0,this.bmpd.width,this.bmpd.height);
            this.bmpd.setPixels(_rect,_byteArrayDecompressionBuffer);
            if(param5)
            {
               this._reduceTextureIfNecessary();
            }
         }
         _byteArrayDecompressionBuffer.clear();
      }
      
      private function _reduceTextureIfNecessary() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:BitmapData = null;
         var _loc5_:Matrix = null;
         if(Platform.qualityTextures < 1)
         {
            _loc1_ = Platform.qualityTextures;
            _loc2_ = Math.max(1,this.bmpd.height * _loc1_);
            _loc3_ = Math.max(1,this.bmpd.width * _loc1_);
            this.reductionScaleX = this.bmpd.width / _loc3_;
            this.reductionScaleY = this.bmpd.height / _loc2_;
            _loc4_ = new BitmapData(_loc3_,_loc2_,true,0);
            _loc5_ = new Matrix();
            _loc5_.scale(1 / this.reductionScaleX,1 / this.reductionScaleY);
            BitmapUtil.drawWithQuality(_loc4_,this.bmpd,_loc5_,null,null,null,true,StageQuality.BEST);
            this.bmpd.dispose();
            this.bmpd = _loc4_;
            this.actualSheetBmpdWidth = this.bmpd.width;
            this.actualSheetBmpdHeight = this.bmpd.height;
            if(this._compressedBitmapData)
            {
               this._compressedBitmapData.clear();
               this._compressedBitmapData = null;
               if(this.useCompression)
               {
                  this.useCompression = this.checkPixelCompressionThreshold(this.actualSheetBmpdWidth,this.actualSheetBmpdHeight);
               }
            }
            if(this.useCompression)
            {
               this.compressFrame();
            }
         }
      }
      
      public function compressFrame() : void
      {
         if(this._compressedBitmapData)
         {
            return;
         }
         if(this.bmpd)
         {
            _rect.setTo(0,0,this.bmpd.width,this.bmpd.height);
            _ccbuffer.position = 0;
            this.bmpd.copyPixelsToByteArray(_rect,_ccbuffer);
            _ccbuffer.compress();
            this._compressedBitmapData = new ByteArray();
            this._compressedBitmapData.writeBytes(_ccbuffer,0,_ccbuffer.length);
            this.bmpd.dispose();
            this.bmpd = null;
            this.sheetBufferSize = this._compressedBitmapData.length;
         }
      }
      
      private function onPngLoadComplete(param1:Event) : void
      {
         this._waiting_onPngLoadComplete = false;
         if(Boolean(this.pngLoader) && Boolean(this.pngLoader.content))
         {
            this.bmpd = (this.pngLoader.content as Bitmap).bitmapData;
            _rect.setTo(0,0,this.bmpd.width,this.bmpd.height);
         }
         var _loc2_:Function = this.pngLoadedCallback;
         this.pngLoadedCallback = null;
         if(_loc2_ != null)
         {
            _loc2_(this);
         }
      }
      
      public function consumeReducedSheet(param1:ByteArray, param2:int, param3:int) : void
      {
         if(this.hasConsumedSheet)
         {
            throw new IllegalOperationError("Already consumed sheet: " + this);
         }
         this.hasConsumedSheet = true;
         if(this.actualSheetBmpdWidth <= 0 || this.actualSheetBmpdHeight <= 0 || param2 < 0 || param3 <= 0)
         {
            return;
         }
         this._compressedBitmapData = new ByteArray();
         this._compressedBitmapData.writeBytes(param1,param2,param3);
         param1.position = param2 + param3;
         this.reductionScaleX = this.sheetBmpdWidth / this.actualSheetBmpdWidth;
         this.reductionScaleY = this.sheetBmpdHeight / this.actualSheetBmpdHeight;
         if(!this.useCompression)
         {
            _byteArrayDecompressionBuffer.position = 0;
            this._compressedBitmapData.position = 0;
            _byteArrayDecompressionBuffer.writeBytes(this._compressedBitmapData);
            _byteArrayDecompressionBuffer.length = this._compressedBitmapData.length;
            _byteArrayDecompressionBuffer.uncompress();
            this.bmpd = new BitmapData(this.sheetBmpdWidth,this.sheetBmpdHeight,true,0);
            _rect.setTo(0,0,this.bmpd.width,this.bmpd.height);
            this.bmpd.setPixels(_rect,_byteArrayDecompressionBuffer);
            _byteArrayDecompressionBuffer.clear();
         }
      }
      
      public function assignEditorBitmapData(param1:BitmapData) : void
      {
         if(Boolean(this.bmpd) && !this.shared)
         {
            this.bmpd.dispose();
         }
         this.bmpd = param1;
      }
      
      public function getBitmapData() : BitmapData
      {
         return this.bmpd;
      }
      
      public function get numBitmapPixels() : int
      {
         if(this.bmpd)
         {
            return this.bmpd.width * this.bmpd.height;
         }
         return 0;
      }
      
      public function readBytes(param1:ByteArray, param2:ILogger, param3:int, param4:int, param5:int) : void
      {
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:AnimFrameChild = null;
         var _loc6_:int = param1.position;
         this.frameNum = param1.readShort();
         if(this.frameNum != param3)
         {
            return;
         }
         var _loc7_:uint = param1.readUnsignedByte();
         var _loc8_:Boolean = Boolean(_loc7_ & 1);
         this.shared = Boolean(_loc7_ & 2);
         var _loc9_:Boolean = Boolean(_loc7_ & 4);
         var _loc10_:Boolean = Boolean(_loc7_ & 8);
         var _loc11_:Boolean = Boolean(_loc7_ & 16);
         if(_loc11_)
         {
            this.locomotiveTiles = param1.readFloat();
         }
         if(_loc8_)
         {
            this.offset = new Point();
            this.offset.x = param1.readFloat();
            this.offset.y = param1.readFloat();
         }
         this.origBmpdNum = param1.readUnsignedShort();
         if(this.shared)
         {
            this.sharedFrom = param1.readUnsignedShort();
         }
         else if(_loc10_)
         {
            this.sheetBufferPosition = param1.readUnsignedInt();
            this.sheetBufferSize = param1.readInt();
            this.sheetBmpdWidth = param1.readUnsignedShort();
            this.sheetBmpdHeight = param1.readUnsignedShort();
         }
         this.bound = new Rectangle(param1.readFloat(),param1.readFloat(),param1.readFloat(),param1.readFloat());
         if(_loc9_)
         {
            this.children = new Vector.<AnimFrameChild>(param4);
            _loc12_ = param1.readUnsignedByte();
            _loc13_ = 0;
            while(_loc13_ < _loc12_)
            {
               _loc14_ = new AnimFrameChild();
               _loc14_.readBytes(param1,param2);
               this.children[_loc14_.childIndex] = _loc14_;
               _loc13_++;
            }
         }
      }
      
      public function writeBytes(param1:ByteArray, param2:int, param3:ILogger, param4:int) : void
      {
         var _loc7_:int = 0;
         var _loc8_:AnimFrameChild = null;
         var _loc9_:int = 0;
         if(this.frameNum >= 32768)
         {
            throw new ArgumentError("Frame num " + this.frameNum + " out of range");
         }
         param1.writeShort(this.frameNum);
         if(param2 != this.frameNum)
         {
            return;
         }
         var _loc5_:uint = 0;
         var _loc6_:Boolean = Boolean(this.offset) && (Boolean(this.offset.x) || Boolean(this.offset.y));
         _loc5_ |= _loc6_ ? 1 : 0;
         _loc5_ |= this.shared ? 2 : 0;
         _loc5_ |= !!this.children ? 4 : 0;
         _loc5_ |= this.sheetBufferSize > 0 ? 8 : 0;
         _loc5_ |= !!this.locomotiveTiles ? 16 : 0;
         param1.writeByte(_loc5_);
         if(this.locomotiveTiles)
         {
            param1.writeFloat(this.locomotiveTiles);
         }
         if(_loc6_)
         {
            param1.writeFloat(this.offset.x);
            param1.writeFloat(this.offset.y);
         }
         param1.writeShort(this.origBmpdNum);
         if(this.shared)
         {
            param1.writeShort(this.sharedFrom);
         }
         else if(this.sheetBufferSize > 0)
         {
            param1.writeInt(this.sheetBufferPosition);
            param1.writeInt(this.sheetBufferSize);
            param1.writeShort(this.sheetBmpdWidth);
            param1.writeShort(this.sheetBmpdHeight);
         }
         param1.writeFloat(this.bound.x);
         param1.writeFloat(this.bound.y);
         param1.writeFloat(this.bound.width);
         param1.writeFloat(this.bound.height);
         if(this.children)
         {
            _loc7_ = 0;
            for each(_loc8_ in this.children)
            {
               if(_loc8_)
               {
                  _loc7_++;
               }
            }
            param1.writeByte(_loc7_);
            _loc9_ = 0;
            for each(_loc8_ in this.children)
            {
               if(_loc8_)
               {
                  _loc8_.writeBytes(param1,param2);
                  _loc9_++;
               }
            }
         }
      }
      
      public function isOffsetEqual(param1:AnimFrame) : Boolean
      {
         if(param1.offset == this.offset)
         {
            return true;
         }
         var _loc2_:Number = !!this.offset ? this.offset.x : 0;
         var _loc3_:Number = !!this.offset ? this.offset.y : 0;
         var _loc4_:Number = !!param1.offset ? param1.offset.x : 0;
         var _loc5_:Number = !!param1.offset ? param1.offset.y : 0;
         return _loc2_ == _loc4_ && _loc3_ == _loc5_;
      }
   }
}
