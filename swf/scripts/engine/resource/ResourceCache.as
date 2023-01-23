package engine.resource
{
   import com.stoicstudio.platform.Platform;
   import engine.core.util.AppInfo;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class ResourceCache
   {
      
      public static var ENABLED:Boolean = true;
      
      public static var MAX_BYTES_HARD:int = 1024 * 1024 * 600;
      
      public static var MAX_BYTES_SOFT:int = 1024 * 1024 * 400;
       
      
      private var appInfo:AppInfo;
      
      private var cacheErrors:int = 0;
      
      public var cacheVersion:String;
      
      public var cacheQuality:Number = 0;
      
      public var manifest:Vector.<Entry>;
      
      public var manifestCachePaths:Dictionary;
      
      public var totalSize:int;
      
      private var CACHEINFO_PATH:String = "cacheinfo.txt";
      
      private var manifestOrdinal:int;
      
      private var cacheInfoManifestOrdinal:int;
      
      private var last_modificationStamp:int;
      
      private var limitCheckElapsed:int;
      
      private var LIMIT_CHECK_THROTTLE_MS:int = 10000;
      
      public function ResourceCache(param1:AppInfo)
      {
         var _loc2_:ByteArray = null;
         var _loc3_:String = null;
         var _loc5_:Array = null;
         this.manifest = new Vector.<Entry>();
         this.manifestCachePaths = new Dictionary();
         super();
         this.appInfo = param1;
         _loc2_ = this.getFromCache(null,this.CACHEINFO_PATH);
         if(_loc2_)
         {
            _loc3_ = _loc2_.readUTFBytes(_loc2_.length);
            _loc2_.clear();
            _loc5_ = _loc3_.split("\n");
            if(_loc5_.length >= 2)
            {
               this.cacheVersion = _loc5_.shift();
               this.cacheQuality = _loc5_.shift();
            }
            this.parseManifest(_loc5_);
         }
         var _loc4_:Boolean = false;
         if(this.cacheVersion != param1.buildVersion)
         {
            param1.logger.info("ResourceCache version [" + this.cacheVersion + "] does not match app version [" + param1.buildVersion + "]");
            this.cacheVersion = param1.buildVersion;
            _loc4_ = true;
         }
         if(this.cacheQuality != Platform.qualityTextures)
         {
            param1.logger.info("ResourceCache quality [" + this.cacheQuality + "] does not match app quality [" + Platform.qualityTextures + "]");
            this.cacheQuality = Platform.qualityTextures;
            _loc4_ = true;
         }
         if(_loc4_)
         {
            this.clearCache(null);
         }
         else
         {
            this.limitCache(MAX_BYTES_SOFT);
            this.writeCacheInfo();
         }
      }
      
      private function parseManifest(param1:Array) : void
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:Entry = null;
         var _loc7_:String = null;
         if(!param1.length)
         {
            return;
         }
         var _loc2_:int = int(param1[0]);
         var _loc3_:int = 1;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1[_loc3_];
            if(_loc4_)
            {
               _loc5_ = _loc4_.split(":");
               if(_loc5_.length == 4)
               {
                  _loc6_ = new Entry();
                  _loc6_.timestamp = _loc5_[0];
                  _loc6_.size = _loc5_[1];
                  _loc6_.cacheId = _loc5_[2];
                  _loc6_.path = _loc5_[3];
                  _loc7_ = this.getCachePath(_loc6_.cacheId,_loc6_.path);
                  if(this.manifestCachePaths[_loc7_])
                  {
                     if(_loc6_.path != this.CACHEINFO_PATH)
                     {
                        this.appInfo.logger.error("ResoureCache duplicate entry for [" + _loc7_ + "]");
                     }
                  }
                  else
                  {
                     this.manifestCachePaths[_loc7_] = _loc6_;
                     this.manifest.push(_loc6_);
                     this.totalSize += _loc6_.size;
                  }
               }
            }
            _loc3_++;
         }
      }
      
      private function writeCacheInfo() : void
      {
         var _loc4_:Entry = null;
         var _loc5_:String = null;
         var _loc1_:* = this.cacheVersion + "\n" + this.cacheQuality + "\n";
         _loc1_ += this.totalSize.toString() + "\n";
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:int = 0;
         while(_loc3_ < this.manifest.length)
         {
            _loc4_ = this.manifest[_loc3_];
            _loc5_ = !!_loc4_.cacheId ? _loc4_.cacheId : "";
            _loc1_ += _loc4_.timestamp + ":" + _loc4_.size + ":" + _loc5_ + ":" + _loc4_.path + "\n";
            _loc3_++;
         }
         _loc2_.writeUTFBytes(_loc1_);
         this.putInCache(null,"cacheinfo.txt",_loc2_);
         _loc2_.clear();
         this.cacheInfoManifestOrdinal = this.manifestOrdinal;
      }
      
      public function hasInCache(param1:String, param2:String) : Boolean
      {
         if(!ENABLED)
         {
            return false;
         }
         var _loc3_:String = this.getCachePath(param1,param2);
         return this.appInfo.checkFileExists(null,_loc3_);
      }
      
      public function removeFromCache(param1:String, param2:String, param3:Boolean, param4:Boolean = true) : void
      {
         var _loc6_:Entry = null;
         var _loc7_:int = 0;
         if(!ENABLED)
         {
            return;
         }
         if(this.appInfo.logger.isDebugEnabled)
         {
            this.appInfo.logger.debug("ResourceCache.removeFromCache [" + param1 + "] [" + param2 + "]");
         }
         var _loc5_:String = this.getCachePath(param1,param2);
         this.appInfo.deleteFile(null,_loc5_,param3);
         if(param4)
         {
            _loc6_ = this.manifestCachePaths[_loc5_];
            if(_loc6_)
            {
               _loc7_ = this.manifest.indexOf(_loc6_);
               if(_loc7_ >= 0)
               {
                  this.manifest.splice(_loc7_,1);
               }
               delete this.manifestCachePaths[_loc5_];
               this.totalSize -= _loc6_.size;
            }
         }
         ++this.manifestOrdinal;
      }
      
      public function getFromCache(param1:String, param2:String) : ByteArray
      {
         if(!ENABLED)
         {
            return null;
         }
         var _loc3_:String = this.getCachePath(param1,param2);
         var _loc4_:ByteArray = this.appInfo.loadFile(null,_loc3_);
         if(_loc4_)
         {
            if(this.appInfo.logger.isDebugEnabled)
            {
               this.appInfo.logger.debug("ResourceCache.getFromCache [" + param1 + "] [" + param2 + "] [" + _loc4_.length + "]");
            }
            this.touchCache(param1,param2,_loc3_,_loc4_.length);
            ++this.manifestOrdinal;
         }
         return _loc4_;
      }
      
      public function touchCache(param1:String, param2:String, param3:String, param4:int) : void
      {
         if(!param3)
         {
            param3 = this.getCachePath(param1,param2);
         }
         var _loc5_:Entry = this.manifestCachePaths[param3];
         if(!_loc5_)
         {
            _loc5_ = new Entry();
            _loc5_.cacheId = param1;
            _loc5_.path = param2;
            _loc5_.size = param4;
            this.manifest.push(_loc5_);
            this.manifestCachePaths[param3] = _loc5_;
         }
         this.totalSize -= _loc5_.size;
         _loc5_.size = param4;
         this.totalSize += _loc5_.size;
         _loc5_.timestamp = new Date().getTime();
         ++this.manifestOrdinal;
      }
      
      public function limitCache(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Entry = null;
         var _loc7_:String = null;
         if(this.totalSize > param1)
         {
            if(this.appInfo.logger.isDebugEnabled)
            {
               this.appInfo.logger.debug("ResourceCache.limitCache totalSize [" + this.totalSize + "] over limit [" + param1 + "]");
            }
            _loc2_ = this.totalSize;
            this.manifest.sort(Entry.comparatorTimestamp);
            _loc3_ = this.manifest.length - 1;
            while(_loc3_ >= 0)
            {
               _loc6_ = this.manifest[_loc3_];
               this.removeFromCache(_loc6_.cacheId,_loc6_.path,true,false);
               this.totalSize -= _loc6_.size;
               _loc7_ = this.getCachePath(_loc6_.cacheId,_loc6_.path);
               if(this.appInfo.logger.isDebugEnabled)
               {
                  this.appInfo.logger.debug("ResourceCache.limitCache evict [" + _loc7_ + "] size [" + _loc6_.size + "] totalSize now [" + this.totalSize + "]");
               }
               delete this.manifestCachePaths[_loc7_];
               if(this.totalSize < MAX_BYTES_SOFT)
               {
                  break;
               }
               _loc3_--;
            }
            _loc4_ = _loc2_ - this.totalSize;
            _loc3_ = Math.max(0,_loc3_);
            _loc5_ = this.manifest.length = _loc3_;
            this.appInfo.logger.info("ResourceCache.limitCache evicted [" + _loc4_ + "] bytes in [" + _loc5_ + "] entries totalSize now [" + this.totalSize + "]");
            this.manifest.splice(_loc3_,_loc5_);
            ++this.manifestOrdinal;
         }
      }
      
      public function putInCache(param1:String, param2:String, param3:ByteArray) : void
      {
         if(!ENABLED)
         {
            return;
         }
         if(this.appInfo.logger.isDebugEnabled)
         {
            this.appInfo.logger.debug("ResourceCache.putInCache [" + param1 + "] [" + param2 + "] [" + param3.length + "]");
         }
         var _loc4_:String = this.getCachePath(param1,param2);
         if(!this.appInfo.saveFile(null,_loc4_,param3,true))
         {
            ++this.cacheErrors;
            this.appInfo.logger.error("ResourceCache.putInCache Failed to write to cache (error count " + this.cacheErrors + "): [" + _loc4_ + "]");
            switch(this.cacheErrors)
            {
               case 1:
                  this.clearCache(param1);
                  break;
               case 2:
                  this.clearCache(null);
                  break;
               default:
                  this.clearCache(null);
                  ENABLED = false;
            }
         }
         else if(param1)
         {
            this.touchCache(param1,param2,_loc4_,param3.length);
            this.limitCache(MAX_BYTES_HARD);
            if(this.manifestOrdinal != this.cacheInfoManifestOrdinal)
            {
               this.writeCacheInfo();
            }
         }
      }
      
      public function clearCache(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Entry = null;
         var _loc5_:String = null;
         var _loc2_:String = this.getCachePath(param1,null);
         this.appInfo.logger.info("ResourceCache.clearCache [" + param1 + "]: " + _loc2_);
         this.appInfo.deleteDirectory(null,_loc2_,true);
         if(!param1)
         {
            this.totalSize = 0;
            this.manifest = new Vector.<Entry>();
            this.manifestCachePaths = new Dictionary();
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < this.manifest.length)
            {
               _loc4_ = this.manifest[_loc3_];
               if(_loc4_.cacheId == param1)
               {
                  _loc5_ = this.getCachePath(_loc4_.cacheId,_loc4_.path);
                  delete this.manifestCachePaths[_loc5_];
                  this.totalSize -= _loc4_.size;
                  this.manifest.splice(_loc3_,1);
               }
               else
               {
                  _loc3_++;
               }
            }
         }
         ++this.manifestOrdinal;
      }
      
      private function getCachePath(param1:String, param2:String) : String
      {
         if(Boolean(param1) && Boolean(param2))
         {
            return "cache/" + param1 + "/" + param2;
         }
         if(param1)
         {
            return "cache/" + param1;
         }
         if(param2)
         {
            return "cache/" + param2;
         }
         return "cache";
      }
      
      public function update(param1:int, param2:int) : void
      {
         this.limitCheckElapsed += param1;
         if(this.limitCheckElapsed > this.LIMIT_CHECK_THROTTLE_MS)
         {
            if(param2 != this.last_modificationStamp)
            {
               this.last_modificationStamp = param2;
               this.limitCheckElapsed = 0;
               this.limitCache(MAX_BYTES_SOFT);
            }
         }
         if(this.manifestOrdinal != this.cacheInfoManifestOrdinal)
         {
            this.writeCacheInfo();
         }
      }
   }
}

class Entry
{
    
   
   public var timestamp:Number;
   
   public var cacheId:String;
   
   public var path:String;
   
   public var size:int;
   
   public function Entry()
   {
      super();
   }
   
   public static function comparatorTimestamp(param1:Entry, param2:Entry) : int
   {
      return param1.size - param2.size;
   }
}
