package engine.resource
{
   import com.greensock.TweenMax;
   import engine.anim.def.AnimClipDef;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   import engine.resource.def.DefResource;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class ConsoleResourceCache
   {
      
      public static var ENABLED:Boolean = false;
      
      public static var MAX_NUM_BYTES:uint = 100 * 1024 * 1024;
      
      public static var MAX_NUM_MUTEXES:int = -1;
      
      public static var RESOURCE_SIZES_FILE:String = "common/console_resource_cache_sizes.json.z";
      
      public static var PNG_EST_NUM_BYTES:int = 10 * 1024 * 1024;
      
      public static var ANIM_EST_NUM_BYTES:int = 100 * 1024 * 1024;
      
      public static var DEBUG_LOGS:Boolean = false;
      
      public static var DEBUG_CHECK_CACHE_STATE:Boolean = false;
      
      private static var s_resourceSizes:Dictionary;
       
      
      private var m_resources:Vector.<Resource>;
      
      private var m_numBytes:uint = 0;
      
      private var m_numMutexes:int = 0;
      
      private var m_numBytesMax:uint = 0;
      
      private var m_numMutexesMax:int = 0;
      
      private var m_resourceManager:ResourceManager;
      
      private var m_unloadResourceFn:Function;
      
      private var m_logger:ILogger;
      
      public function ConsoleResourceCache(param1:ResourceManager, param2:Function, param3:ILogger)
      {
         this.m_resources = new Vector.<Resource>();
         super();
         this.m_resourceManager = param1;
         this.m_unloadResourceFn = param2;
         this.m_logger = param3;
         if(!s_resourceSizes)
         {
            s_resourceSizes = new Dictionary();
            TweenMax.delayedCall(1,this.initResourceSizes);
         }
      }
      
      private static function isResourceTypeToCache(param1:Resource) : Boolean
      {
         return param1 is BitmapResource || param1 is AnimClipBagResource;
      }
      
      private static function getResourceNumBytesEstimate(param1:Resource) : int
      {
         var _loc2_:ResSize = !!param1 ? s_resourceSizes[param1.url] : null;
         if(_loc2_)
         {
            return _loc2_.numBytes;
         }
         return param1 is AnimClipBagResource ? ANIM_EST_NUM_BYTES : PNG_EST_NUM_BYTES;
      }
      
      private static function getResourceNumBytes(param1:Resource) : int
      {
         var _loc2_:int = 0;
         var _loc3_:AnimClipBagResource = null;
         var _loc4_:AnimClipDef = null;
         if(param1 is AnimClipBagResource)
         {
            _loc2_ = 0;
            _loc3_ = param1 as AnimClipBagResource;
            if(Boolean(_loc3_) && Boolean(_loc3_.bag))
            {
               for each(_loc4_ in _loc3_.bag.clips)
               {
                  _loc2_ += _loc4_.numBytes;
               }
            }
            else
            {
               _loc2_ = _loc3_.numBytes;
            }
            return _loc2_;
         }
         return param1.numBytes;
      }
      
      private static function getResourceNumMutexes(param1:Resource) : int
      {
         var _loc2_:ResSize = null;
         if(param1 is BitmapResource)
         {
            return 0;
         }
         _loc2_ = !!param1 ? s_resourceSizes[param1.url] : null;
         if(_loc2_)
         {
            return _loc2_.numMutexes;
         }
         return 4000;
      }
      
      public function isOverfull() : Boolean
      {
         return this.m_numBytes > MAX_NUM_BYTES || MAX_NUM_MUTEXES >= 0 && this.m_numMutexes > MAX_NUM_MUTEXES;
      }
      
      public function get numBytes() : uint
      {
         return this.m_numBytes;
      }
      
      public function addResource(param1:Resource) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = false;
         var _loc4_:Vector.<Resource> = null;
         var _loc5_:Resource = null;
         var _loc6_:int = 0;
         var _loc7_:Resource = null;
         var _loc8_:int = 0;
         this.checkCacheState(param1);
         if(!ENABLED)
         {
            return;
         }
         if(!param1 || !isResourceTypeToCache(param1))
         {
            return;
         }
         if(param1.isInConsoleCache())
         {
            _loc2_ = this.m_resources.indexOf(param1);
            if(_loc2_ > 0)
            {
               this.m_resources.splice(_loc2_,1);
               this.m_resources.unshift(param1);
            }
            else if(_loc2_ < 0)
            {
               this.m_logger.error("ResourceManager.addResource: Resource not found in cache though it has state {0} {1}",param1.consoleCacheState,param1.url);
            }
         }
         else
         {
            this.m_resources.unshift(param1);
            param1.consoleCacheState = Resource.CONSOLE_CACHE_STATE__LOADING;
            param1.consoleCacheNumBytes = getResourceNumBytesEstimate(param1);
            param1.consoleCacheNumMutexes = getResourceNumMutexes(param1);
            this.m_numBytes += param1.consoleCacheNumBytes;
            this.m_numMutexes += param1.consoleCacheNumMutexes;
            _loc3_ = false;
            _loc4_ = new Vector.<Resource>();
            while(this.isOverfull())
            {
               _loc3_ = this.m_numBytes <= MAX_NUM_BYTES;
               _loc5_ = null;
               _loc6_ = int(this.m_resources.length - 1);
               while(_loc6_ >= 0)
               {
                  _loc7_ = this.m_resources[_loc6_];
                  if(_loc7_.refcount.refcount == 0 && (!_loc3_ || _loc7_.consoleCacheNumMutexes > 0) && _loc4_.indexOf(_loc7_) < 0)
                  {
                     _loc5_ = _loc7_;
                     break;
                  }
                  _loc6_--;
               }
               if(_loc5_ == null)
               {
                  if(DEBUG_LOGS)
                  {
                     this.m_logger.info("Console Resource Cache: Can\'t remove any resources from cache to free up space (i.e. cache size is smaller than the resource size high-water mark). Cache Size: {0}, Num Failed: {1}, Url: {2}",this.m_numBytes,_loc4_.length,param1.url);
                  }
                  break;
               }
               _loc8_ = _loc5_.consoleCacheState;
               _loc5_.consoleCacheState = Resource.CONSOLE_CACHE_STATE__SHOULD_BE_REMOVED;
               this.m_unloadResourceFn(_loc5_);
               this.checkCacheState(_loc5_);
               if(_loc5_.isInConsoleCache())
               {
                  _loc5_.consoleCacheState = _loc8_;
                  _loc4_.push(_loc5_);
                  if(DEBUG_LOGS)
                  {
                     this.m_logger.debug("ConsoleResourceCache.addResource: Resource was not removed from cache " + _loc5_.url);
                  }
               }
            }
            if(DEBUG_LOGS)
            {
               this.m_logger.debug("Console Resource Cache: Added resource: {0}. Cache size [{1}], Num mutexes [{2}], {3}, Max: [{4}, {5}]",param1,this.m_numBytes,this.m_numMutexes,this.getNumModifiedDebugString(),this.m_numBytesMax,this.m_numMutexesMax);
               if(_loc3_)
               {
                  this.m_logger.debug("Console Resource Cache: Warning: limited by mutexes. Cache size [{0}], Num mutexes [{1}]",this.m_numBytes,this.m_numMutexes);
               }
            }
         }
      }
      
      public function modifyResourceSize(param1:Resource) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:* = false;
         var _loc5_:String = null;
         this.checkCacheState(param1);
         if(param1 && param1.consoleCacheState == Resource.CONSOLE_CACHE_STATE__LOADING && param1.did_load && param1.ok)
         {
            param1.consoleCacheState = Resource.CONSOLE_CACHE_STATE__LOADED;
            _loc2_ = getResourceNumBytes(param1);
            _loc3_ = _loc2_ - param1.consoleCacheNumBytes;
            if(_loc3_ < 0 && Math.abs(_loc3_) > this.m_numBytes)
            {
               this.m_logger.error("ConsoleResourceCache.modifyResourceSize: Cache size is becoming negative. Cache size: {0}, bytesDiff: {1}",this.m_numBytes,_loc3_);
               _loc3_ = int(this.m_numBytes) * -1;
            }
            this.m_numBytes += _loc3_;
            param1.consoleCacheNumBytes = _loc2_;
            this.m_numBytesMax = Math.max(this.m_numBytes,this.m_numBytesMax);
            if(this.m_numMutexes > this.m_numMutexesMax)
            {
               this.m_numMutexesMax = this.m_numMutexes;
            }
            if(DEBUG_LOGS)
            {
               _loc4_ = s_resourceSizes[param1.url] != null;
               _loc5_ = "";
               if(_loc4_ && _loc3_ != 0)
               {
                  _loc5_ = "Warning: if it\'s in the table, we expect our estimate to be exact. ";
               }
               else if(!_loc4_ && _loc3_ > 0)
               {
                  _loc5_ = "Warning: if it\'s not in the table, we expect our estimate to be greater than the actual. ";
               }
               this.m_logger.debug("Console Resource Cache: Modifing size. {3}in table [{0}], bytesDiff [{1}], {4}, {2}, Max: [{5}, {6}]",_loc4_,_loc3_,param1,_loc5_,this.getNumModifiedDebugString(),this.m_numBytesMax,this.m_numMutexesMax);
            }
         }
      }
      
      public function removeResource(param1:Resource) : void
      {
         var _loc2_:int = 0;
         this.checkCacheState(param1);
         if(Boolean(param1) && param1.isInConsoleCache())
         {
            _loc2_ = this.m_resources.lastIndexOf(param1);
            if(_loc2_ >= 0)
            {
               ArrayUtil.removeAt(this.m_resources,_loc2_);
               this.m_numBytes -= param1.consoleCacheNumBytes;
               this.m_numMutexes -= param1.consoleCacheNumMutexes;
               param1.consoleCacheState = Resource.CONSOLE_CACHE_STATE__NOT_IN_CACHE;
               param1.consoleCacheNumBytes = 0;
               param1.consoleCacheNumMutexes = 0;
            }
            else
            {
               this.m_logger.error("ConsoleResourceCache.removeResource: Resource not found in cache though it has state [{0}] {1}",param1.consoleCacheState,param1);
            }
            if(DEBUG_LOGS)
            {
               this.m_logger.debug("Console Resource Cache: Removed resource: {0}. Cache size [{1}], Num mutexes [{2}], {3}, Max: [{4}, {5}]",param1.url,this.m_numBytes,this.m_numMutexes,this.getNumModifiedDebugString(),this.m_numBytesMax,this.m_numMutexesMax);
            }
         }
      }
      
      private function checkCacheState(param1:Resource) : void
      {
         if(DEBUG_CHECK_CACHE_STATE)
         {
            if(Boolean(param1) && this.m_resources.indexOf(param1) >= 0 != param1.isInConsoleCache())
            {
               this.m_logger.error("ConsoleResourceCache.checkCacheState: Resource {0} in m_resources but its state says it {1} ({2}).",param1.isInConsoleCache() ? "isn\'t" : "is",param1.isInConsoleCache() ? "is" : "isn\'t",param1.consoleCacheState);
            }
         }
      }
      
      private function getNumSizeWasModified() : int
      {
         var _loc2_:Resource = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_resources)
         {
            if(_loc2_.consoleCacheState == Resource.CONSOLE_CACHE_STATE__LOADED)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      private function getNumModifiedDebugString() : String
      {
         return "Num Modified [" + this.getNumSizeWasModified() + "/" + this.m_resources.length + "]";
      }
      
      private function initResourceSizes() : void
      {
         var _loc1_:IResource = null;
         s_resourceSizes = new Dictionary();
         if(ENABLED)
         {
            _loc1_ = this.m_resourceManager.getResource(RESOURCE_SIZES_FILE,DefResource);
            _loc1_.addEventListener(Event.COMPLETE,this.onLoadDataFileComplete);
         }
      }
      
      private function onLoadDataFileComplete(param1:Event) : void
      {
         var _loc3_:Object = null;
         var _loc2_:DefResource = param1.target as DefResource;
         if(_loc2_ && _loc2_.ok && Boolean(_loc2_.jo.resourceSizes))
         {
            for each(_loc3_ in _loc2_.jo.resourceSizes)
            {
               EngineJsonDef.validateThrow(_loc3_,ResSize.schema,this.m_logger);
               s_resourceSizes[_loc3_.url] = new ResSize(uint(_loc3_.numBytes),uint(_loc3_.numMutexes));
               if(DEBUG_LOGS)
               {
                  this.m_logger.info("s_resourceSizes[\"{0}\"] = new ResSize({1}, {2});",_loc3_.url,uint(_loc3_.numBytes),uint(_loc3_.numMutexes));
               }
            }
         }
         else
         {
            this.m_logger.error("ConsoleResourceCache.initResourceSizes: Failed to load {0}",RESOURCE_SIZES_FILE);
         }
         if(_loc2_)
         {
            _loc2_.removeEventListener(Event.COMPLETE,this.onLoadDataFileComplete);
            _loc2_.release();
         }
      }
   }
}

class ResSize
{
   
   public static const schema:Object = {
      "name":"ResSize",
      "type":"object",
      "properties":{
         "url":{"type":"string"},
         "numBytes":{"type":"number"},
         "numMutexes":{"type":"number"}
      }
   };
    
   
   public var numBytes:uint;
   
   public var numMutexes:uint;
   
   public function ResSize(param1:uint, param2:uint)
   {
      super();
      this.numBytes = param1;
      this.numMutexes = param2;
   }
}
