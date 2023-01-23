package engine.resource
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.anim.def.AnimClipChildDef;
   import engine.anim.def.AnimClipDef;
   import engine.anim.def.AnimFrame;
   import engine.anim.view.AnimClip;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.anim.view.XAnimClipSpriteFlash;
   import engine.anim.view.XAnimClipSpriteStarling;
   import engine.core.util.StringUtil;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.resource.loader.IResourceLoader;
   import engine.resource.loader.IResourceLoaderListener;
   import engine.resource.loader.URLResourceLoader;
   import flash.utils.ByteArray;
   
   public class AnimClipResource extends URLResource implements ILoaderFactory
   {
      
      public static var CACHE_ID:String = "anim";
      
      public static var instances:Vector.<AnimClipResource> = new Vector.<AnimClipResource>();
       
      
      public var clipDef:AnimClipDef;
      
      private var bagr:AnimClipBagResource;
      
      private var clipId:String;
      
      public function AnimClipResource(param1:String, param2:ResourceManager, param3:ILoaderFactory = null)
      {
         instances.push(this);
         super(param1,param2,param3 != null ? param3 : this);
         if(!StringUtil.endsWith(param1,".clip") && !StringUtil.endsWith(param1,".clipq"))
         {
            throw new ArgumentError("Bad clip url [" + param1 + "]");
         }
      }
      
      override public function loaderFactoryHandler(param1:String, param2:IResourceLoaderListener) : IResourceLoader
      {
         return new URLResourceLoader(param1,param2,logger,true,true);
      }
      
      override public function load() : void
      {
         if(!url)
         {
            return;
         }
         if(!StringUtil.endsWith(url,".clipq"))
         {
            super.load();
            return;
         }
         this.clipId = StringUtil.getBasename(url);
         var _loc1_:* = StringUtil.getFolder(url) + ".clips";
         this.bagr = resourceManager.getResource(_loc1_,AnimClipBagResource) as AnimClipBagResource;
         this.bagr.addResourceListener(this.bagrHandler);
      }
      
      private function bagrHandler(param1:ResourceLoadedEvent) : void
      {
         this.bagr.removeResourceListener(this.bagrHandler);
         handleLoadCompletion();
      }
      
      private function getReducedSheetFromCache() : Boolean
      {
         var reducedOk:Boolean = false;
         var reduced:ByteArray = null;
         if(ResourceCache.ENABLED && Boolean(m_engineResourceManager.cache))
         {
            if(Platform.qualityTextures < 1)
            {
               reduced = m_engineResourceManager.cache.getFromCache(CACHE_ID,url);
               if(reduced)
               {
                  try
                  {
                     reducedOk = this.clipDef.consumeReducedSheet(reduced,0,logger);
                  }
                  catch(e:Error)
                  {
                     logger.error("internalOnLoadComplete failed reducing:\n" + e.getStackTrace());
                     reducedOk = false;
                  }
                  reduced.clear();
                  reduced = null;
               }
            }
         }
         return reducedOk;
      }
      
      private function putReducedSheetInCache() : void
      {
         var _loc1_:ByteArray = this.reduceSheet();
         if(ResourceCache.ENABLED && Boolean(m_engineResourceManager.cache))
         {
            if(_loc1_)
            {
               m_engineResourceManager.cache.putInCache(CACHE_ID,url,_loc1_);
               _loc1_.clear();
               _loc1_ = null;
            }
         }
      }
      
      override protected function internalOnLoadComplete() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:ByteArray = null;
         var _loc3_:* = false;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:AnimClipChildDef = null;
         super.internalOnLoadComplete();
         if(this.bagr)
         {
            if(this.bagr.bag)
            {
               this.clipDef = this.bagr.bag.getClipDefById(this.clipId);
               if(!this.clipDef)
               {
                  logger.error("AnimClipResource [" + url + "] not found in bag [" + this.bagr.url + "]");
               }
            }
         }
         else if(data && Boolean(data.bytesAvailable))
         {
            this.clipDef = new AnimClipDef(logger);
            this.clipDef.readBytes(data);
            if(this.clipDef.hasSheet)
            {
               _loc1_ = this.getReducedSheetFromCache();
               if(!_loc1_)
               {
                  _loc2_ = loader.data as ByteArray;
                  _loc3_ = url.indexOf("common/locale") < 0;
                  _loc4_ = true;
                  if(url.indexOf(".portrait.") > 0)
                  {
                     _loc4_ = false;
                  }
                  else if(url.indexOf("/caravan/") > 0)
                  {
                     _loc4_ = false;
                  }
                  else if(url.indexOf("saga3/vfx/flames_simple") == 0)
                  {
                     _loc4_ = false;
                  }
                  this.clipDef.consumeSheet(_loc2_,_loc2_.position,logger,_loc3_,_loc4_,this.clipConsumptionCompleteCallback);
                  if(!this.clipDef.consumptionComplete)
                  {
                     inhibitFinishing = true;
                  }
                  else
                  {
                     this.putReducedSheetInCache();
                  }
               }
            }
         }
         if(this.clipDef)
         {
            _loc5_ = 0;
            while(_loc5_ < this.clipDef.aframes.numChildren)
            {
               _loc6_ = this.clipDef.aframes.getClipChild(_loc5_);
               addChild(_loc6_.url,AnimClipResource);
               _loc5_++;
            }
         }
      }
      
      private function clipConsumptionCompleteCallback(param1:AnimClipDef) : void
      {
         inhibitFinishing = false;
      }
      
      private function reduceSheet() : ByteArray
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
         while(_loc3_ < this.clipDef.aframes.frames.length)
         {
            _loc5_ = this.clipDef.aframes.frames[_loc3_];
            if(_loc5_.frameNum == _loc3_ && !_loc5_.shared)
            {
               if(_loc5_._compressedBitmapData)
               {
                  _loc1_.writeInt(_loc5_.frameNum);
                  _loc6_ = _loc2_.length;
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
      
      override protected function internalOnLoadedAllComplete() : void
      {
         var _loc1_:int = 0;
         var _loc2_:AnimClipChildDef = null;
         var _loc3_:AnimClipResource = null;
         if(this.clipDef)
         {
            _loc1_ = 0;
            while(_loc1_ < this.clipDef.aframes.numChildren)
            {
               _loc2_ = this.clipDef.aframes.getClipChild(_loc1_);
               _loc3_ = resourceManager.getResource(_loc2_.url,AnimClipResource) as AnimClipResource;
               _loc2_.clip = _loc3_.clipDef;
               _loc3_.release();
               _loc1_++;
            }
         }
      }
      
      override public function get error() : Boolean
      {
         return super.error;
      }
      
      override protected function internalUnload() : void
      {
         if(this.bagr)
         {
            this.bagr.removeResourceListener(this.bagrHandler);
            this.bagr.release();
            this.bagr = null;
         }
         else if(this.clipDef)
         {
            this.clipDef.cleanup();
            this.clipDef = null;
         }
         var _loc1_:int = instances.indexOf(this);
         if(_loc1_ >= 0)
         {
            instances.splice(_loc1_,1);
         }
      }
      
      public function get _animClipSpriteFlash() : XAnimClipSpriteFlash
      {
         var _loc1_:AnimClip = this.clip;
         return new XAnimClipSpriteFlash(null,_loc1_,this.logger,true);
      }
      
      public function get _animClipSpriteStarling() : XAnimClipSpriteStarling
      {
         var _loc1_:AnimClip = this.clip;
         return new XAnimClipSpriteStarling(null,_loc1_,this.logger,true);
      }
      
      public function get animClipSprite() : XAnimClipSpriteBase
      {
         if(PlatformStarling.instance)
         {
            return this._animClipSpriteStarling;
         }
         return this._animClipSpriteFlash;
      }
      
      override public function get resource() : *
      {
         var _loc1_:XAnimClipSpriteFlash = null;
         if(this.clipDef)
         {
            _loc1_ = this._animClipSpriteFlash;
            _loc1_.clip.start(0);
            return _loc1_;
         }
         return null;
      }
      
      public function get clip() : AnimClip
      {
         return new AnimClip(this.clipDef,null,null,logger);
      }
      
      override public function get numBytes() : int
      {
         if(this.clipDef)
         {
            return this.clipDef.numBytes + super.numBytes;
         }
         return super.numBytes;
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
