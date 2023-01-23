package lib.engine.resource.air
{
   import engine.core.logging.ILogger;
   import engine.resource.loader.IResourceScheme;
   import engine.resource.loader.SagaURLLoader;
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.URLLoaderDataFormat;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.setTimeout;
   
   public class ZipFileResourceScheme extends EventDispatcher implements IResourceScheme
   {
      
      public static const RESOURCE_ERROR:String = "ZipFileResourceScheme.RESOURCE_ERROR";
       
      
      private var zipFiles:Array;
      
      private var tempVideoDir:File;
      
      private var logger:ILogger;
      
      private var loadRequests:Vector.<ZipFileLoadRequest>;
      
      private var isLoading:Boolean = false;
      
      private var lastFileError:String = null;
      
      private const MAX_LOAD_TIME_MSEC:Number = 17;
      
      public function ZipFileResourceScheme(param1:ILogger, param2:IEventDispatcher = null)
      {
         this.zipFiles = new Array();
         this.loadRequests = new Vector.<ZipFileLoadRequest>();
         super(param2);
         this.logger = param1;
      }
      
      public function get scheme() : String
      {
         return "zip";
      }
      
      public function registerZipFile(param1:String, param2:File, param3:Boolean = false) : void
      {
         var _loc5_:Boolean = false;
         if(!param2.exists)
         {
            throw new Error("No such file: " + param2.url);
         }
         var _loc4_:ZipFileResource = new ZipFileResource(param2,param1,this.logger);
         if(param3)
         {
            _loc4_.keepOpen = true;
            _loc5_ = _loc4_.loadCentralDirectory();
            if(!_loc5_)
            {
               this.logger.error(_loc4_.lastError);
               throw new Error("Failed to load resource file");
            }
         }
         this.logger.info("ZipFileResourceScheme: Registered zip file at " + param2.url + " with prefix \'" + param1 + "\'");
         this.zipFiles.unshift(_loc4_);
      }
      
      private function sendDelayedErrorCallback(param1:SagaURLLoader, param2:String) : void
      {
         var loader:SagaURLLoader = param1;
         var message:String = param2;
         setTimeout(function():void
         {
            loader.schemaLoadError(message);
         },1);
      }
      
      private function parsePath(param1:String) : Array
      {
         var found:Boolean;
         var zipFile:ZipFileResource = null;
         var fileName:String = null;
         var hasFile:Boolean = false;
         var msg:String = null;
         var path:String = param1;
         if(path.charAt(0) != "/")
         {
            this.logger.info("Failed to parse path: " + path);
            this.lastFileError = "path \'" + path + "\' must start with a \'/\'";
            return null;
         }
         path = path.substr(1);
         found = false;
         var _loc3_:int = 0;
         var _loc4_:* = this.zipFiles;
         while(true)
         {
            for each(zipFile in _loc4_)
            {
               if(zipFile.prefix == "" || path.indexOf(zipFile.prefix) == 0 && path.charAt(zipFile.prefix.length) == "/")
               {
                  fileName = path.substr(zipFile.prefix.length + 1);
                  if(fileName.length >= 1)
                  {
                     hasFile = false;
                     try
                     {
                        hasFile = zipFile.containsFile(fileName);
                     }
                     catch(err:Error)
                     {
                        logger.error("Error loading \'" + fileName + "\' from \'" + zipFile.prefix + ": " + err.message + "\n" + err.getStackTrace());
                        msg = err.message as String;
                        if(msg == null)
                        {
                           msg = "";
                        }
                        dispatchEvent(new ErrorEvent(ZipFileResourceScheme.RESOURCE_ERROR,false,false,msg,err.errorID));
                        hasFile = false;
                     }
                     if(hasFile)
                     {
                        break;
                     }
                     this.logger.d("ZIP","ZipFileResourceScheme: \'{0}\' with prefix {1} NOT FOUND in {2}",fileName,zipFile.prefix,zipFile.url);
                  }
               }
            }
            this.logger.i("ZIP","Could not find a file that matches any registered resources for \'{0}\'",path);
            this.lastFileError = "could not find a file that matches any registered resources for \'" + path + "\'";
            return null;
         }
         this.logger.d("ZIP","ZipFileResourceScheme: found \'{0}\' with prefix {1} found in {2}",fileName,zipFile.prefix,zipFile.url);
         return new Array(zipFile,fileName);
      }
      
      public function hasFile(param1:String) : Boolean
      {
         var _loc2_:Array = this.parsePath(param1);
         if(_loc2_ == null)
         {
            this.logger.i("ZIP","Checking for {0}: does not exist.",param1);
            return false;
         }
         return true;
      }
      
      private function loadInternal() : void
      {
         var _loc4_:Array = null;
         var _loc5_:ByteArray = null;
         var _loc6_:ZipFileLoadRequest = null;
         var _loc7_:ZipFileResource = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc1_:Date = new Date();
         var _loc2_:Number = _loc1_.time;
         var _loc3_:int = 0;
         while(this.loadRequests.length > 0 && _loc1_.time - _loc2_ < this.MAX_LOAD_TIME_MSEC)
         {
            _loc6_ = this.loadRequests.pop();
            if(this.logger.isDebugEnabled)
            {
               this.logger.d("ZIP","Loading {0}",_loc6_.path);
            }
            _loc4_ = this.parsePath(_loc6_.path);
            if(_loc4_ == null)
            {
               this.logger.i("ZIP","Failed to find file for {0}",_loc6_.path);
               _loc6_.loader.schemaLoadError(this.lastFileError);
            }
            else
            {
               _loc7_ = _loc4_[0];
               _loc8_ = _loc4_[1];
               _loc5_ = _loc7_.loadFile(_loc8_);
               if(_loc5_ != null)
               {
                  if(_loc6_.loader.dataFormat == URLLoaderDataFormat.TEXT)
                  {
                     _loc9_ = _loc5_.readUTF();
                     _loc6_.loader.data = _loc9_;
                     _loc6_.loader.bytesLoaded = _loc9_.length;
                     _loc6_.loader.bytesTotal = _loc9_.length;
                  }
                  else
                  {
                     _loc6_.loader.data = _loc5_;
                     _loc6_.loader.bytesLoaded = _loc5_.length;
                     _loc6_.loader.bytesTotal = _loc5_.length;
                  }
                  _loc6_.loader.schemaLoadComplete();
               }
               else
               {
                  dispatchEvent(new ErrorEvent(ZipFileResourceScheme.RESOURCE_ERROR,false,false,_loc7_.lastError));
                  _loc6_.loader.schemaLoadError("(" + _loc6_.path + "): Failed to load file.");
               }
               _loc3_++;
               _loc1_ = new Date();
            }
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("ZIP","Loaded {0} in {1} msec. {2} files remaining.",_loc3_,_loc1_.time - _loc2_,this.loadRequests.length);
         }
         if(this.loadRequests.length > 0)
         {
            setTimeout(this.loadInternal,1);
         }
         else
         {
            this.isLoading = false;
         }
      }
      
      public function load(param1:String, param2:SagaURLLoader) : void
      {
         var _loc3_:ZipFileLoadRequest = new ZipFileLoadRequest(param1,param2);
         this.loadRequests.push(_loc3_);
         if(!this.isLoading)
         {
            this.isLoading = true;
            setTimeout(this.loadInternal,1);
         }
      }
      
      public function setupForVideo() : void
      {
         if(this.tempVideoDir == null)
         {
            this.tempVideoDir = File.applicationStorageDirectory.resolvePath("temporaryVideoStorage");
            if(this.tempVideoDir.exists)
            {
               this.tempVideoDir.deleteDirectory(true);
            }
            this.tempVideoDir.createDirectory();
         }
      }
      
      public function getVideoUrl(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:File = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc2_:String = param1;
         if(SagaURLLoader.hasCustomSchema(param1))
         {
            _loc3_ = param1;
            _loc4_ = param1.lastIndexOf("/");
            if(_loc4_ != -1)
            {
               _loc3_ = param1.substr(_loc4_ + 1);
            }
            _loc5_ = this.tempVideoDir.resolvePath(_loc3_);
            _loc6_ = param1;
            _loc7_ = param1.indexOf(":");
            if(_loc7_ != -1)
            {
               _loc6_ = param1.substr(_loc7_ + 1);
            }
            this.copyTo(_loc6_,_loc5_);
            _loc2_ = _loc5_.url;
         }
         return _loc2_;
      }
      
      public function releaseVideoUrl(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:File = null;
         if(SagaURLLoader.hasCustomSchema(param1))
         {
            _loc2_ = param1;
            _loc3_ = param1.lastIndexOf("/");
            if(_loc3_ != -1)
            {
               _loc2_ = param1.substr(_loc3_ + 1);
            }
            _loc4_ = this.tempVideoDir.resolvePath(_loc2_);
            if(_loc4_.exists)
            {
               _loc4_.deleteFile();
            }
         }
      }
      
      public function copyTo(param1:String, param2:File) : void
      {
         var _loc4_:FileStream = null;
         var _loc5_:ByteArray = null;
         var _loc6_:uint = 0;
         var _loc3_:IDataInput = this.getFileStream(param1);
         if(_loc3_ != null)
         {
            _loc4_ = new FileStream();
            _loc4_.addEventListener(IOErrorEvent.IO_ERROR,this.onCopyError);
            _loc4_.open(param2,FileMode.WRITE);
            _loc5_ = new ByteArray();
            while(_loc3_.bytesAvailable > 0)
            {
               _loc6_ = Math.min(_loc3_.bytesAvailable,16384);
               _loc5_.position = 0;
               _loc3_.readBytes(_loc5_,0,_loc6_);
               _loc4_.writeBytes(_loc5_,0,_loc6_);
            }
            _loc4_.removeEventListener(IOErrorEvent.IO_ERROR,this.onCopyError);
            _loc4_.close();
         }
         else
         {
            this.logger.error("Failed to get source stream for " + param1);
         }
      }
      
      private function onCopyError(param1:IOErrorEvent) : void
      {
         dispatchEvent(new ErrorEvent(ZipFileResourceScheme.RESOURCE_ERROR,false,false,param1.text,param1.errorID));
      }
      
      public function getFileStream(param1:String) : IDataInput
      {
         var zipFile:ZipFileResource;
         var result:ZipFileStream;
         var fileName:String = null;
         var msg:String = null;
         var path:String = param1;
         var pathComponents:Array = this.parsePath(path);
         if(pathComponents == null)
         {
            this.logger.info("Failed to find file for " + path);
            return null;
         }
         zipFile = pathComponents[0];
         fileName = pathComponents[1];
         result = null;
         try
         {
            result = new ZipFileStream(zipFile,fileName);
         }
         catch(err:Error)
         {
            msg = err.message as String;
            if(msg == null)
            {
               msg = "";
            }
            dispatchEvent(new ErrorEvent(ZipFileResourceScheme.RESOURCE_ERROR,false,false,msg,err.errorID));
            logger.error("Error creating zipFileStream for " + fileName + " : " + err);
         }
         return result;
      }
   }
}
