package engine.resource
{
   import engine.core.logging.ILogger;
   import engine.core.logging.Log;
   import engine.core.util.Refcount;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.resource.loader.IResourceLoader;
   import engine.resource.loader.IResourceLoaderListener;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class Resource extends EventDispatcher implements IResource, IResourceLoaderListener
   {
      
      public static var DEBUG_RESOURCES:Boolean;
      
      public static var FORCE_CAN_UNLOAD:Boolean;
      
      public static var globalResourceTimingsByClass:Dictionary = new Dictionary();
      
      public static const CONSOLE_CACHE_STATE__NOT_IN_CACHE:int = 0;
      
      public static const CONSOLE_CACHE_STATE__LOADING:int = 1;
      
      public static const CONSOLE_CACHE_STATE__LOADED:int = 2;
      
      public static const CONSOLE_CACHE_STATE__SHOULD_BE_REMOVED:int = 3;
      
      public static var IMMEDIATE_PROCESS_LOAD_COMPLETION:Boolean;
       
      
      protected var m_url:String;
      
      private var m_loaded:Boolean;
      
      public var did_load:Boolean;
      
      private var m_loader:IResourceLoader;
      
      protected var m_engineResourceManager:ResourceManager;
      
      private var m_refcount:Refcount;
      
      private var m_loaderFactory:ILoaderFactory;
      
      private var m_tree:ResourceTree;
      
      private var m_error:Boolean;
      
      public var cacheId:String;
      
      public var cachedBytes:ByteArray;
      
      public var disableCacheLoad:Boolean;
      
      private var timingStart:int;
      
      private var timingLoading:int;
      
      private var timingProcessing:int;
      
      private var timingComplete:int;
      
      protected var _unrequired:Boolean;
      
      public var consoleCacheState:int = 0;
      
      public var consoleCacheNumBytes:int = 0;
      
      public var consoleCacheNumMutexes:int = 0;
      
      private var _finishing:Boolean;
      
      public var unloaded:Boolean;
      
      protected var forceReload:Boolean;
      
      private var _inhibitFinishing:Boolean;
      
      private var _finishingInhibited:Boolean;
      
      public function Resource(param1:String, param2:ResourceManager, param3:ILoaderFactory, param4:String = null)
      {
         this.m_refcount = new Refcount(this);
         super();
         if(null == param3)
         {
            throw new ArgumentError("need a loader factory");
         }
         if(null == param2)
         {
            throw new ArgumentError("Need a resource manager");
         }
         if(null == param1)
         {
            param2.logger.error("not really a good url, fool, for " + this);
         }
         if(param1.indexOf("*") >= 0)
         {
            throw new ArgumentError("Don\'t load urls with wildcards -- expand them first [" + param1 + "]");
         }
         this.timingStart = getTimer();
         this.cacheId = param4;
         this.m_url = param1;
         this.m_engineResourceManager = param2;
         this.m_loaderFactory = param3;
      }
      
      private static function addGlobalResourceTiming(param1:String, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:TimingInfo = globalResourceTimingsByClass[param1];
         if(!_loc5_)
         {
            _loc5_ = new TimingInfo(param1);
            globalResourceTimingsByClass[param1] = _loc5_;
         }
         _loc5_.add(param2,param3,param4);
      }
      
      public static function reportGlobalResourceTiming(param1:ILogger) : void
      {
         var _loc3_:TimingInfo = null;
         var _loc4_:* = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc2_:Array = [];
         for(_loc4_ in globalResourceTimingsByClass)
         {
            _loc3_ = globalResourceTimingsByClass[_loc4_];
            _loc2_.push({
               "short":_loc3_.clazzNameShort,
               "long":_loc4_
            });
         }
         _loc2_.sortOn("short");
         TimingInfo.header(param1);
         for each(_loc10_ in _loc2_)
         {
            _loc3_ = globalResourceTimingsByClass[_loc10_.long];
            _loc3_.report(param1);
            _loc5_ += _loc3_.totalDurationLoad;
            _loc6_ += _loc3_.totalDurationComplete;
            _loc7_ += _loc3_.totalDurationProcess;
            _loc9_ += _loc3_.count;
            _loc8_ = Math.max(_loc8_,_loc3_.maxDurationComplete);
         }
         TimingInfo.reportOne(param1,_loc5_,_loc6_,_loc7_,_loc8_,"TOTAL",_loc9_);
      }
      
      public function set unrequired(param1:Boolean) : void
      {
         this._unrequired = param1;
         if(this.m_loader)
         {
            this.m_loader.unrequired = param1;
         }
      }
      
      override public function toString() : String
      {
         return this.m_url;
      }
      
      public function get url() : String
      {
         return this.m_url;
      }
      
      public function load() : void
      {
         this.loadFromUrl();
      }
      
      protected function internalOnLoadedAllComplete() : void
      {
      }
      
      protected function handleFinishing() : void
      {
         this.loaded = true;
      }
      
      final public function setFinishing() : void
      {
         if(this._inhibitFinishing)
         {
            this._finishingInhibited = true;
            return;
         }
         if(this.logger.isDebugEnabled)
         {
         }
         if(this._finishing || this.m_loaded)
         {
            throw new IllegalOperationError("setFinishing invalid " + this.url);
         }
         this._finishing = true;
         this.handleFinishing();
      }
      
      private function get loaded() : Boolean
      {
         return this.m_loaded;
      }
      
      private function set loaded(param1:Boolean) : void
      {
         var b:Boolean = param1;
         if(!this.m_loaded && b)
         {
            if(this.logger.isDebugEnabled)
            {
               if(DEBUG_RESOURCES)
               {
                  this.logger.debug("Resource.loaded " + this.url);
               }
            }
            this._finishing = false;
            this.did_load = b;
            this.m_loaded = b;
            try
            {
               this.internalOnLoadedAllComplete();
            }
            catch(e:Error)
            {
               m_error = true;
               logger.error("Failure while finishing load " + url + " " + e.getStackTrace());
            }
            try
            {
               dispatchEvent(new ResourceLoadedEvent(Event.COMPLETE,this));
            }
            catch(e:Error)
            {
               logger.error("Failure while sending complete event for " + url + ":\n" + e.getStackTrace());
            }
            this.resourceManager.notifyModified(this);
         }
      }
      
      public function get loader() : IResourceLoader
      {
         return this.m_loader;
      }
      
      public function get refcount() : Refcount
      {
         return this.m_refcount;
      }
      
      protected function setError() : void
      {
         this.m_error = true;
      }
      
      public function get error() : Boolean
      {
         if(this.m_error)
         {
            return true;
         }
         if(Boolean(this.m_loader) && this.m_loader.error)
         {
            return this.m_loader.error;
         }
         return false;
      }
      
      public function get ok() : Boolean
      {
         return !this.unloaded && this.did_load && !this.error;
      }
      
      public function unloadBigmem() : Boolean
      {
         return false;
      }
      
      final internal function unload() : void
      {
         if(this.unloaded)
         {
            return;
         }
         this.logger.d("RES ","Unload {0}",this.url);
         dispatchEvent(new Event(Event.UNLOAD));
         this.unloaded = true;
         this.internalUnload();
         this.releaseLoader();
         if(null != this.m_tree)
         {
            this.m_tree.release();
            this.m_tree = null;
         }
      }
      
      protected function internalUnload() : void
      {
      }
      
      public function get loaderFactory() : ILoaderFactory
      {
         return this.m_loaderFactory;
      }
      
      protected function loadFromUrl() : void
      {
         var _loc1_:String = this.url;
         if(null != this.m_engineResourceManager)
         {
            _loc1_ = this.m_engineResourceManager.getFullUrl(this.url);
         }
         if(this.cacheId && this.m_engineResourceManager.cache && !this.disableCacheLoad)
         {
            this.cachedBytes = this.m_engineResourceManager.cache.getFromCache(this.cacheId,this.url);
            if(this.cachedBytes)
            {
               this.timingLoading = getTimer() - this.timingStart;
               this.handleLoadCompletion();
               return;
            }
         }
         this.m_loader = this.m_loaderFactory.loaderFactoryHandler(_loc1_,this);
      }
      
      public function get logger() : ILogger
      {
         if(null != this.m_engineResourceManager)
         {
            return this.m_engineResourceManager.logger;
         }
         return Log.getLogger("null");
      }
      
      public function get resourceManager() : ResourceManager
      {
         return this.m_engineResourceManager;
      }
      
      protected function internalOnLoadComplete() : void
      {
      }
      
      public function resourceLoaderCompleteHandler(param1:IResourceLoader) : void
      {
         if(this.logger.isDebugEnabled)
         {
         }
         if(this.m_loaded)
         {
            this.logger.error("Attempting to in-place reload the root of a Resource " + this.url);
            return;
         }
         if(param1.error)
         {
            this.setError();
         }
         this.timingLoading = param1.loadTime;
         this.timingProcessing = param1.processingTime;
         this.handleLoadCompletion();
      }
      
      public function set inhibitFinishing(param1:Boolean) : void
      {
         if(this._inhibitFinishing == param1)
         {
            return;
         }
         this._inhibitFinishing = param1;
         if(!this._inhibitFinishing && this._finishingInhibited)
         {
            this.setFinishing();
         }
      }
      
      final protected function handleLoadCompletion() : void
      {
         if(this.resourceManager)
         {
            if(this.error)
            {
               this.loaded = true;
               return;
            }
            if(IMMEDIATE_PROCESS_LOAD_COMPLETION)
            {
               this.processLoadCompletion();
            }
            else
            {
               this.resourceManager.setLoaderCompleted(this);
            }
         }
      }
      
      protected function canProcessLoadCompletion() : Boolean
      {
         return true;
      }
      
      protected function handleProcessedLoadCompletion() : void
      {
      }
      
      final public function processLoadCompletion() : Boolean
      {
         var _loc1_:Boolean = this.internalProcessLoadCompletion();
         this.handleProcessedLoadCompletion();
         return _loc1_;
      }
      
      private function internalProcessLoadCompletion() : Boolean
      {
         var pstart:int;
         var pend:int = 0;
         var cn:String = null;
         if(Boolean(this.m_refcount) && !this.m_refcount.refcount)
         {
            return true;
         }
         if(!this.canProcessLoadCompletion())
         {
            return false;
         }
         pstart = getTimer();
         try
         {
            this.internalOnLoadComplete();
         }
         catch(e:Error)
         {
            logger.error("Resource.internalProcessLoadCompletion FAIL " + url + ": " + e.message + "\n" + e.getStackTrace);
            setError();
         }
         if(!this.forceReload && !this.timingComplete)
         {
            pend = getTimer();
            this.timingProcessing += pend - pstart;
            this.timingComplete = pend - this.timingStart;
            cn = getQualifiedClassName(this);
            addGlobalResourceTiming(cn,this.timingLoading,this.timingProcessing,this.timingComplete);
         }
         if(this.forceReload)
         {
            this.forceReload = false;
            this.loadFromUrl();
            return true;
         }
         if(this.logger.isDebugEnabled)
         {
         }
         if(this.m_tree)
         {
            this.m_tree.handleRootResourceLoadComplete();
         }
         else
         {
            this.setFinishing();
         }
         return true;
      }
      
      protected function releaseLoader() : void
      {
         if(null != this.m_loader)
         {
            this.m_loader.unload();
            this.m_loader = null;
         }
         this.m_loaded = false;
      }
      
      public function get tree() : ResourceTree
      {
         return this.m_tree;
      }
      
      private function set tree(param1:ResourceTree) : void
      {
         this.m_tree = param1;
      }
      
      protected function addChild(param1:String, param2:Class) : void
      {
         if(!this.m_tree)
         {
            this.m_tree = new ResourceTree(this);
         }
         this.m_tree.addChild(param1,param2);
      }
      
      public function get resource() : *
      {
         return this.loader.data;
      }
      
      public function addResourceListener(param1:Function) : void
      {
         addEventListener(Event.COMPLETE,param1);
         if(this.did_load)
         {
            param1(new ResourceLoadedEvent(Event.COMPLETE,this));
         }
      }
      
      public function removeResourceListener(param1:Function) : void
      {
         removeEventListener(Event.COMPLETE,param1);
      }
      
      public function release() : void
      {
         this.m_refcount.releaseReference();
      }
      
      public function get numBytes() : int
      {
         return !!this.m_loader ? this.m_loader.numBytes : 0;
      }
      
      public function get canUnloadResource() : Boolean
      {
         return FORCE_CAN_UNLOAD;
      }
      
      public function addReference() : void
      {
         this.refcount.addReference();
      }
      
      public function isInConsoleCache() : Boolean
      {
         return this.consoleCacheState != CONSOLE_CACHE_STATE__NOT_IN_CACHE;
      }
   }
}

import engine.core.logging.ILogger;
import engine.core.util.StringUtil;

class TimingInfo
{
    
   
   public var clazzName:String;
   
   public var clazzNameShort:String;
   
   public var count:int;
   
   public var totalDurationLoad:int;
   
   public var totalDurationComplete:int;
   
   public var totalDurationProcess:int;
   
   public var maxDurationComplete:int;
   
   public function TimingInfo(param1:String)
   {
      super();
      this.clazzName = param1;
      var _loc2_:int = param1.indexOf("::");
      if(_loc2_ > 0)
      {
         this.clazzNameShort = param1.substr(_loc2_ + 2);
      }
      else
      {
         this.clazzNameShort = param1;
      }
   }
   
   public static function header(param1:ILogger) : void
   {
      param1.info("\t" + StringUtil.padRight("Class"," ",24) + " \t" + "Count" + " \t" + "tot.load" + " \t" + "tot.proc" + " \t" + "tot.comp" + " \t" + "avg.load" + " \t" + "avg.proc" + " \t" + "avg.comp" + " \t" + "comp.max" + " \t");
   }
   
   public static function reportOne(param1:ILogger, param2:int, param3:int, param4:int, param5:int, param6:String, param7:int) : void
   {
      var _loc8_:int = param2 / param7;
      var _loc9_:int = param3 / param7;
      var _loc10_:int = param4 / param7;
      var _loc11_:String = StringUtil.padRight(param6," ",24);
      var _loc12_:String = StringUtil.padLeft(param7.toString()," ",5);
      var _loc13_:String = StringUtil.padLeft((param2 / 1000).toFixed(1)," ",8);
      var _loc14_:String = StringUtil.padLeft((param3 / 1000).toFixed(1)," ",8);
      var _loc15_:String = StringUtil.padLeft((param4 / 1000).toFixed(1)," ",8);
      var _loc16_:String = StringUtil.padLeft(_loc8_.toFixed(0)," ",8);
      var _loc17_:String = StringUtil.padLeft(_loc9_.toFixed(0)," ",8);
      var _loc18_:String = StringUtil.padLeft(_loc10_.toFixed(0)," ",8);
      var _loc19_:String = StringUtil.padLeft((param5 / 1000).toFixed(1)," ",8);
      param1.info("\t" + _loc11_ + " \t" + _loc12_ + " \t" + _loc13_ + " \t" + _loc15_ + " \t" + _loc14_ + " \t" + _loc16_ + " \t" + _loc18_ + " \t" + _loc17_ + " \t" + _loc19_ + " \t");
   }
   
   public function add(param1:int, param2:int, param3:int) : void
   {
      ++this.count;
      this.totalDurationLoad += param1;
      this.totalDurationComplete += param3;
      this.totalDurationProcess += param2;
      this.maxDurationComplete = Math.max(this.maxDurationComplete,param3);
   }
   
   public function report(param1:ILogger) : void
   {
      reportOne(param1,this.totalDurationLoad,this.totalDurationComplete,this.totalDurationProcess,this.maxDurationComplete,this.clazzNameShort,this.count);
   }
}
