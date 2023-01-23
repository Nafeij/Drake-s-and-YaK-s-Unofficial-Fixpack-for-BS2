package engine.resource
{
   import com.stoicstudio.platform.Platform;
   import engine.anim.def.AnimClipDefBag;
   import engine.core.util.StringUtil;
   import engine.resource.loader.IResourceLoader;
   import engine.resource.loader.IResourceLoaderListener;
   import engine.resource.loader.URLResourceLoader;
   import flash.utils.ByteArray;
   
   public class AnimClipBagResource extends URLResource implements ILoaderFactory
   {
      
      public static var CACHE_ID:String = "anim";
       
      
      public var bag:AnimClipDefBag;
      
      public function AnimClipBagResource(param1:String, param2:ResourceManager, param3:ILoaderFactory = null)
      {
         super(param1,param2,param3 != null ? param3 : this);
         this.cacheId = CACHE_ID;
         if(!StringUtil.endsWith(param1,".clips"))
         {
            throw new ArgumentError("Bad clip bag url [" + param1 + "]");
         }
      }
      
      override public function loaderFactoryHandler(param1:String, param2:IResourceLoaderListener) : IResourceLoader
      {
         return new URLResourceLoader(param1,param2,logger,true,true);
      }
      
      private function loadBag(param1:ByteArray, param2:Boolean) : Boolean
      {
         var ok:Boolean = false;
         var bytes:ByteArray = param1;
         var doReduce:Boolean = param2;
         if(bytes)
         {
            try
            {
               this.bag = new AnimClipDefBag(logger);
               this.bag.url = url;
               logger.d("CLPS","AnimClipBagResource.loadBag {0} loading cache",url);
               this.bag.loadCache(bytes,doReduce,this.bagConsumptionCompleteCallback);
               ok = true;
               if(!this.bag.bagComplete)
               {
                  inhibitFinishing = true;
               }
            }
            catch(e:Error)
            {
               logger.error("AnimClipBagResource.loadBag " + url + " failed:\n" + e.getStackTrace());
               if(bag)
               {
                  bag.cleanup();
               }
               bag = null;
               ok = false;
            }
            bytes.clear();
            bytes = null;
         }
         return ok;
      }
      
      private function bagConsumptionCompleteCallback(param1:AnimClipDefBag) : void
      {
         inhibitFinishing = false;
      }
      
      private function putReducedSheetInCache() : void
      {
         var _loc1_:ByteArray = null;
         if(ResourceCache.ENABLED && Boolean(m_engineResourceManager.cache))
         {
            _loc1_ = this.bag.writeCache();
            if(_loc1_)
            {
               m_engineResourceManager.cache.putInCache(CACHE_ID,url,_loc1_);
               _loc1_.clear();
            }
         }
      }
      
      override protected function internalOnLoadComplete() : void
      {
         var _loc1_:ByteArray = null;
         var _loc2_:Boolean = false;
         super.internalOnLoadComplete();
         if(cachedBytes)
         {
            this.loadBag(cachedBytes,false);
            cachedBytes = null;
         }
         if(!this.bag)
         {
            _loc1_ = data as ByteArray;
            _loc2_ = Platform.qualityTextures < 1 && url.indexOf("common/locale") < 0;
            this.loadBag(_loc1_,_loc2_);
            releaseLoader();
            if(_loc2_)
            {
               this.putReducedSheetInCache();
            }
         }
      }
      
      override public function get error() : Boolean
      {
         return super.error;
      }
      
      override protected function internalUnload() : void
      {
         if(this.bag)
         {
            this.bag.cleanup();
            this.bag = null;
         }
      }
      
      override public function get canUnloadResource() : Boolean
      {
         return true;
      }
   }
}
