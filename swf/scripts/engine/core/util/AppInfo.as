package engine.core.util
{
   import com.stoicstudio.platform.PlatformFlash;
   import engine.core.logging.ILogger;
   import engine.resource.ResourceCache;
   import engine.resource.ResourceCensor;
   import flash.display.Sprite;
   import flash.display.StageDisplayState;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.profiler.showRedrawRegions;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class AppInfo extends EventDispatcher
   {
      
      public static const DIR_APPLICATION_STORAGE:String = "$APPLICATION_STORAGE_DIRECTORY";
      
      public static const DIR_APPLICATION:String = "$APPLICATION_DIRECTORY";
      
      public static const DIR_DOCUMENTS:String = "$DOCUMENTS_DIRECTORY";
      
      public static const DIR_ABSOLUTE:String = "$DIR_ABSOLUTE";
      
      public static const EVENT_WINDOW_MOVE:String = "AppInfo.EVENT_WINDOW_MOVE";
      
      public static var terminating:Boolean;
      
      public static var instance:AppInfo;
      
      private static const LOCALE_PREFIX:String = "locale.";
      
      private static const LOCALE_REGEX:RegExp = /_/g;
      
      private static const LOCALE_EXTENSION_REGEX:RegExp = /-.*$/;
       
      
      private var _root:Sprite;
      
      private var _buildVersion:String;
      
      private var _buildId:String;
      
      private var _appUrlRoot:String;
      
      public var logger:ILogger;
      
      public var exitCode:int = 0;
      
      private var _buildRelease:String;
      
      public var ordinal:int;
      
      public var minSize:Point;
      
      protected var _macAddress:String = "unknown_macAddress";
      
      public var inikeys:Vector.<String>;
      
      public var ini:Dictionary;
      
      public var locales:Vector.<String>;
      
      public var locale_mapping:Dictionary;
      
      public var resourceCache:ResourceCache;
      
      public var resourceCensor:ResourceCensor;
      
      public var master_sku:String;
      
      public var activated:Boolean;
      
      public var saveSkus:Array;
      
      public var finaleSaveSkus:Array;
      
      public var fullscreening:Boolean;
      
      private var redrawRegionsToggled:Boolean;
      
      private var redrawRegionsColor:uint = 16724838;
      
      public var applicationDirectoryUrl:String;
      
      public var applicationStorageDirectoryUrl:String;
      
      public var applicationDirectoryUrl_native:String;
      
      public var applicationStorageDirectoryUrl_native:String;
      
      public function AppInfo(param1:Sprite, param2:String, param3:String, param4:String, param5:int)
      {
         this.minSize = new Point(960,480);
         this.inikeys = new Vector.<String>();
         this.ini = new Dictionary();
         this.locales = new Vector.<String>();
         this.locale_mapping = new Dictionary();
         this.saveSkus = [];
         this.finaleSaveSkus = [];
         super();
         this._root = param1;
         this._buildVersion = param2;
         this._buildId = param3;
         this._buildRelease = param4;
         this.ordinal = param5;
         instance = this;
      }
      
      public function addLogLocation(param1:String) : void
      {
      }
      
      public function cloneAppInfo(param1:int) : AppInfo
      {
         return new AppInfo(this._root,this._buildVersion,this._buildId,this._buildRelease,param1);
      }
      
      public function hasIni(param1:String) : Boolean
      {
         return this.ini[param1] != undefined;
      }
      
      public function getIni(param1:String, param2:* = undefined) : *
      {
         if(this.ini[param1] != undefined)
         {
            return this.ini[param1];
         }
         return param2;
      }
      
      protected function cacheLocales() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         for each(_loc1_ in this.inikeys)
         {
            if(StringUtil.startsWith(_loc1_,LOCALE_PREFIX))
            {
               _loc2_ = String(this.ini[_loc1_]);
               if(!this.locale_mapping[_loc1_])
               {
                  if(this.locales.indexOf(_loc2_) == -1)
                  {
                     if(this.logger.isDebugEnabled)
                     {
                        this.logger.d("LOC ","cache add " + _loc2_);
                     }
                     this.locales.push(_loc2_);
                  }
                  _loc3_ = LOCALE_PREFIX + _loc2_;
                  if(_loc3_ != _loc1_)
                  {
                     if(!this.locale_mapping[_loc3_])
                     {
                        if(this.logger.isDebugEnabled)
                        {
                           this.logger.d("LOC ","cache map " + _loc3_ + " => " + _loc2_);
                        }
                        this.locale_mapping[_loc3_] = _loc2_;
                     }
                  }
                  if(!this.locale_mapping[_loc1_])
                  {
                     if(this.logger.isDebugEnabled)
                     {
                        this.logger.d("LOC ","cache map " + _loc1_ + " => " + _loc2_);
                     }
                     this.locale_mapping[_loc1_] = _loc2_;
                  }
               }
            }
         }
      }
      
      public function addLocales(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = param1.split(",");
         for each(_loc3_ in _loc2_)
         {
            this.addLocale(_loc3_,_loc3_);
         }
      }
      
      public function insertLocales(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = param1.split(",");
         for each(_loc3_ in _loc2_)
         {
            this.addLocale(_loc3_,_loc3_,true);
         }
      }
      
      public function addLocale(param1:String, param2:String, param3:Boolean = false) : void
      {
         if(this.locales.indexOf(param2) < 0)
         {
            this.logger.i("LOC","addlocale " + param2);
            if(param3)
            {
               this.locales.splice(0,0,param2);
            }
            this.locales.push(param2);
         }
         param1 = LOCALE_PREFIX + param1;
         if(!this.locale_mapping[param1])
         {
            this.locale_mapping[param1] = param2;
            this.logger.i("LOC","addlocale map " + param1 + " => " + param2);
         }
      }
      
      public function getLocaleMapping(param1:String) : String
      {
         var _loc2_:String = LOCALE_PREFIX + param1.replace(LOCALE_REGEX,"-");
         _loc2_ = _loc2_.toLowerCase();
         var _loc3_:String = String(this.locale_mapping[_loc2_]);
         if(_loc3_ == null)
         {
            _loc2_ = _loc2_.replace(LOCALE_EXTENSION_REGEX,"");
            _loc3_ = String(this.locale_mapping[_loc2_]);
         }
         return _loc3_;
      }
      
      public function get buildRelease() : String
      {
         return this._buildRelease;
      }
      
      final public function loadIni(param1:String) : void
      {
         this.handleLoadIni(param1);
         this.cacheLocales();
         var _loc2_:String = String(this.ini["saveSkus"]);
         if(_loc2_)
         {
            this.saveSkus = _loc2_.split(",");
         }
         _loc2_ = String(this.ini["finaleSaveSkus"]);
         if(_loc2_)
         {
            this.finaleSaveSkus = _loc2_.split(",");
         }
      }
      
      protected function handleLoadIni(param1:String) : void
      {
      }
      
      protected function parseIni(param1:String) : void
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc7_:String = null;
         this.ini = new Dictionary();
         this.inikeys.splice(0,this.inikeys.length);
         param1 = param1.replace("\r","");
         var _loc2_:Array = param1.split("\n");
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = String(_loc2_[_loc3_]);
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("parseIni scanning line " + _loc3_ + ":[" + _loc4_ + "]");
            }
            if(_loc4_.length == 0)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("parseIni skipping line " + _loc3_ + ":[" + _loc4_ + "]");
               }
            }
            else if(_loc4_.charAt(0) == "#")
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("parseIni comment line " + _loc3_ + ":[" + _loc4_ + "]");
               }
            }
            else
            {
               _loc5_ = _loc4_.indexOf("=");
               if(_loc5_ == -1)
               {
                  this.logger.info("parseIni malformed ignoring line " + _loc3_ + ":[" + _loc4_ + "]");
               }
               else
               {
                  _loc6_ = _loc4_.substring(0,_loc5_);
                  _loc7_ = _loc4_.substring(_loc5_ + 1);
                  this.ini[_loc6_] = _loc7_;
                  this.inikeys.push(_loc6_);
               }
            }
            _loc3_++;
         }
      }
      
      public function get appUrl() : String
      {
         return this._root.loaderInfo.url;
      }
      
      public function get appUrlRoot() : String
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         if(!this._appUrlRoot)
         {
            _loc1_ = this.applicationDirectoryUrl;
            _loc2_ = _loc1_.lastIndexOf("/");
            this._appUrlRoot = _loc1_.substring(0,_loc2_ + 1);
         }
         return this._appUrlRoot;
      }
      
      public function get nativeAppUrlRoot() : String
      {
         return this.appUrlRoot;
      }
      
      public function get root() : Sprite
      {
         return this._root;
      }
      
      public function get buildId() : String
      {
         return this._buildId;
      }
      
      public function get buildVersion() : String
      {
         return this._buildVersion;
      }
      
      public function set buildVersionOverride(param1:String) : void
      {
         this._buildVersion = param1;
      }
      
      public function init(param1:ILogger) : void
      {
         this.logger = param1;
      }
      
      public function exitGame(param1:String) : void
      {
         terminating = true;
         this.logger.info("AppInfo.exitGame: " + param1);
         System.exit(0);
      }
      
      public function terminateError(param1:String) : void
      {
         terminating = true;
         this.exitCode = 1;
         this.logger.error("AppInfo TERMINATING: " + param1);
         System.exit(1);
      }
      
      public function toggleRedrawRegions() : void
      {
         if(this.redrawRegionsToggled)
         {
            showRedrawRegions(false,16777215);
         }
         else
         {
            showRedrawRegions(true,this.redrawRegionsColor);
         }
         this.redrawRegionsToggled = !this.redrawRegionsToggled;
      }
      
      public function showRedrawRegions(param1:uint) : void
      {
         this.redrawRegionsToggled = false;
         this.redrawRegionsColor = param1;
         this.toggleRedrawRegions();
      }
      
      public function hideRedrawRegions() : void
      {
         this.redrawRegionsToggled = true;
         this.toggleRedrawRegions();
      }
      
      public function checkDesktopResolutionChange() : Boolean
      {
         return false;
      }
      
      public function set fullscreen(param1:Boolean) : void
      {
         if(param1)
         {
            this.root.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
         }
         else
         {
            this.root.stage.displayState = StageDisplayState.NORMAL;
         }
         PlatformFlash.fullscreen = param1;
      }
      
      public function get fullscreen() : Boolean
      {
         return Boolean(this.root) && Boolean(this.root.stage) && this.root.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE;
      }
      
      public function toggleFullscreen() : void
      {
         if(!this.root || !this.root.stage)
         {
            return;
         }
         this.fullscreen = !this.fullscreen;
      }
      
      public function saveFile(param1:String, param2:String, param3:ByteArray, param4:Boolean) : Boolean
      {
         return false;
      }
      
      final public function saveFileString(param1:String, param2:String, param3:String, param4:Boolean) : Boolean
      {
         var _loc5_:ByteArray = new ByteArray();
         _loc5_.writeUTFBytes(param3);
         var _loc6_:Boolean = this.saveFile(param1,param2,_loc5_,param4);
         _loc5_.clear();
         return _loc6_;
      }
      
      public function deleteFile(param1:String, param2:String, param3:Boolean) : void
      {
      }
      
      public function deleteDirectory(param1:String, param2:String, param3:Boolean) : void
      {
      }
      
      public function checkFileExists(param1:String, param2:String) : Boolean
      {
         return false;
      }
      
      public function loadFile(param1:String, param2:String) : ByteArray
      {
         return null;
      }
      
      final public function loadFileJson(param1:String, param2:String) : Object
      {
         var s:String = null;
         var jo:Object = null;
         var root:String = param1;
         var url:String = param2;
         s = this.loadFileString(root,url);
         if(!s)
         {
            return null;
         }
         try
         {
            jo = JSON.parse(s);
            return jo;
         }
         catch(e:Error)
         {
            logger.error("Failed parsing file [" + url + "] string json: " + e + "\n" + e.getStackTrace() + "\n" + s);
            return null;
         }
      }
      
      final public function loadFileJsonZ(param1:String, param2:String) : Object
      {
         var jo:Object = null;
         var root:String = param1;
         var url:String = param2;
         var ba:ByteArray = this.loadFile(root,url);
         if(!ba)
         {
            return null;
         }
         try
         {
            ba.uncompress();
            jo = ba.readObject();
            ba.clear();
            return jo;
         }
         catch(e:Error)
         {
            logger.error("Failed parsing file [" + url + "] string json: " + e + "\n" + e.getStackTrace());
            return null;
         }
      }
      
      final public function loadFileString(param1:String, param2:String) : String
      {
         var _loc3_:ByteArray = this.loadFile(param1,param2);
         if(!_loc3_)
         {
            return null;
         }
         var _loc4_:String = _loc3_.readUTFBytes(_loc3_.bytesAvailable);
         _loc3_.clear();
         return _loc4_;
      }
      
      public function loadFileAsync(param1:String, param2:String, param3:*, param4:Function) : void
      {
      }
      
      public function createDirectory(param1:String, param2:String) : Boolean
      {
         return false;
      }
      
      public function listDirectory(param1:String, param2:String) : Array
      {
         return null;
      }
      
      public function moveFile(param1:String, param2:String, param3:String, param4:Boolean) : Boolean
      {
         return false;
      }
      
      public function loadPreviousSagaFinaleSavesAsync(param1:Function, param2:String, param3:String) : void
      {
      }
      
      public function httpRequestAsync(param1:String, param2:String, param3:String = null, param4:Function = null) : void
      {
      }
      
      public function getUsernameForAnalytics() : String
      {
         return "";
      }
      
      public function navigateToURL(param1:URLRequest) : void
      {
         navigateToURL(param1);
      }
      
      public function bindLogTarget(param1:ILogger, param2:String) : void
      {
      }
      
      public function get macAddress() : String
      {
         return this._macAddress;
      }
      
      public function pathToUrl(param1:String) : String
      {
         return param1;
      }
      
      public function urlToPath(param1:String) : String
      {
         return param1;
      }
      
      public function setSystemIdleKeepAwake(param1:Boolean) : void
      {
      }
      
      public function setAspectRatio(param1:String) : void
      {
      }
      
      public function getLocalizedString(param1:String, param2:String) : String
      {
         if(!param1)
         {
            param1 = "BAD_TOKEN";
         }
         if(!param2)
         {
            param2 = "en";
         }
         var _loc3_:String = this.getLocaleMapping(param2);
         if(!_loc3_)
         {
            _loc3_ = param2;
         }
         var _loc4_:* = String(this.ini[param1 + "." + _loc3_]);
         if(!_loc4_)
         {
            _loc4_ = String(this.ini[param1 + ".en"]);
         }
         if(_loc4_)
         {
            _loc4_ = _loc4_.replace("\\n","\n");
         }
         else
         {
            _loc4_ = "{missing " + param1 + "}";
         }
         return _loc4_;
      }
      
      public function browseForFile(param1:String, param2:String, param3:String, param4:String, param5:Function) : void
      {
      }
      
      public function findFilesUnderUrl(param1:String, param2:String, param3:String) : Array
      {
         return null;
      }
      
      public function getUrlFromAbstractFolder(param1:String) : String
      {
         return null;
      }
      
      public function bringAppToFront() : void
      {
      }
      
      public function checkIfDebugBlocked() : Boolean
      {
         return false;
      }
      
      public function establishInitialUser() : void
      {
      }
      
      public function emitPlatformEvent(param1:String, ... rest) : void
      {
      }
      
      public function getSystemLocale() : String
      {
         return Capabilities.language;
      }
      
      public function forceSfGarbageCollectionNextFrame() : void
      {
      }
      
      public function getNumPs4Mutexes() : int
      {
         return 0;
      }
      
      public function get isDebugger() : Boolean
      {
         return Capabilities.isDebugger;
      }
      
      public function get windowX() : int
      {
         return 0;
      }
      
      public function get windowY() : int
      {
         return 0;
      }
      
      public function set windowX(param1:int) : void
      {
      }
      
      public function set windowY(param1:int) : void
      {
      }
      
      public function get windowWidth() : int
      {
         return 0;
      }
      
      public function get windowHeight() : int
      {
         return 0;
      }
      
      public function set windowWidth(param1:int) : void
      {
      }
      
      public function set windowHeight(param1:int) : void
      {
      }
      
      public function openLogFile() : void
      {
      }
   }
}
