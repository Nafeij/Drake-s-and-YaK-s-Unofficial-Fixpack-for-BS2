package engine.resource
{
   import engine.core.locale.LocaleId;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.Refcount;
   import engine.core.util.StringUtil;
   import engine.resource.event.ResourceLoadedEvent;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class ResourceManager implements IResourceManager
   {
      
      public static var videoURLTransform:IVideoFinder;
      
      public static var BIGMEM:Boolean;
      
      public static var LOADER_PROCESSING_FRAMELIMIT_MS:int = 50;
      
      public static var LOADER_PROCESSING_DELAY:int = 0;
       
      
      private var m_assetIndex:AssetIndex;
      
      private var m_logger:ILogger;
      
      private var m_resources:Dictionary;
      
      private var m_assetPath:String;
      
      private var monitors:Vector.<ResourceMonitor>;
      
      private var loaderFactoryFuncs:Dictionary;
      
      public var keepResourceUrls:Dictionary;
      
      public var modificationStamp:int;
      
      public var localeId:LocaleId;
      
      public var remapping:Dictionary;
      
      public var cache:ResourceCache;
      
      public var textureSizes:ResourceTextureSizes;
      
      public var resourceErrorCallback:Function;
      
      public var censor:ResourceCensor;
      
      private var consoleCache:ConsoleResourceCache;
      
      private var _loaderCompletedResources:Vector.<Resource>;
      
      private var _loading_processing_delay_elapsed:int;
      
      public function ResourceManager(param1:AssetIndex, param2:String, param3:LocaleId, param4:ILogger, param5:ResourceCache, param6:ResourceTextureSizes, param7:ResourceCensor)
      {
         this.m_resources = new Dictionary();
         this.monitors = new Vector.<ResourceMonitor>();
         this.loaderFactoryFuncs = new Dictionary();
         this.keepResourceUrls = new Dictionary();
         this.remapping = new Dictionary();
         this._loaderCompletedResources = new Vector.<Resource>();
         super();
         this.censor = param7;
         this.localeId = param3;
         this.m_assetIndex = param1;
         this.m_assetPath = param2 != null ? param2 : "";
         this.cache = param5;
         this.textureSizes = param6;
         this.consoleCache = new ConsoleResourceCache(this,this.unloadResource,param4);
         if(this.m_assetPath)
         {
            if(this.m_assetPath.charAt(this.m_assetPath.length - 1) != "/")
            {
               this.m_assetPath += "/";
            }
         }
         this.m_logger = param4;
      }
      
      public function addRemapping(param1:String, param2:String) : Boolean
      {
         if(param1 in this.remapping)
         {
            return false;
         }
         this.remapping[param1] = param2;
         return true;
      }
      
      public function notifyModified(param1:Resource) : void
      {
         ++this.modificationStamp;
         if(param1.error)
         {
            if(this.resourceErrorCallback != null)
            {
               this.resourceErrorCallback(param1.url);
            }
         }
         this.consoleCache.modifyResourceSize(param1);
      }
      
      public function addKeepResourceUrls(param1:Array) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in param1)
         {
            this.keepResourceUrls[_loc2_] = _loc2_;
         }
      }
      
      public function registerLoaderFactoryFunc(param1:Class, param2:Function) : void
      {
         this.loaderFactoryFuncs[param1] = param2;
      }
      
      public function getResource(param1:String, param2:Class, param3:IResourceGroup = null, param4:Function = null, param5:Boolean = false) : IResource
      {
         var _loc9_:String = null;
         var _loc10_:Resource = null;
         if(!param1)
         {
            throw new ArgumentError("Bad url [" + param1 + "] for clazz " + param2);
         }
         if(!this.m_assetPath)
         {
            throw new ArgumentError("No such resource manager for [" + param1 + "]");
         }
         var _loc6_:String = param1;
         ResourceCollector.collectUrl(param1);
         if(this.censor)
         {
            _loc9_ = this.censor.getCensoredUrl(param1);
            if(Boolean(_loc9_) && _loc9_ != param1)
            {
               this.logger.i("CENS","Replace [" + param1 + "] with [" + _loc9_ + "]");
               param1 = _loc9_;
               ResourceCollector.collectUrl(param1);
            }
         }
         if(param4 == null)
         {
            param4 = this.loaderFactoryFuncs[param2];
         }
         var _loc7_:ResourceGroup = param3 as ResourceGroup;
         if(_loc7_)
         {
            _loc10_ = _loc7_.getResource(param1);
            if(_loc10_)
            {
               this.noticeMonitoring(_loc10_);
               return _loc10_;
            }
         }
         var _loc8_:Resource = this.m_resources[param1];
         if(null == _loc8_)
         {
            _loc8_ = new param2(param1,this,param4);
            _loc8_.refcount.addReference();
            this.m_resources[param1] = _loc8_;
            _loc8_.unrequired = param5;
            _loc8_.load();
            this.notifyModified(_loc8_);
         }
         else
         {
            _loc8_.refcount.addReference();
         }
         if(!(_loc8_ as param2))
         {
            throw new ArgumentError("resource " + param1 + " already exists as " + getQualifiedClassName(_loc8_) + ", not " + param2);
         }
         _loc8_.refcount.addEventListener(Event.UNLOAD,this.resourceUnloadHandler);
         if(_loc7_)
         {
            _loc7_.addResource(_loc8_,_loc6_);
         }
         this.noticeMonitoring(_loc8_);
         this.consoleCache.addResource(_loc8_);
         return _loc8_;
      }
      
      private function noticeMonitoring(param1:Resource) : void
      {
         var _loc2_:ResourceMonitor = null;
         for each(_loc2_ in this.monitors)
         {
            _loc2_.addResource(param1);
         }
      }
      
      public function addMonitor(param1:ResourceMonitor) : void
      {
         if(!param1)
         {
            throw new ArgumentError("null monitor");
         }
         this.monitors.push(param1);
         param1.addResourceManager(this);
      }
      
      public function removeMonitor(param1:ResourceMonitor) : void
      {
         var _loc2_:int = this.monitors.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.monitors.splice(_loc2_,1);
            param1.removeResourceManager(this);
         }
      }
      
      protected function resourceUnloadHandler(param1:Event) : void
      {
         var _loc2_:Refcount = param1.target as Refcount;
         var _loc3_:Resource = _loc2_.owner as Resource;
         this.unloadResource(_loc3_);
      }
      
      private function unloadResource(param1:Resource) : void
      {
         var _loc3_:ResourceMonitor = null;
         var _loc4_:Event = null;
         var _loc5_:Event = null;
         if(AppInfo.terminating)
         {
            return;
         }
         if(param1.refcount.refcount != 0)
         {
            this.logger.error("Attempt to unload resource " + param1 + " with refcount " + param1.refcount.refcount);
         }
         this.notifyModified(param1);
         if(param1.url in this.keepResourceUrls)
         {
            return;
         }
         if(!param1.canUnloadResource)
         {
            return;
         }
         if(param1.isInConsoleCache() && param1.consoleCacheState != Resource.CONSOLE_CACHE_STATE__SHOULD_BE_REMOVED && param1.ok && !this.consoleCache.isOverfull())
         {
            return;
         }
         if(ConsoleResourceCache.DEBUG_LOGS)
         {
            if(param1.isInConsoleCache() && param1.consoleCacheState != Resource.CONSOLE_CACHE_STATE__SHOULD_BE_REMOVED && param1.ok)
            {
               this.logger.info("Console Resource Cache: Unloading resource normally because cache is overfull. Cache Size: {0}, Url: {1}",this.consoleCache.numBytes,param1);
            }
         }
         if(Resource.FORCE_CAN_UNLOAD)
         {
            this.logger.info("ResourceManager UNLOADING " + param1);
         }
         param1.refcount.removeEventListener(Event.UNLOAD,this.resourceUnloadHandler);
         var _loc2_:Vector.<ResourceMonitor> = this.monitors.concat();
         for each(_loc3_ in _loc2_)
         {
            _loc3_.removeResource(param1);
         }
         if(param1.tree)
         {
            param1.tree.release();
         }
         if(param1.hasEventListener(Event.COMPLETE) || param1.hasEventListener(Event.UNLOAD))
         {
            this.logger.error("somebody still listens to " + param1);
            _loc4_ = new ResourceLoadedEvent(Event.COMPLETE,param1);
            _loc5_ = new Event(Event.UNLOAD);
            param1.dispatchEvent(_loc4_);
            param1.dispatchEvent(_loc5_);
         }
         if(BIGMEM)
         {
            if(param1.unloadBigmem())
            {
               return;
            }
         }
         this.consoleCache.removeResource(param1);
         param1.unload();
         delete this.m_resources[param1.url];
      }
      
      public function releaseResource(param1:Resource) : void
      {
         param1.refcount.releaseReference();
      }
      
      public function get logger() : ILogger
      {
         return this.m_logger;
      }
      
      public function get assetPath() : String
      {
         return this.m_assetPath;
      }
      
      public function getRelativeUrl(param1:String) : String
      {
         if(param1.indexOf(this.assetPath) == 0)
         {
            return param1.substring(this.assetPath.length);
         }
         return param1;
      }
      
      internal function getFullUrl(param1:String) : String
      {
         var _loc3_:String = null;
         if(param1.indexOf("file://") == 0 || param1.indexOf("http://") == 0 || param1.indexOf("https://") == 0)
         {
            return param1;
         }
         if(null != this.m_assetIndex)
         {
            _loc3_ = this.m_assetIndex.getHashUrlFromPath(param1);
            if(_loc3_)
            {
               return this.assetPath + _loc3_;
            }
         }
         var _loc2_:String = this.remapping[param1];
         if(_loc2_)
         {
            return _loc2_;
         }
         return this.assetPath + param1;
      }
      
      public function getVideoUrl(param1:String) : String
      {
         var _loc2_:String = null;
         if(videoURLTransform != null)
         {
            _loc2_ = videoURLTransform.getVideoUrl(param1);
            this.logger.info("Transformed video URL from " + param1 + " to " + _loc2_);
            return _loc2_;
         }
         return this.assetPath + param1;
      }
      
      public function releaseVideoUrl(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(videoURLTransform != null)
         {
            videoURLTransform.releaseVideoUrl(param1);
         }
      }
      
      public function report(param1:String) : String
      {
         var _loc5_:Resource = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:String = "";
         var _loc3_:int = 75;
         var _loc4_:int = 0;
         for each(_loc5_ in this.m_resources)
         {
            if(param1)
            {
               if(_loc5_.url.indexOf(param1) < 0)
               {
                  continue;
               }
            }
            _loc7_ = _loc5_.numBytes;
            _loc4_ += _loc7_;
            _loc8_ = _loc7_ / 1024;
            this.logger.info(StringUtil.padRight(_loc5_.url," ",_loc3_) + " " + StringUtil.padLeft(_loc8_.toString()," ",6) + " kB #" + _loc5_.refcount.refcount);
            _loc2_ += _loc5_.url + "\t" + _loc8_ + "\t" + _loc5_.refcount.refcount + "\n";
         }
         _loc6_ = _loc4_ / 1024;
         this.logger.info(StringUtil.padRight("TOTAL"," ",_loc3_) + " " + StringUtil.padLeft(_loc6_.toString()," ",6) + " kB");
         return _loc2_;
      }
      
      public function setLoaderCompleted(param1:Resource) : void
      {
         this._loaderCompletedResources.push(param1);
      }
      
      public function update(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Resource = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(LOADER_PROCESSING_DELAY)
         {
            this._loading_processing_delay_elapsed += param1;
            if(this._loading_processing_delay_elapsed <= LOADER_PROCESSING_DELAY)
            {
               return;
            }
            this._loading_processing_delay_elapsed = 0;
         }
         var _loc2_:int = this._loaderCompletedResources.length;
         if(_loc2_)
         {
            _loc3_ = getTimer();
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc5_ = this._loaderCompletedResources[_loc4_];
               if(!_loc5_.processLoadCompletion())
               {
                  this._loaderCompletedResources.push(_loc5_);
               }
               else
               {
                  _loc6_ = getTimer();
                  _loc7_ = _loc6_ - _loc3_;
                  if(_loc7_ > LOADER_PROCESSING_FRAMELIMIT_MS)
                  {
                     _loc4_++;
                     break;
                  }
               }
               _loc4_++;
            }
            this._loaderCompletedResources.splice(0,_loc4_);
         }
         if(this.cache)
         {
            this.cache.update(param1,this.modificationStamp);
         }
      }
      
      public function getTextureOriginalSize(param1:String) : Point
      {
         return !!this.textureSizes ? this.textureSizes.getOriginalSize(param1) : null;
      }
      
      public function purgeUnreferencedResources() : void
      {
         var _loc2_:* = null;
         var _loc3_:Resource = null;
         var _loc1_:Vector.<Resource> = new Vector.<Resource>();
         for(_loc2_ in this.m_resources)
         {
            _loc3_ = this.m_resources[_loc2_];
            if(Boolean(_loc3_) && _loc3_.refcount.refcount == 0)
            {
               _loc1_.push(_loc3_);
            }
         }
         Resource.FORCE_CAN_UNLOAD = true;
         for each(_loc3_ in _loc1_)
         {
            if(Boolean(_loc3_) && !_loc3_.unloaded)
            {
               this.logger.info("purgeUnreferencedResources " + _loc3_);
               this.unloadResource(_loc3_);
            }
         }
         Resource.FORCE_CAN_UNLOAD = false;
      }
      
      public function peekResource(param1:String) : Resource
      {
         return this.m_resources[param1];
      }
      
      public function listResources(param1:Class) : Vector.<Resource>
      {
         var _loc3_:* = null;
         var _loc4_:Resource = null;
         var _loc2_:Vector.<Resource> = new Vector.<Resource>();
         for(_loc3_ in this.m_resources)
         {
            _loc4_ = this.m_resources[_loc3_];
            if(param1 == null || Boolean(_loc4_ as param1))
            {
               _loc2_.push(_loc4_);
            }
         }
         return _loc2_;
      }
      
      public function get censorId() : String
      {
         return !!this.censor ? this.censor.id : null;
      }
      
      public function getLocaleId() : LocaleId
      {
         return this.localeId;
      }
   }
}
