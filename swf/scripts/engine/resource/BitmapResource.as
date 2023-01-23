package engine.resource
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.BitmapUtil;
   import engine.core.util.ClickableBitmap;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import engine.landscape.view.DisplayObjectWrapperStarling;
   import engine.resource.loader.DisplayResourceLoader;
   import engine.resource.loader.IResourceLoader;
   import engine.resource.loader.IResourceLoaderListener;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.PixelSnapping;
   import flash.display.StageQuality;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import starling.display.Image;
   import starling.textures.Texture;
   
   public class BitmapResource extends Resource implements IBitmapResource, ILoaderFactory
   {
      
      public static var CACHE_ID:String = "bitmap";
      
      public static var defaultLoaderClazz:Class = DisplayResourceLoader;
      
      private static var MAX_DIMENSION:int = 4096;
      
      private static const CACHE_HEADER:uint = 305419896;
      
      private static var _textureDebugDumped:Boolean;
      
      public static var orphanedTextures:Vector.<Texture> = new Vector.<Texture>();
       
      
      private var m_bmpd:BitmapData;
      
      private var numBmpdBytes:int;
      
      public var transparent:Boolean;
      
      private var restoreCount:uint = 0;
      
      private var isRestoring:Boolean = false;
      
      public var scaleX:Number = 1;
      
      public var scaleY:Number = 1;
      
      private var _texture:Texture;
      
      private var _textureRects:Dictionary;
      
      public function BitmapResource(param1:String, param2:ResourceManager, param3:ILoaderFactory = null)
      {
         super(param1,param2,null != param3 ? param3 : this,CACHE_ID);
         if(Platform.qualityTextures == 1)
         {
            disableCacheLoad = true;
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
            param1.info("BitmapResource.purgeOrphanedTextures purged " + orphanedTextures.length);
            orphanedTextures.splice(0,orphanedTextures.length);
         }
      }
      
      public function loaderFactoryHandler(param1:String, param2:IResourceLoaderListener) : IResourceLoader
      {
         if(defaultLoaderClazz == null)
         {
            throw new Error("defaultLoaderFactory can\'t create a loader because defaultLoaderClazz is not set!");
         }
         return new defaultLoaderClazz(param1,param2,logger);
      }
      
      override public function toString() : String
      {
         return "[BitmapResource " + super.toString() + "]";
      }
      
      final private function handleLoadFromDisplayLoader() : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Matrix = null;
         var _loc8_:ByteArray = null;
         var _loc9_:Point = null;
         var _loc1_:IResourceLoader = loader as IResourceLoader;
         var _loc2_:Bitmap = _loc1_.data as Bitmap;
         var _loc3_:BitmapData = _loc2_.bitmapData;
         this.transparent = _loc3_.transparent;
         if(_loc3_.width > MAX_DIMENSION || _loc3_.height > MAX_DIMENSION)
         {
            logger.error("Bitmap [" + url + "] is too large: " + _loc3_.width + " x " + _loc3_.height);
            setError();
         }
         else
         {
            this.numBmpdBytes = _loc3_.width * _loc3_.height * 4;
            if(Platform.qualityTextures < 1)
            {
               _loc4_ = Platform.qualityTextures;
               if(url.indexOf(".icon.") >= 0 || url.indexOf("/ability/icon/") >= 0)
               {
                  _loc4_ += (1 - _loc4_) * 0.5;
               }
               else if(url.indexOf("/scene/snow/") >= 0 || url.indexOf("/heraldry/") >= 0 || url.indexOf("/achievement/") >= 0 || url.indexOf("magic_bridge_atlas.png") >= 0 || url == "common/mouse/mouse_cursor.png")
               {
                  _loc4_ = 1;
               }
               _loc5_ = Math.max(1,_loc3_.height * _loc4_);
               _loc6_ = Math.max(1,_loc3_.width * _loc4_);
               this.scaleX = _loc3_.width / _loc6_;
               this.scaleY = _loc3_.height / _loc5_;
               this.m_bmpd = new BitmapData(_loc6_,_loc5_,_loc3_.transparent,0);
               _loc7_ = new Matrix();
               _loc7_.scale(1 / this.scaleX,1 / this.scaleY);
               _loc2_.smoothing = true;
               BitmapUtil.drawWithQuality(this.m_bmpd,_loc2_,_loc7_,null,null,null,true,StageQuality.BEST);
               this.numBmpdBytes = this.m_bmpd.width * this.m_bmpd.height * 4;
               if(ResourceCache.ENABLED && m_engineResourceManager.cache && Boolean(cacheId))
               {
                  disableCacheLoad = false;
                  _loc8_ = new ByteArray();
                  _loc8_.writeUnsignedInt(CACHE_HEADER);
                  _loc8_.writeInt(this.m_bmpd.width);
                  _loc8_.writeInt(this.m_bmpd.height);
                  _loc8_.writeFloat(this.scaleX);
                  _loc8_.writeFloat(this.scaleY);
                  _loc8_.writeBoolean(this.m_bmpd.transparent);
                  this.m_bmpd.copyPixelsToByteArray(this.m_bmpd.rect,_loc8_);
                  m_engineResourceManager.cache.putInCache(cacheId,url,_loc8_);
                  _loc8_.clear();
               }
            }
            else
            {
               this.m_bmpd = _loc3_.clone();
               _loc9_ = resourceManager.getTextureOriginalSize(url);
               if(_loc9_)
               {
                  this.scaleX = _loc9_.x / this.m_bmpd.width;
                  this.scaleY = _loc9_.y / this.m_bmpd.height;
               }
            }
            _loc3_.dispose();
         }
      }
      
      final private function handleLoadFromCache() : void
      {
         var _loc1_:uint = cachedBytes.readUnsignedInt();
         if(_loc1_ != CACHE_HEADER)
         {
            logger.error("Invalid cache entry [" + url + "]");
            this.uncacheAndReload();
            return;
         }
         var _loc2_:int = cachedBytes.readInt();
         var _loc3_:int = cachedBytes.readInt();
         if(_loc2_ == 0 || _loc3_ == 0)
         {
            logger.error("Invalid cache size for [" + url + "] " + _loc2_ + "x" + _loc3_);
            this.uncacheAndReload();
         }
         this.scaleX = cachedBytes.readFloat();
         this.scaleY = cachedBytes.readFloat();
         this.transparent = cachedBytes.readBoolean();
         this.m_bmpd = new BitmapData(_loc2_,_loc3_,this.transparent,0);
         this.m_bmpd.setPixels(this.m_bmpd.rect,cachedBytes);
         cachedBytes.clear();
         cachedBytes = null;
      }
      
      private function uncacheAndReload() : void
      {
         logger.info("Uncaching [" + url + "]");
         disableCacheLoad = true;
         if(m_engineResourceManager.cache)
         {
            m_engineResourceManager.cache.removeFromCache(cacheId,m_url,true);
         }
         if(cachedBytes)
         {
            cachedBytes.clear();
            cachedBytes = null;
         }
         forceReload = true;
      }
      
      override protected function internalOnLoadComplete() : void
      {
         if(this.isRestoring)
         {
            this.restoreCount = this.restoreCount - 1;
            if(this.restoreCount > 0)
            {
               this.uncacheAndReload();
               return;
            }
            this.isRestoring = false;
         }
         if(this.m_bmpd)
         {
            return;
         }
         var _loc1_:IResourceLoader = loader as IResourceLoader;
         if(Boolean(_loc1_) && _loc1_.data)
         {
            this.handleLoadFromDisplayLoader();
         }
         if(cachedBytes)
         {
            this.handleLoadFromCache();
         }
         if(Boolean(this._texture) && Boolean(this.m_bmpd))
         {
            this._texture.root.uploadBitmapData(this.m_bmpd);
            this.m_bmpd.dispose();
            this.m_bmpd = null;
            this.numBmpdBytes = 0;
         }
      }
      
      override protected function internalOnLoadedAllComplete() : void
      {
         releaseLoader();
      }
      
      public function getWrapper() : DisplayObjectWrapper
      {
         var _loc1_:Image = null;
         var _loc2_:Bitmap = null;
         if(PlatformStarling.instance)
         {
            _loc1_ = this.getImage();
            return new DisplayObjectWrapperStarling(_loc1_);
         }
         _loc2_ = this.bmp;
         return new DisplayObjectWrapperFlash(_loc2_);
      }
      
      public function getWrapperRect(param1:Rectangle) : DisplayObjectWrapper
      {
         var _loc2_:Image = null;
         var _loc3_:Bitmap = null;
         if(PlatformStarling.instance)
         {
            _loc2_ = this.getImageRect(param1);
            return new DisplayObjectWrapperStarling(_loc2_);
         }
         _loc3_ = this.getBmpRect(param1);
         return new DisplayObjectWrapperFlash(_loc3_);
      }
      
      public function get bmp() : Bitmap
      {
         var _loc2_:Boolean = false;
         var _loc3_:Bitmap = null;
         var _loc1_:BitmapData = this.bitmapData;
         if(_loc1_)
         {
            _loc2_ = true;
            _loc3_ = new ClickableBitmap(_loc1_,PixelSnapping.AUTO,_loc2_);
            _loc3_.scaleX = this.scaleX;
            _loc3_.scaleY = this.scaleY;
            return _loc3_;
         }
         return null;
      }
      
      public function getTexture() : Texture
      {
         if(!this._texture && Boolean(this.m_bmpd))
         {
            try
            {
               this._texture = Texture.fromBitmapData(this,this.m_bmpd,false);
               this._texture.root.onRestore = this.textureRestoreHandler;
               if(!ResourceManager.BIGMEM)
               {
                  this.numBmpdBytes = 0;
                  this.m_bmpd.dispose();
                  this.m_bmpd = null;
               }
               resourceManager.notifyModified(this);
            }
            catch(e:Error)
            {
               logger.error("BitmapResource.getTexture() failed [" + url + "], textureCount " + Texture.textureCount + ":\n" + e.getStackTrace());
               if(!_textureDebugDumped)
               {
                  _textureDebugDumped = true;
                  logger.error(Texture.debugDump());
               }
               _texture = null;
            }
         }
         return this._texture;
      }
      
      private function textureRestoreHandler() : void
      {
         if(!this._texture)
         {
            logger.debug("BitmapResource.textureRestoreHandler [" + url + "]: no texture");
            return;
         }
         if(logger.isDebugEnabled)
         {
            logger.debug("BitmapResource.textureRestoreHandler [" + url + "] ok=" + ok);
         }
         if(this.isRestoring)
         {
            this.restoreCount += 1;
            return;
         }
         this.isRestoring = true;
         this.restoreCount = 1;
         load();
      }
      
      public function getImage() : Image
      {
         var _loc1_:Image = new Image(this.getTexture());
         _loc1_.scaleX = this.scaleX;
         _loc1_.scaleY = this.scaleY;
         _loc1_.touchable = false;
         return _loc1_;
      }
      
      public function get bitmapData() : BitmapData
      {
         return this.m_bmpd;
      }
      
      public function getTextureRect(param1:Rectangle) : Texture
      {
         var _loc3_:Texture = null;
         var _loc2_:Texture = this.getTexture();
         if(!param1)
         {
            return _loc2_;
         }
         if(this._textureRects)
         {
            _loc3_ = this._textureRects[param1];
         }
         else
         {
            this._textureRects = new Dictionary();
         }
         if(!_loc3_)
         {
            _loc3_ = Texture.fromTexture(this,this._texture,param1);
         }
         this._textureRects[param1] = _loc3_;
         return _loc3_;
      }
      
      public function getBmpRect(param1:Rectangle) : Bitmap
      {
         var _loc3_:BitmapData = null;
         if(!param1)
         {
            return this.bmp;
         }
         var _loc2_:BitmapData = this.bitmapData;
         if(_loc2_)
         {
            _loc3_ = new BitmapData(param1.width,param1.height);
            _loc3_.copyPixels(_loc2_,param1,new Point(0,0));
            return new Bitmap(_loc3_);
         }
         return null;
      }
      
      public function getImageRect(param1:Rectangle) : Image
      {
         var _loc3_:Image = null;
         var _loc2_:Texture = this.getTextureRect(param1);
         if(_loc2_)
         {
            _loc3_ = new Image(_loc2_);
            _loc3_.scaleX = this.scaleX;
            _loc3_.scaleY = this.scaleY;
            _loc3_.touchable = false;
            return _loc3_;
         }
         return null;
      }
      
      override public function unloadBigmem() : Boolean
      {
         this._unloadTextures();
         return true;
      }
      
      override protected function internalUnload() : void
      {
         if(this.m_bmpd)
         {
            this.m_bmpd.dispose();
            this.m_bmpd = null;
            this.numBmpdBytes = 0;
         }
         this._unloadTextures();
      }
      
      private function _unloadTextures() : void
      {
         var _loc1_:Texture = null;
         if(this._textureRects)
         {
            for each(_loc1_ in this._textureRects)
            {
               _loc1_.root.onRestore = null;
               if(PlatformStarling.isContextValid)
               {
                  _loc1_.dispose();
               }
               else if(!AppInfo.terminating)
               {
                  logger.info("BitmapResource._unloadTextures orphaning texture rect for " + this);
                  orphanedTextures.push(_loc1_);
               }
            }
         }
         if(this._texture)
         {
            this._texture.root.onRestore = null;
            if(PlatformStarling.isContextValid)
            {
               this._texture.dispose();
            }
            else if(!AppInfo.terminating)
            {
               logger.info("BitmapResource._unloadTextures orphaning texture for " + this);
               orphanedTextures.push(this._texture);
            }
         }
         this._texture = null;
         this._textureRects = null;
      }
      
      override public function get resource() : *
      {
         return this.bmp;
      }
      
      override public function get numBytes() : int
      {
         return super.numBytes + this.numBmpdBytes;
      }
      
      override public function get canUnloadResource() : Boolean
      {
         return true;
      }
      
      override protected function canProcessLoadCompletion() : Boolean
      {
         if(Boolean(PlatformStarling.instance) && !PlatformStarling.isContextValid)
         {
            return false;
         }
         return true;
      }
   }
}
