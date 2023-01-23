package lib.engine.util.air
{
   import com.stoicstudio.platform.PlatformFlash;
   import engine.core.logging.ILogger;
   import engine.core.logging.Log;
   import engine.core.util.AppInfo;
   import engine.core.util.StringUtil;
   import flash.desktop.NativeApplication;
   import flash.desktop.SystemIdleMode;
   import flash.display.NativeWindow;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.NativeWindowBoundsEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.geom.Point;
   import flash.net.FileFilter;
   import flash.net.InterfaceAddress;
   import flash.net.NetworkInfo;
   import flash.net.NetworkInterface;
   import flash.net.URLRequestDefaults;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.clearTimeout;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import lib.engine.logging.targets.air.BufferLogTarget;
   import lib.engine.logging.targets.air.FileLogTarget;
   
   public class AirAppInfo extends AppInfo
   {
      
      public static var ALLOW_TOGGLE_FULLSCREEN:Boolean = true;
      
      public static var DOCUMENTS_DIRECTORY:File = File.documentsDirectory;
      
      public static var DOCUMENTS_FOLDER_LOGS:Boolean;
      
      public static var logFolderSubdir:String = "gamelog";
      
      public static var criticalErrorLogFunction:Function = null;
       
      
      private var _nativeAppUrlRoot:String;
      
      private var _nativePathSupported:Boolean = true;
      
      public var terminateWithMessageCallback:Function;
      
      private var _idleResetTimer:uint = 0;
      
      private var _browseFileCallback:Function;
      
      private var _lastScreenResolutionX:int = 0;
      
      private var _lastScreenResolutionY:int = 0;
      
      public function AirAppInfo(param1:Sprite, param2:String, param3:String, param4:String, param5:int)
      {
         var root:Sprite = param1;
         var buildVersion:String = param2;
         var buildTag:String = param3;
         var buildRelease:String = param4;
         var ordinal:int = param5;
         super(root,buildVersion,buildTag,buildRelease,ordinal);
         if(Boolean(root) && Boolean(root.stage))
         {
            this._lastScreenResolutionX = root.stage.fullScreenWidth;
            this._lastScreenResolutionY = root.stage.fullScreenHeight;
         }
         applicationDirectoryUrl = File.applicationDirectory.url;
         applicationStorageDirectoryUrl = File.applicationStorageDirectory.url;
         try
         {
            applicationDirectoryUrl_native = new File(File.applicationDirectory.nativePath).url;
            applicationStorageDirectoryUrl_native = new File(File.applicationStorageDirectory.nativePath).url;
         }
         catch(e:Error)
         {
            Log.getLogger(null).i("INIT","Error determining native diectories using URL");
            _nativePathSupported = false;
            applicationDirectoryUrl_native = "native paths not supported on mobile";
            applicationStorageDirectoryUrl_native = "native paths not supported on mobile";
         }
         if(applicationDirectoryUrl_native == "" || applicationStorageDirectoryUrl_native == "")
         {
            Log.getLogger(null).i("INIT","Empty path determining native diectories using URL");
            this._nativePathSupported = false;
            applicationDirectoryUrl_native = "native paths not supported on mobile";
            applicationStorageDirectoryUrl_native = "native paths not supported on mobile";
         }
         NativeApplication.nativeApplication.addEventListener(Event.SUSPEND,this.nativeApplicationHandler);
         NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,this.nativeApplicationHandler);
         NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,this.nativeApplicationHandler);
         URLRequestDefaults.useCache = false;
         URLRequestDefaults.cacheResponse = false;
      }
      
      public static function migrateApplicationStorageToToDocuments(param1:String, param2:String, param3:ILogger) : void
      {
         if(!param2)
         {
            param2 = param1;
         }
         var _loc4_:File = DOCUMENTS_DIRECTORY.resolvePath(param2);
         if(Boolean(_loc4_) && Boolean(_loc4_.exists))
         {
            return;
         }
         param3.info("migrateApplicationStorageToToDocuments: Documents [" + _loc4_.url + "] folder does not exist, migrating.");
         var _loc5_:File = File.applicationStorageDirectory.resolvePath(param1);
         if(Boolean(_loc5_) && Boolean(_loc5_.exists))
         {
            param3.info("migrateApplicationStorageToToDocuments: Application Storage [" + param1 + "] folder found..");
            param3.info("...Moving Folder:");
            param3.info(!!("... FROM " + _loc5_.nativePath) ? _loc5_.nativePath : _loc5_.url);
            param3.info(!!("...   TO " + _loc4_.nativePath) ? _loc4_.nativePath : _loc4_.url);
            _loc5_.moveTo(_loc4_);
         }
         else
         {
            param3.e("INIT","migrateApplicationStorageToDocuments: app folder [{0}] does not exist",_loc5_.url);
         }
      }
      
      private function _discoverMacAddress() : String
      {
         var _loc3_:String = null;
         var _loc4_:NetworkInterface = null;
         var _loc5_:String = null;
         var _loc6_:InterfaceAddress = null;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc1_:NetworkInfo = NetworkInfo.networkInfo;
         if(!_loc1_)
         {
            return null;
         }
         var _loc2_:Vector.<NetworkInterface> = _loc1_.findInterfaces();
         for each(_loc4_ in _loc2_)
         {
            _loc5_ = _loc4_.hardwareAddress;
            if(_loc5_)
            {
               for each(_loc6_ in _loc4_.addresses)
               {
                  _loc7_ = _loc6_.ipVersion == "IPv4" || Boolean("IPv6");
                  if(_loc7_)
                  {
                     _loc8_ = _loc6_.address + "/" + _loc6_.broadcast + "/" + _loc6_.ipVersion + "/" + _loc6_.prefixLength;
                     _loc9_ = !!_loc4_.subInterfaces ? int(_loc4_.subInterfaces.length) : 0;
                     _loc10_ = _loc4_.name + "/" + _loc4_.displayName + "/" + _loc4_.hardwareAddress + "/" + _loc4_.mtu + "/" + _loc4_.name + "/" + _loc9_ + "/" + _loc4_.active;
                     logger.info("candidate NIC [" + _loc5_ + "] [" + _loc10_ + "] addr [" + _loc8_ + "]");
                     if(!_loc3_)
                     {
                        logger.info("------------- CHOSE " + _loc5_);
                        _loc3_ = _loc5_;
                     }
                  }
               }
            }
         }
         return _loc3_;
      }
      
      private function nativeApplicationHandler(param1:Event) : void
      {
         var _loc2_:NativeApplication = NativeApplication.nativeApplication;
         var _loc3_:NativeWindow = !!_loc2_ ? _loc2_.activeWindow : null;
         activated = Boolean(_loc3_) && Boolean(_loc3_.active);
         dispatchEvent(param1);
      }
      
      override public function cloneAppInfo(param1:int) : AppInfo
      {
         return new AirAppInfo(root,buildVersion,buildId,buildRelease,param1);
      }
      
      override protected function handleLoadIni(param1:String) : void
      {
         var _loc2_:File = null;
         var _loc3_:Boolean = false;
         logger.info("documentsDirectory: " + (this._nativePathSupported ? DOCUMENTS_DIRECTORY.nativePath : DOCUMENTS_DIRECTORY.url));
         _loc2_ = File.applicationDirectory.resolvePath(param1 + ".ini");
         _loc3_ = this.loadIniFile("APPLICATION",_loc2_) || _loc3_;
         _loc2_ = File.applicationStorageDirectory.resolvePath(param1 + ".ini");
         _loc3_ = this.loadIniFile("APPLICATION_STORAGE",_loc2_) || _loc3_;
         if(!_loc3_)
         {
            logger.error("No ini file found anywhere for [" + param1 + "], see above");
         }
         master_sku = ini["sku"];
         if(master_sku)
         {
            _loc2_ = File.userDirectory.resolvePath(param1 + "_" + master_sku + ".ini");
            this.loadIniFile("USER",_loc2_);
         }
      }
      
      private function loadIniFile(param1:String, param2:File) : Boolean
      {
         var f:File = null;
         var fs:FileStream = null;
         var iniContents:String = null;
         var type:String = param1;
         var iniFile:File = param2;
         logger.info("AirAppInfo.loadIni checking for " + type + " iniFile: " + (this._nativePathSupported ? iniFile.nativePath : iniFile.url));
         try
         {
            if(iniFile)
            {
               f = iniFile;
               if(f.exists)
               {
                  logger.info("AirAppInfo.loadIni      loading " + type + " iniFile: " + (this._nativePathSupported ? iniFile.nativePath : iniFile.url));
                  fs = new FileStream();
                  fs.open(f,FileMode.READ);
                  iniContents = fs.readUTFBytes(fs.bytesAvailable);
                  parseIni(iniContents);
                  return true;
               }
            }
         }
         catch(e:Error)
         {
            logger.info(e.getStackTrace());
         }
         if(!ini)
         {
            ini = new Dictionary();
         }
         return false;
      }
      
      override public function get nativeAppUrlRoot() : String
      {
         var _loc1_:String = null;
         if(!this._nativeAppUrlRoot)
         {
            _loc1_ = File.applicationDirectory.nativePath;
            if(_loc1_)
            {
               this._nativeAppUrlRoot = new File(_loc1_).url;
            }
            else
            {
               this._nativeAppUrlRoot = File.applicationDirectory.url;
            }
         }
         return this._nativeAppUrlRoot;
      }
      
      private function initBufferLogTarget() : BufferLogTarget
      {
         var _loc1_:BufferLogTarget = null;
         if(DOCUMENTS_FOLDER_LOGS)
         {
            _loc1_ = new BufferLogTarget();
            logger.addTarget(_loc1_);
            AirAppInfo.migrateApplicationStorageToToDocuments("logs",logFolderSubdir,logger);
         }
         return _loc1_;
      }
      
      private function cleanupBufferLogTarget(param1:BufferLogTarget, param2:FileLogTarget) : void
      {
         if(param1)
         {
            logger.removeTarget(param1);
            param1.unbuffer(param2);
            param1.cleanup();
            param1 = null;
         }
      }
      
      private function resolveLogFolder(param1:File) : File
      {
         return param1.resolvePath(logFolderSubdir);
      }
      
      private function ensureLogFolder(param1:File) : File
      {
         var fileLogFolder:File = param1;
         if(logFolderSubdir != null)
         {
            fileLogFolder = this.resolveLogFolder(fileLogFolder);
         }
         if(!fileLogFolder.exists)
         {
            Log.getLogger(null).i("INIT","Log folder [{0}] does not exist: creating",fileLogFolder.url);
            try
            {
               fileLogFolder.createDirectory();
            }
            catch(e:Error)
            {
               fileLogFolder = null;
            }
         }
         return fileLogFolder;
      }
      
      override public function bindLogTarget(param1:ILogger, param2:String) : void
      {
         var _loc5_:* = null;
         var _loc6_:File = null;
         var _loc7_:FileLogTarget = null;
         var _loc3_:File = File.applicationStorageDirectory;
         var _loc4_:BufferLogTarget = this.initBufferLogTarget();
         if(_loc4_)
         {
            _loc3_ = DOCUMENTS_DIRECTORY;
         }
         _loc3_ = this.ensureLogFolder(_loc3_);
         if(_loc3_ != null)
         {
            _loc5_ = param2 + "-";
            this.rotateLogs(_loc3_,_loc5_,4);
            _loc6_ = _loc3_.resolvePath(_loc5_ + "0.log.txt");
            _loc7_ = new FileLogTarget(_loc6_,param1);
            param1.addTarget(_loc7_);
            param1.info("Writing logfile to " + (this._nativePathSupported ? _loc6_.nativePath : _loc6_.url));
            this.cleanupBufferLogTarget(_loc4_,_loc7_);
         }
      }
      
      override public function addLogLocation(param1:String) : void
      {
         var file:File = null;
         var flt:FileLogTarget = null;
         var path:String = param1;
         try
         {
            file = new File(path);
            flt = new FileLogTarget(file,logger);
            logger.addTarget(flt);
         }
         catch(e:Error)
         {
            logger.error("Unable to addLogLocation [" + path + "]");
         }
      }
      
      override public function init(param1:ILogger) : void
      {
         var _loc2_:String = String.fromCharCode(65 + ordinal);
         super.init(param1);
         this.bindLogTarget(param1,_loc2_);
         _macAddress = this._discoverMacAddress();
         new AirGpSource(param1);
      }
      
      final private function rotateLogs(param1:File, param2:String, param3:int) : void
      {
         var prev:File = null;
         var next:File = null;
         var baseDir:File = param1;
         var prefix:String = param2;
         var keep:int = param3;
         var i:int = keep - 1;
         while(i >= 0)
         {
            prev = null;
            next = null;
            try
            {
               prev = baseDir.resolvePath(prefix + i + ".log.txt");
               if(prev.exists)
               {
                  next = baseDir.resolvePath(prefix + (i + 1) + ".log.txt");
                  prev.moveTo(next,true);
               }
            }
            catch(e:Error)
            {
               logger.error("Failed to rotate logs from " + prev + " to " + next);
               break;
            }
            i--;
         }
      }
      
      override public function exitGame(param1:String) : void
      {
         if(terminating)
         {
            logger.info("Attempted to exitGame [" + param1 + "] while already terminating");
            return;
         }
         terminating = true;
         logger.info("AirAppInfo.exitGame: " + param1);
         if(criticalErrorLogFunction != null)
         {
            criticalErrorLogFunction("Game exiting: " + param1);
         }
         NativeApplication.nativeApplication.dispatchEvent(new Event(Event.EXITING));
      }
      
      override public function terminateError(param1:String) : void
      {
         if(terminating)
         {
            logger.info("Attempted to terminateError [" + param1 + "] while already terminating");
            return;
         }
         terminating = true;
         exitCode = 1;
         logger.error("AirAppInfo TERMINATING: " + param1);
         if(this.terminateWithMessageCallback != null)
         {
            if(this.terminateWithMessageCallback(param1))
            {
               return;
            }
         }
         NativeApplication.nativeApplication.dispatchEvent(new Event(Event.EXITING));
      }
      
      override public function set fullscreen(param1:Boolean) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(_loc2_ == null)
         {
            return;
         }
         if(param1)
         {
            fullscreening = true;
            _loc2_.minSize = minSize;
         }
         if(ALLOW_TOGGLE_FULLSCREEN)
         {
            super.fullscreen = param1;
            if(!param1)
            {
               _loc3_ = Number(_loc2_.width) - Number(_loc2_.stage.stageWidth);
               _loc4_ = Number(_loc2_.height) - Number(_loc2_.stage.stageHeight);
               _loc2_.minSize = new Point(minSize.x + _loc3_,minSize.y + _loc4_);
            }
         }
         _loc2_ = null;
         PlatformFlash.fullscreen = param1;
         fullscreening = false;
      }
      
      override public function bringAppToFront() : void
      {
         NativeApplication.nativeApplication.activate();
      }
      
      private function processFld(param1:String) : File
      {
         var _loc2_:File = null;
         var _loc3_:String = null;
         if(!param1)
         {
            _loc2_ = File.applicationStorageDirectory;
            if(this._nativePathSupported && Boolean(_loc2_.nativePath))
            {
               _loc2_ = new File(_loc2_.nativePath);
            }
         }
         else if(param1.indexOf(DIR_APPLICATION_STORAGE) == 0)
         {
            _loc3_ = param1.substr(DIR_APPLICATION_STORAGE.length);
            if(_loc3_.indexOf("/") == 0)
            {
               _loc3_ = _loc3_.substr(1);
            }
            if(_loc3_.length == 0)
            {
               _loc2_ = File.applicationStorageDirectory;
            }
            else
            {
               _loc2_ = File.applicationStorageDirectory.resolvePath(_loc3_);
            }
         }
         else if(param1.indexOf(DIR_APPLICATION) == 0)
         {
            _loc3_ = param1.substr(DIR_APPLICATION.length);
            if(_loc3_.indexOf("/") == 0)
            {
               _loc3_ = _loc3_.substr(1);
            }
            if(_loc3_.length == 0)
            {
               _loc2_ = File.applicationDirectory;
            }
            else
            {
               _loc2_ = File.applicationDirectory.resolvePath(_loc3_);
            }
         }
         else if(param1.indexOf(DIR_DOCUMENTS) == 0)
         {
            _loc3_ = param1.substr(DIR_DOCUMENTS.length);
            if(_loc3_.indexOf("/") == 0)
            {
               _loc3_ = _loc3_.substr(1);
            }
            if(_loc3_.length == 0)
            {
               _loc2_ = DOCUMENTS_DIRECTORY;
            }
            else
            {
               _loc2_ = DOCUMENTS_DIRECTORY.resolvePath(_loc3_);
            }
         }
         else
         {
            if(param1.indexOf(DIR_ABSOLUTE) == 0)
            {
               return null;
            }
            if(param1.indexOf("/") != param1.length - 1)
            {
               _loc2_ = new File(param1);
               if(logger)
               {
                  logger.info("processFld: " + param1 + " -> " + _loc2_.url);
               }
            }
            else
            {
               _loc2_ = null;
            }
         }
         return _loc2_;
      }
      
      override public function deleteDirectory(param1:String, param2:String, param3:Boolean) : void
      {
         var fld:String = param1;
         var url:String = param2;
         var sync:Boolean = param3;
         var file:File = this.processPath(fld,url);
         if(file.exists)
         {
            logger.info("Deleting directory " + file.url);
            try
            {
               if(sync)
               {
                  file.deleteDirectory(true);
               }
               else
               {
                  file.deleteDirectoryAsync(true);
               }
            }
            catch(err:Error)
            {
               logger.info("Error deleting directory: " + err.getStackTrace());
            }
         }
      }
      
      override public function deleteFile(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc4_:File = this.processPath(param1,param2);
         if(_loc4_.exists)
         {
            if(param3)
            {
               _loc4_.deleteFile();
            }
            else
            {
               _loc4_.deleteFileAsync();
            }
         }
      }
      
      override public function moveFile(param1:String, param2:String, param3:String, param4:Boolean) : Boolean
      {
         var src:File = null;
         var dst:File = null;
         var fld:String = param1;
         var src_url:String = param2;
         var dst_url:String = param3;
         var sync:Boolean = param4;
         var baseDir:File = this.processFld(fld);
         try
         {
            logger.info("moveFile [" + src_url + "] to [" + dst_url + "]");
            src = baseDir.resolvePath(src_url);
            dst = baseDir.resolvePath(dst_url);
            if(src.exists)
            {
               if(sync)
               {
                  src.moveTo(dst);
               }
               else
               {
                  src.moveToAsync(dst);
               }
               return true;
            }
         }
         catch(e:Error)
         {
            logger.error("Failed to moveFile [" + src_url + "] to [" + dst_url + "]");
            logger.error(e.getStackTrace());
         }
         return false;
      }
      
      private function fileMoveIOErrorEventHandler(param1:IOErrorEvent) : void
      {
         logger.error("fileMoveIOErrorEventHandler: " + param1);
      }
      
      override public function createDirectory(param1:String, param2:String) : Boolean
      {
         var _loc3_:File = this.processPath(param1,param2);
         if(!_loc3_.exists)
         {
            _loc3_.createDirectory();
            return true;
         }
         return false;
      }
      
      override public function saveFile(param1:String, param2:String, param3:ByteArray, param4:Boolean) : Boolean
      {
         var file:File = null;
         var parentDir:File = null;
         var fs:FileStream = null;
         var fld:String = param1;
         var url:String = param2;
         var data:ByteArray = param3;
         var sync:Boolean = param4;
         file = this.processPath(fld,url);
         logger.d("SAVE","saveFile fld={0}, url={1}",fld,url);
         parentDir = file.parent;
         if(parentDir != null && !parentDir.exists)
         {
            try
            {
               parentDir.createDirectory();
            }
            catch(err:Error)
            {
               logger.error("saveFile: failed to create parent directory " + parentDir.url + " for saving " + file.url);
            }
         }
         try
         {
            fs = new FileStream();
            if(sync)
            {
               fs.open(file,FileMode.WRITE);
            }
            else
            {
               fs.openAsync(file,FileMode.WRITE);
            }
            if(data)
            {
               fs.writeBytes(data);
            }
            fs.close();
            return true;
         }
         catch(err:Error)
         {
            logger.error("Failed to saveFile [" + file + "]: " + err);
            return false;
         }
      }
      
      override public function listDirectory(param1:String, param2:String) : Array
      {
         var _loc7_:File = null;
         var _loc8_:String = null;
         var _loc3_:File = this.processPath(param1,param2);
         if(!_loc3_.exists || !_loc3_.isDirectory)
         {
            return [];
         }
         var _loc4_:Array = _loc3_.getDirectoryListing();
         var _loc5_:Array = [];
         var _loc6_:* = _loc3_.url + "/";
         if(logger.isDebugEnabled)
         {
            logger.debug("AirAppInfo.listDirectory pfx=[" + _loc6_ + "]");
         }
         for each(_loc7_ in _loc4_)
         {
            _loc8_ = StringUtil.stripPrefix(_loc7_.url,_loc6_);
            _loc5_.push(_loc8_);
         }
         return _loc5_;
      }
      
      override public function getUrlFromAbstractFolder(param1:String) : String
      {
         var file:File = null;
         var fld:String = param1;
         try
         {
            file = this.processFld(fld);
            return !!file ? file.url : null;
         }
         catch(e:Error)
         {
            logger.error("Problem getUrlFromAbstractFolder [" + fld + "]: " + e);
            return null;
         }
      }
      
      private function processPath(param1:String, param2:String) : File
      {
         var file:File = null;
         var fld:String = param1;
         var url:String = param2;
         try
         {
            file = this.processFld(fld);
            if(file)
            {
               file = file.resolvePath(url);
            }
            else
            {
               file = new File(url);
            }
         }
         catch(e:Error)
         {
            logger.e("FILE","processPath: [" + fld + " + " + url + "]: " + e);
         }
         return file;
      }
      
      override public function loadFileAsync(param1:String, param2:String, param3:*, param4:Function) : void
      {
         var file:File = null;
         var fs:FileStream = null;
         var fsCompleteHandler:Function = null;
         var fld:String = param1;
         var url:String = param2;
         var context:* = param3;
         var callback:Function = param4;
         try
         {
            file = this.processPath(fld,url);
         }
         catch(e:Error)
         {
            logger.error("Problem loading file [" + fld + " + " + url + "]: " + e);
         }
         if(!file || !file.exists)
         {
            callback(url,context,null);
            return;
         }
         fs = new FileStream();
         try
         {
            fsCompleteHandler = function(param1:Event):void
            {
               fs.removeEventListener(Event.COMPLETE,fsCompleteHandler);
               var _loc2_:ByteArray = new ByteArray();
               fs.readBytes(_loc2_);
               fs.close();
               callback(url,context,_loc2_);
            };
            fs.addEventListener(Event.COMPLETE,fsCompleteHandler);
            fs.openAsync(file,FileMode.READ);
         }
         catch(err:Error)
         {
            logger.error("Failed to loadFile [" + file + "]: " + err);
         }
      }
      
      override public function loadFile(param1:String, param2:String) : ByteArray
      {
         var file:File = null;
         var fs:FileStream = null;
         var data:ByteArray = null;
         var fld:String = param1;
         var url:String = param2;
         try
         {
            file = this.processPath(fld,url);
            if(!file.exists)
            {
               return null;
            }
            fs = new FileStream();
            data = new ByteArray();
            fs.open(file,FileMode.READ);
            fs.readBytes(data);
            fs.close();
            return data;
         }
         catch(err:Error)
         {
            logger.error("Failed to loadFile [" + fld + "] [" + url + "]:\n" + err);
            return null;
         }
      }
      
      override public function checkFileExists(param1:String, param2:String) : Boolean
      {
         var _loc3_:File = this.processPath(param1,param2);
         return _loc3_.exists;
      }
      
      override public function pathToUrl(param1:String) : String
      {
         var f:File = null;
         var value:String = param1;
         if(Boolean(value) && !StringUtil.startsWith(value,"zip://"))
         {
            try
            {
               f = new File(value);
               return f.url;
            }
            catch(e:Error)
            {
               logger.e("FILE","pathToUrl: [" + value + "]:\n" + e.getStackTrace());
               return null;
            }
         }
         else
         {
            return value;
         }
      }
      
      override public function urlToPath(param1:String) : String
      {
         if(Boolean(param1) && this._nativePathSupported)
         {
            return new File(param1).nativePath;
         }
         return param1;
      }
      
      override public function setSystemIdleKeepAwake(param1:Boolean) : void
      {
         var value:Boolean = param1;
         if(value)
         {
            if(this._idleResetTimer != 0)
            {
               clearTimeout(this._idleResetTimer);
               this._idleResetTimer = 0;
            }
            NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
         }
         else
         {
            if(this._idleResetTimer != 0)
            {
               clearTimeout(this._idleResetTimer);
            }
            this._idleResetTimer = setTimeout(function():void
            {
               _idleResetTimer = 0;
               NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
            },30000);
         }
      }
      
      override public function setAspectRatio(param1:String) : void
      {
         PlatformFlash.stage.setAspectRatio(param1);
      }
      
      override public function browseForFile(param1:String, param2:String, param3:String, param4:String, param5:Function) : void
      {
         var _loc8_:Array = null;
         var _loc6_:File = this.processPath(param1,param2);
         var _loc7_:int = 0;
         while(_loc7_ < 5 && _loc6_ && !_loc6_.exists)
         {
            logger.info("AirAppInfo.browseForFile trying parent of nonexistent [" + _loc6_.url + "]");
            _loc6_ = _loc6_.parent;
            _loc7_++;
         }
         if(!_loc6_ || !_loc6_.exists)
         {
            logger.info("AirAppInfo.browseForFile defaulting to documents directory");
            _loc6_ = File.documentsDirectory;
         }
         this._browseFileCallback = param5;
         _loc8_ = [];
         _loc8_.push(new FileFilter("desc",param4));
         _loc6_.addEventListener(Event.SELECT,this.fileBrowseSelectHandler);
         _loc6_.addEventListener(Event.CANCEL,this.fileBrowseSelectCanceled);
         _loc6_.browseForOpen(param3,_loc8_);
      }
      
      private function fileBrowseSelectHandler(param1:Event) : void
      {
         var _loc3_:String = null;
         var _loc2_:File = param1.target as File;
         if(this._browseFileCallback != null)
         {
            _loc3_ = Boolean(_loc2_) && Boolean(_loc2_.exists) ? _loc2_.url : null;
            if(_loc2_.exists)
            {
               this._browseFileCallback(_loc3_);
            }
         }
      }
      
      private function fileBrowseSelectCanceled(param1:Event) : void
      {
         if(this._browseFileCallback != null)
         {
            this._browseFileCallback(null);
         }
      }
      
      override public function findFilesUnderUrl(param1:String, param2:String, param3:String) : Array
      {
         var _loc10_:File = null;
         var _loc4_:File = this.processPath(param1,param2);
         if(!_loc4_)
         {
            return null;
         }
         var _loc5_:int = getTimer();
         var _loc6_:Array = this.findFiles(_loc4_,param3);
         var _loc7_:int = getTimer();
         var _loc8_:int = _loc7_ - _loc5_;
         if(!_loc6_)
         {
            return null;
         }
         var _loc9_:Array = [];
         for each(_loc10_ in _loc6_)
         {
            _loc9_.push(_loc10_.url);
         }
         return _loc9_;
      }
      
      private function findFiles(param1:File, param2:String) : Array
      {
         var _loc5_:Array = null;
         var _loc6_:File = null;
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         if(param1.isDirectory)
         {
            _loc4_.push(param1);
         }
         while(_loc4_.length)
         {
            param1 = _loc4_.pop();
            _loc5_ = param1.getDirectoryListing();
            for each(_loc6_ in _loc5_)
            {
               if(_loc6_.isDirectory)
               {
                  _loc4_.push(_loc6_);
               }
               else if(_loc6_.name == param2)
               {
                  _loc3_.push(_loc6_);
               }
            }
         }
         return _loc3_;
      }
      
      override public function get windowX() : int
      {
         var _loc1_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc1_)
         {
            return 0;
         }
         return _loc1_.x;
      }
      
      override public function get windowY() : int
      {
         var _loc1_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc1_)
         {
            return 0;
         }
         return _loc1_.y;
      }
      
      override public function set windowX(param1:int) : void
      {
         var _loc2_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.x = param1;
      }
      
      override public function set windowY(param1:int) : void
      {
         var _loc2_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.y = param1;
      }
      
      override public function get windowWidth() : int
      {
         var _loc1_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc1_)
         {
            return 0;
         }
         return _loc1_.width;
      }
      
      override public function get windowHeight() : int
      {
         var _loc1_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc1_)
         {
            return 0;
         }
         return _loc1_.height;
      }
      
      override public function set windowWidth(param1:int) : void
      {
         var _loc2_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.x = Math.max(0,_loc2_.x - (param1 - Number(_loc2_.width)));
         _loc2_.width = param1;
      }
      
      override public function set windowHeight(param1:int) : void
      {
         var _loc2_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.y = Math.max(0,_loc2_.y - (param1 - Number(_loc2_.height)));
         _loc2_.height = param1;
      }
      
      private function windowMoveHandler(param1:NativeWindowBoundsEvent) : void
      {
         this.dispatchEvent(new Event(AppInfo.EVENT_WINDOW_MOVE));
      }
      
      override public function checkDesktopResolutionChange() : Boolean
      {
         return false;
      }
      
      override public function openLogFile() : void
      {
         var _loc2_:String = null;
         var _loc3_:File = null;
         var _loc1_:Array = logger.getLogFilePaths();
         if(_loc1_)
         {
            for each(_loc2_ in _loc1_)
            {
               if(_loc2_)
               {
                  logger.info("Opening logfile [" + _loc2_ + "]");
                  _loc3_ = new File(_loc2_);
                  _loc3_.openWithDefaultApplication();
               }
            }
         }
      }
   }
}
