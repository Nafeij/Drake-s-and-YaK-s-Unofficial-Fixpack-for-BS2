package lib.fmodstudio
{
   import air.fmodstudio.ane.FmodEventId;
   import air.fmodstudio.ane.FmodStudio;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.fmod.FmodManifest;
   import engine.fmod.FmodManifestEvent;
   import engine.resource.ResourceManager;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundEventId;
   import engine.sound.ISoundPreloader;
   import engine.sound.SoundDriverEvent;
   import engine.sound.config.FmodSoundSystem;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.ISoundDef;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.filesystem.File;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import lib.engine.sound.fmod.FmodSoundDefBundle;
   import lib.engine.sound.fmod.IFmodSoundDriver;
   
   public class FmodStudioSoundDriver extends EventDispatcher implements IFmodSoundDriver
   {
      
      public static var _debug:Boolean = false;
      
      public static var _eventExpirationMs:int = 10000;
      
      private static const REVERB_BUS:String = "Reverb";
      
      private static const MUSIC_BUS:String = "music";
      
      private static const SFX_BUS:String = "sfx";
      
      public static var ENABLE_SUSTAIN_POINT_WORKAROUND:Boolean;
       
      
      private var logger:ILogger;
      
      private var fmod:FmodStudio;
      
      public var _system:FmodSoundSystem;
      
      private var loadedFsbs:Dictionary;
      
      private var resman:ResourceManager;
      
      private var _debugVerbose:Boolean = false;
      
      private var _playing:Dictionary;
      
      private var _params:Dictionary;
      
      private var _reverb:String;
      
      private var _fmodManifest:FmodManifest;
      
      private var waveBankInfos:Dictionary;
      
      private var _knownSkus:Array;
      
      private var _skuFallback:String = "common";
      
      private var _playingResources:Dictionary;
      
      private var _cleanupResources:Array;
      
      private var clear:Vector.<ISoundEventId>;
      
      private var _disposed:Boolean = false;
      
      private var fmod_event_callbacktype:Array;
      
      public function FmodStudioSoundDriver(param1:FmodSoundSystem, param2:ILogger)
      {
         this.loadedFsbs = new Dictionary();
         this._playing = new Dictionary();
         this._params = new Dictionary();
         this._fmodManifest = new FmodManifest();
         this.waveBankInfos = new Dictionary();
         this._knownSkus = ["saga1","saga2s","saga2","saga3s","saga3"];
         this._playingResources = new Dictionary();
         this._cleanupResources = [];
         this.clear = new Vector.<ISoundEventId>();
         this.fmod_event_callbacktype = ["FMOD_EVENT_CALLBACKTYPE_SYNCPOINT            ","FMOD_EVENT_CALLBACKTYPE_SOUNDDEF_START       ","FMOD_EVENT_CALLBACKTYPE_SOUNDDEF_END         ","FMOD_EVENT_CALLBACKTYPE_STOLEN               ","FMOD_EVENT_CALLBACKTYPE_EVENTFINISHED        ","FMOD_EVENT_CALLBACKTYPE_NET_MODIFIED         ","FMOD_EVENT_CALLBACKTYPE_SOUNDDEF_CREATE      ","FMOD_EVENT_CALLBACKTYPE_SOUNDDEF_RELEASE     ","FMOD_EVENT_CALLBACKTYPE_SOUNDDEF_INFO        ","FMOD_EVENT_CALLBACKTYPE_EVENTSTARTED         ","FMOD_EVENT_CALLBACKTYPE_SOUNDDEF_SELECTINDEX ","FMOD_EVENT_CALLBACKTYPE_OCCLUSION            "];
         super();
         if(param2.isDebugEnabled)
         {
            param2.d("fmod","FmodSoundDriver ctor");
         }
         this.logger = param2;
         this._system = param1;
         this.resman = param1.resman as ResourceManager;
      }
      
      private static function getEventId(param1:ISoundEventId) : FmodEventId
      {
         var _loc2_:FmodStudioSoundEventId = param1 as FmodStudioSoundEventId;
         return !!_loc2_ ? _loc2_.eventId : null;
      }
      
      private static function castNumberToNearbyInt(param1:Number, param2:Number) : int
      {
         var _loc3_:Number = Math.floor(param1);
         if(Math.abs(param1 - _loc3_) < param2)
         {
            return int(_loc3_);
         }
         var _loc4_:Number = Math.ceil(param1);
         if(Math.abs(param1 - _loc4_) < param2)
         {
            return int(_loc4_);
         }
         return undefined;
      }
      
      public function get isDebug() : Boolean
      {
         return _debug;
      }
      
      public function isFsbLoaded(param1:String) : Boolean
      {
         return this.loadedFsbs[param1];
      }
      
      public function get system() : ISoundSystem
      {
         return this._system;
      }
      
      private function initFMOD(param1:Boolean, param2:int) : Boolean
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.initFMOD");
         }
         return this.fmod.initFMOD(param1,param2);
      }
      
      public function loadBaseResource(param1:String, param2:ByteArray) : Boolean
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.loadBaseResource [" + param1 + "] bytes=(" + (!!param2 ? param2.length : "-") + ")");
         }
         var _loc3_:Boolean = this.fmod.loadBank(param1,param2);
         if(!_loc3_)
         {
            this.logger.error("FmodStudioSoundDriver.loadBaseResource failed to load event file");
         }
         return _loc3_;
      }
      
      public function loadResource(param1:String, param2:ByteArray, param3:Boolean = false) : Boolean
      {
         if(this.isFsbLoaded(param1))
         {
            throw new IllegalOperationError("Do not try to load " + param1 + " twice -- unless we support reload in the future");
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.loadFSB soundBankPath=" + param1 + " bytes=(" + (!!param2 ? param2.length : "-") + ")");
         }
         var _loc4_:Boolean = this.fmod.loadBank(param1,param2);
         if(_loc4_)
         {
            this.loadedFsbs[param1] = param1;
         }
         return _loc4_;
      }
      
      public function unloadResource(param1:String, param2:int) : Boolean
      {
         if(!this.isFsbLoaded(param1))
         {
            throw new IllegalOperationError("Do not try to unload " + param1 + " without it being loaded.");
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.unloadFSB soundBankPath=" + param1);
         }
         var _loc3_:Boolean = this.fmod.unloadBank(param1);
         if(_loc3_)
         {
            delete this.loadedFsbs[param1];
         }
         return _loc3_;
      }
      
      public function getGroup(param1:String) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.getGroup " + param1);
         }
      }
      
      public function getWaveBankInfo(param1:String) : Array
      {
         var _loc2_:Array = null;
         var _loc3_:FmodManifestEvent = null;
         if(param1)
         {
            param1 = "event:/" + param1;
            _loc2_ = this.waveBankInfos[param1];
            if(!_loc2_)
            {
               if(this.logger.isDebugEnabled)
               {
               }
               _loc3_ = this._fmodManifest.getEvent(param1);
               if(_loc3_ != null)
               {
                  _loc2_ = [];
                  _loc2_ = _loc3_.banks.concat();
                  if(_debug && this.logger.isDebugEnabled)
                  {
                     this.logger.d("fmod","getWaveBankInfo " + param1 + ": " + _loc2_.join(","));
                  }
                  this.waveBankInfos[param1] = _loc2_;
               }
               else
               {
                  this.logger.error("FmodSoundDriver: the FmodManifest doesn\'t have an entry for: " + param1);
               }
            }
            return _loc2_;
         }
         return null;
      }
      
      public function get fmodManfest() : FmodManifest
      {
         return this._fmodManifest;
      }
      
      public function inferSkuFromEventPath(param1:String) : String
      {
         var _loc2_:String = null;
         if(!param1)
         {
            return null;
         }
         for each(_loc2_ in this._knownSkus)
         {
            if(StringUtil.startsWith(param1,_loc2_))
            {
               return _loc2_;
            }
         }
         return this._skuFallback;
      }
      
      private function addEventBankReference(param1:ISoundEventId, param2:String, param3:String) : void
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:FmodFsbResource = null;
         if(!param3)
         {
            return;
         }
         if(!param2)
         {
            param2 = this.inferSkuFromEventPath(param3);
         }
         var _loc4_:Array = this.internalReleaseEventBankRefs(param1);
         var _loc5_:Array = _loc4_;
         var _loc6_:Array = this.getWaveBankInfo(param3);
         if(_loc6_)
         {
            if(!_loc5_)
            {
               _loc5_ = [];
            }
            for each(_loc7_ in _loc6_)
            {
               _loc8_ = this.getResourcePath(param2,_loc7_);
               if(_loc8_)
               {
                  _loc9_ = this.resman.getResource(_loc8_,FmodFsbResource) as FmodFsbResource;
                  if(_loc9_)
                  {
                     if(!_loc9_.bankName)
                     {
                        _loc9_.bankName = _loc7_;
                     }
                     if(!_loc9_.soundDriver)
                     {
                        _loc9_.soundDriver = this;
                     }
                     _loc5_.push(_loc9_);
                  }
               }
            }
            this._playingResources[param1] = _loc5_;
         }
      }
      
      public function getResourcePath(param1:String, param2:String) : String
      {
         return FmodSoundDefBundle.getFsbPath(param1,param2,".bank");
      }
      
      private function internalReleaseEventBankRefs(param1:ISoundEventId) : Array
      {
         var _loc4_:FmodFsbResource = null;
         var _loc2_:int = getTimer() + _eventExpirationMs;
         var _loc3_:Array = this._playingResources[param1];
         if(_loc3_)
         {
            if(_debug && this.logger.isDebugEnabled)
            {
               this.logger.d("FMOD"," ---------------- internalReleaseEventBankRefs " + param1 + " " + this.getEventName(param1,"<unknown event id>"));
            }
            for each(_loc4_ in _loc3_)
            {
               if(_loc4_)
               {
                  if(_debug && this.logger.isDebugEnabled)
                  {
                     this.logger.d("FMOD","               -- old " + _loc4_ + " (refs=" + _loc4_.refcount.refcount + ") at " + _loc2_ + "ms");
                  }
                  this._cleanupResources.push({
                     "expire":_loc2_,
                     "rs":_loc4_,
                     "systemid":param1
                  });
               }
            }
            _loc3_.splice(0,_loc3_.length);
         }
         return _loc3_;
      }
      
      private function removeEventBankReference(param1:ISoundEventId) : void
      {
         if(!param1)
         {
            return;
         }
         this.internalReleaseEventBankRefs(param1);
         delete this._playingResources[param1];
      }
      
      private function removePlayingEvent(param1:ISoundEventId) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:String = this._playing[param1];
         if(_loc2_)
         {
            if(_debug && this.logger.isDebugEnabled)
            {
               this.logger.d("fmod","FmodStudioSoundDriver.removePlayingEvent [" + param1 + "] [" + _loc2_ + "]");
            }
         }
         this.removeEventBankReference(param1);
         delete this._playing[param1];
         if(_loc2_)
         {
            dispatchEvent(new SoundDriverEvent(SoundDriverEvent.STOP,param1,_loc2_,null,0,null));
         }
      }
      
      private function addPlayingEvent(param1:ISoundEventId, param2:String) : void
      {
         if(!param1 || !param2)
         {
            return;
         }
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.addPlayingEvent [" + param1 + "] [" + param2 + "]");
         }
         this._playing[param1] = param2;
         this.addEventBankReference(param1,null,param2);
         dispatchEvent(new SoundDriverEvent(SoundDriverEvent.PLAY,param1,param2,null,0,null));
      }
      
      public function normalizeEventId(param1:String) : String
      {
         if(!param1)
         {
            return param1;
         }
         return param1.replace(/^event:\//,"");
      }
      
      public function playEvent(param1:String) : ISoundEventId
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.playEvent [" + param1 + "]");
         }
         var _loc2_:FmodEventId = this.fmod.playEvent(param1);
         var _loc3_:FmodStudioSoundEventId = !!_loc2_ ? new FmodStudioSoundEventId(_loc2_) : null;
         if(_loc3_)
         {
            this.addPlayingEvent(_loc3_,param1);
         }
         if(this._fmodManifest && _debug && this.logger.isDebugEnabled)
         {
         }
         return _loc3_;
      }
      
      public function stopEvent(param1:ISoundEventId, param2:Boolean) : Boolean
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.stopEvent " + param1 + " " + this.getEventNameOrDesc(param1) + " " + param2);
         }
         var _loc3_:Boolean = this.fmod.stopEvent(getEventId(param1),param2);
         this.isPlaying(param1);
         return _loc3_;
      }
      
      public function isLooping(param1:ISoundEventId) : Boolean
      {
         var _loc2_:Boolean = false;
         if(param1)
         {
            _loc2_ = this.fmod.isLooping(getEventId(param1));
         }
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.isLooping " + this.getEventNameOrDesc(param1) + " result: " + _loc2_);
         }
         return _loc2_;
      }
      
      public function isPlaying(param1:ISoundEventId) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         var _loc2_:Boolean = this.fmod.isPlaying(getEventId(param1));
         if(!_loc2_)
         {
            this.removePlayingEvent(param1);
         }
         if(!_loc2_ && _debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.isPlaying " + this.getEventNameOrDesc(param1) + " result: " + _loc2_);
         }
         return _loc2_;
      }
      
      public function getEventName(param1:ISoundEventId, param2:String) : String
      {
         var _loc3_:String = this.fmod.getEventName(getEventId(param1));
         return _loc3_ != null ? _loc3_ : param2;
      }
      
      public function getEventNameOrDesc(param1:ISoundEventId) : String
      {
         if(param1 == null)
         {
            return "<null>";
         }
         var _loc2_:String = this.getEventName(param1,null);
         if(_loc2_ == null)
         {
            return "<name unknown> " + param1.toString();
         }
         return _loc2_;
      }
      
      public function checkPlaying() : void
      {
         var _loc1_:* = null;
         var _loc2_:ISoundEventId = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:ISoundEventId = null;
         var _loc6_:Boolean = false;
         var _loc7_:Object = null;
         var _loc8_:FmodFsbResource = null;
         if(this.clear.length > 0)
         {
            this.clear.splice(0,this.clear.length);
         }
         for(_loc1_ in this._playing)
         {
            _loc5_ = _loc1_ as ISoundEventId;
            _loc6_ = this.isPlaying(_loc5_);
            if(!_loc6_)
            {
               this.clear.push(_loc5_);
            }
         }
         for each(_loc2_ in this.clear)
         {
            this.removePlayingEvent(_loc2_);
         }
         _loc3_ = getTimer();
         _loc4_ = 0;
         while(_loc4_ < this._cleanupResources.length)
         {
            _loc7_ = this._cleanupResources[_loc4_];
            if(_loc3_ < _loc7_.expire)
            {
               break;
            }
            _loc8_ = _loc7_.rs;
            if(_loc8_)
            {
               if(_debug && this.logger.isDebugEnabled)
               {
                  this.logger.d("fmod","FmodStudioSoundDriver.checkPlaying DEFERRED RELEASE of " + _loc8_ + " (refs=" + _loc8_.refcount.refcount + ") for " + _loc7_.systemid);
               }
               _loc8_.release();
            }
            _loc4_++;
         }
         if(_loc4_ > 0)
         {
            this._cleanupResources.splice(0,_loc4_);
         }
      }
      
      public function reverbAmbientPreset(param1:String) : Boolean
      {
         if(!param1)
         {
            param1 = "default";
         }
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.reverbAmbientPreset " + param1);
         }
         this.fmod.stopAllSnapshots();
         if(this.fmod.startSnapshot(param1))
         {
            this._reverb = param1;
            return true;
         }
         return false;
      }
      
      public function unloadSound() : void
      {
      }
      
      public function get disposed() : Boolean
      {
         return this._disposed;
      }
      
      public function dispose() : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.dispose");
         }
         this._disposed = true;
         this.fmod.dispose();
         this.fmod = null;
      }
      
      private function onStatusEvent(param1:StatusEvent) : void
      {
         if(this.disposed)
         {
            return;
         }
         if(param1.level == "error")
         {
            if(param1.code.indexOf("FMOD_System_Update") > 0 || param1.code.indexOf("FMOD_EventSystem_Update") > 0)
            {
               this.logger.info("FmodStudioSoundDriver.onStatusEvent " + param1.level + ": " + param1.code);
            }
            else
            {
               this.logger.error("FmodStudioSoundDriver.onStatusEvent " + param1.level + ": " + param1.code);
            }
         }
         else if(param1.level == "debug")
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.d("fmod","FmodStudioSoundDriver.onStatusEvent " + param1.level + ": " + param1.code);
            }
         }
         else
         {
            if(param1.code.indexOf("event_callback ") == 0)
            {
               return;
            }
            this.logger.info("FmodStudioSoundDriver.onStatusEvent " + param1.level + ": " + param1.code);
         }
      }
      
      private function eventCallbackHandler(param1:String) : void
      {
         var _loc2_:Array = param1.split(" ");
         var _loc3_:String = _loc2_.length > 1 ? _loc2_[1] : "<unknown systemid>";
         var _loc4_:int = _loc2_.length > 2 ? int(_loc2_[2]) : 0;
         var _loc5_:String = _loc4_ >= 0 && _loc4_ < this.fmod_event_callbacktype.length ? this.fmod_event_callbacktype[_loc4_] : null;
         var _loc6_:* = _loc2_.length > 3 ? _loc2_[3] : null;
         var _loc7_:* = _loc2_.length > 4 ? _loc2_[4] : null;
         this.logger.info("FMOD event_callback " + _loc3_ + " " + _loc5_ + " " + _loc6_ + " " + _loc7_);
      }
      
      public function preloadSoundDefData(param1:String, param2:Vector.<ISoundDef>) : ISoundDefBundle
      {
         var _loc3_:ResourceManager = this.system.resman as ResourceManager;
         return new FmodFsbSoundDefBundle(param1,this,this.logger,_loc3_,param2);
      }
      
      public function get allSoundDefBundles() : Vector.<ISoundDefBundle>
      {
         return FmodSoundDefBundle.allBundles;
      }
      
      public function get preloader() : ISoundPreloader
      {
         return new FmodFsbPreloader(this.resman,this);
      }
      
      public function init(param1:Boolean, param2:int) : Boolean
      {
         var dir:File = null;
         var profile:Boolean = param1;
         var profilePort:int = param2;
         try
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.d("fmod","FmodStudioSoundDriver.load creating extension context " + FmodStudio.CONTEXT_ID);
               dir = ExtensionContext.getExtensionDirectory(FmodStudio.CONTEXT_ID);
               this.logger.d("fmod","FmodSoundDriver extension dir " + dir.url);
            }
            this.fmod = new FmodStudio();
            if(this.logger.isDebugEnabled)
            {
               this.logger.d("fmod","FmodStudioSoundDriver.load created extension context " + this.fmod);
            }
            if(!this.fmod.hasContext())
            {
               throw new ArgumentError("failed to create context");
            }
         }
         catch(error:Error)
         {
            fmod = null;
            logger.error("FmodSoundDriver initialization failed: " + error.message);
            logger.error("Does the extension id in extension.xml match the id used in createExtensionContext?");
            throw new ArgumentError("error while creating context: " + error.getStackTrace());
         }
         this.fmod.addEventListener(StatusEvent.STATUS,this.onStatusEvent);
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodSoundDriver loaded");
         }
         if(this.initFMOD(profile,profilePort))
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.d("fmod","FmodSoundDriver initialized");
            }
            return true;
         }
         this.logger.info("FmodStudioSoundDriver.init FAILED");
         return false;
      }
      
      public function pause() : void
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.pause");
         }
         this.fmod.pause();
      }
      
      public function unpause() : void
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.unpause");
         }
         this.fmod.unpause();
      }
      
      public function setEventParameter(param1:String, param2:String, param3:Number) : Boolean
      {
         var _loc7_:FmodEventId = null;
         var _loc8_:Boolean = false;
         var _loc9_:Dictionary = null;
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setEventParameter " + param1 + " " + param2 + " " + param3);
         }
         var _loc4_:int = this.fmod.getNumEventInsts(param1);
         var _loc5_:* = _loc4_ > 0;
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            _loc7_ = this.fmod.getEventInst(param1,_loc6_);
            _loc8_ = this.fmod.setEventParameterValueByName(_loc7_,param2,param3);
            this.setSustainPointTimelinePos(param1,_loc7_,param2,param3);
            if(!_loc8_)
            {
               _loc5_ = false;
               break;
            }
            _loc6_++;
         }
         if(_loc5_)
         {
            _loc9_ = this._params[param1];
            if(!_loc9_)
            {
               _loc9_ = new Dictionary();
               this._params[param1] = _loc9_;
            }
            _loc9_[param2] = param3;
            dispatchEvent(new SoundDriverEvent(SoundDriverEvent.PARAM,null,param1,param2,param3,null));
         }
         return _loc5_;
      }
      
      public function getEventParameter(param1:String, param2:String) : Number
      {
         var _loc3_:int = this.fmod.getNumEventInsts(param1);
         var _loc4_:FmodEventId = _loc3_ > 0 ? this.fmod.getEventInst(param1,0) : null;
         var _loc5_:Number = 0;
         if(_loc4_ != null)
         {
            _loc5_ = this.fmod.getEventParameterValueByName(_loc4_,param2);
         }
         var _loc6_:Dictionary = this._params[param1];
         if(!_loc6_)
         {
            _loc6_ = new Dictionary();
            this._params[param1] = _loc6_;
         }
         if(_loc6_[param2] != _loc5_)
         {
            _loc6_[param2] = _loc5_;
            dispatchEvent(new SoundDriverEvent(SoundDriverEvent.PARAM,null,param1,param2,_loc5_,null));
         }
         if(_debug && this.logger.isDebugEnabled)
         {
         }
         return _loc5_;
      }
      
      public function hasEventParameter(param1:String, param2:String) : Boolean
      {
         var _loc3_:Boolean = this.fmod.hasEventDefParameter(param1,param2) as Boolean;
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.hasEventParameter " + param1 + " " + param2 + " result: " + _loc3_);
         }
         return _loc3_;
      }
      
      public function systemUpdate() : Boolean
      {
         var _loc1_:Boolean = this.fmod.systemUpdate();
         FmodSoundDefBundle.checkBundlesFinishing(this.logger);
         return _loc1_;
      }
      
      public function netEventSystem_Init(param1:int) : Boolean
      {
         return true;
      }
      
      public function netEventSystem_Update() : Boolean
      {
         return true;
      }
      
      public function netEventSystem_Shutdown() : Boolean
      {
         return true;
      }
      
      public function get playing() : Dictionary
      {
         return this._playing;
      }
      
      public function getParams(param1:String) : Dictionary
      {
         return this._params[param1];
      }
      
      public function get reverb() : String
      {
         return this._reverb;
      }
      
      public function getNumEventParameters(param1:ISoundEventId) : int
      {
         var _loc2_:int = this.fmod.getNumEventParameters(getEventId(param1)) as int;
         if(_debug && this.logger.isDebugEnabled)
         {
         }
         return _loc2_;
      }
      
      public function getEventTimelinePosition(param1:ISoundEventId) : int
      {
         return this.fmod.getEventTimelinePosition(getEventId(param1)) as int;
      }
      
      public function getEventParameterName(param1:ISoundEventId, param2:int) : String
      {
         var _loc3_:String = this.fmod.getEventParameterName(getEventId(param1),param2) as String;
         if(_debug && this.logger.isDebugEnabled)
         {
         }
         return _loc3_;
      }
      
      public function getEventParameterValue(param1:ISoundEventId, param2:int) : Number
      {
         var _loc3_:Number = this.fmod.getEventParameterValue(getEventId(param1),param2) as Number;
         if(_debug && this.logger.isDebugEnabled)
         {
         }
         return _loc3_;
      }
      
      public function getEventParameterValueByName(param1:ISoundEventId, param2:String) : Number
      {
         var _loc3_:Number = this.fmod.getEventParameterValueByName(getEventId(param1),param2) as Number;
         if(_debug && this.logger.isDebugEnabled)
         {
         }
         return _loc3_;
      }
      
      public function getEventParameterVelocity(param1:ISoundEventId, param2:int) : Number
      {
         if(_debug && this.logger.isDebugEnabled)
         {
         }
         return 0;
      }
      
      public function getEventParameterSeekSpeed(param1:ISoundEventId, param2:int) : Number
      {
         if(_debug && this.logger.isDebugEnabled)
         {
         }
         return 0;
      }
      
      public function setEventParameterValue(param1:ISoundEventId, param2:int, param3:Number) : Boolean
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setEventParameterValue " + this.getEventNameOrDesc(param1) + " " + param2 + " value: " + param3);
         }
         var _loc4_:FmodEventId = getEventId(param1);
         var _loc5_:Boolean = this.fmod.setEventParameterValue(_loc4_,param2,param3);
         var _loc6_:String = this.fmod.getEventParameterName(_loc4_,param2);
         this.setSustainPointTimelinePos(null,_loc4_,_loc6_,param3);
         return _loc5_;
      }
      
      public function setEventParameterValueByName(param1:ISoundEventId, param2:String, param3:Number) : Boolean
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setEventParameterValueByName " + this.getEventNameOrDesc(param1) + " " + param2 + " value: " + param3);
         }
         if(!param2)
         {
            throw new ArgumentError("setEventParameterValueByName invalid name");
         }
         var _loc4_:FmodEventId = getEventId(param1);
         var _loc5_:Boolean = this.fmod.setEventParameterValueByName(_loc4_,param2,param3);
         this.setSustainPointTimelinePos(null,_loc4_,param2,param3);
         return _loc5_;
      }
      
      private function setSustainPointTimelinePos(param1:String, param2:FmodEventId, param3:String, param4:Number) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         if(!ENABLE_SUSTAIN_POINT_WORKAROUND)
         {
            return;
         }
         if(param1 == null)
         {
            param1 = this.fmod.getEventName(param2);
         }
         var _loc5_:FmodManifestEvent = this._fmodManifest.getEvent("event:/" + param1);
         if(_loc5_ == null)
         {
            this.logger.error("FmodStudioSoundDriver.setSustainPointTimelinePos: the FmodManifest doesn\'t have an entry for: " + param1);
            return;
         }
         var _loc6_:Boolean = false;
         var _loc7_:int = -1;
         if(param3 == "complete")
         {
            _loc8_ = castNumberToNearbyInt(param4,0.01);
            if(_loc8_ == 1 || _loc8_ == 2)
            {
               if(param4 - 1 < _loc5_.completeMarkerPos.length)
               {
                  _loc7_ = int(_loc5_.completeMarkerPos[param4 - 1] * 1000);
                  this.fmod.setEventTimelinePos(param2,_loc7_);
                  _loc6_ = true;
               }
            }
            if(!_loc6_ && !_loc5_.isOldSustPt())
            {
               this.logger.error("FmodStudioSoundDriver.setSustainPointTimelinePos: could not find a marker for \'complete\' param: " + param1 + " value: " + param4);
            }
         }
         if(!_loc6_ && _loc5_.isOldSustPt() && _loc5_.oldSustPtParam == param3)
         {
            _loc9_ = _loc5_.oldSustPtScale * (param4 - _loc5_.oldSustPtRangeMin);
            _loc7_ = int(_loc9_ * 1000);
            this.fmod.setEventTimelinePos(param2,_loc7_);
            _loc6_ = true;
         }
         if(_loc6_ && _debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setSustainPointTimelinePos " + param1 + " " + param3 + " value: " + param4 + " set timeline pos to: " + _loc7_);
         }
      }
      
      public function set3dListenerPosition(param1:int, param2:Number, param3:Number, param4:Number) : Boolean
      {
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.set3dListenerPosition " + param1 + " (" + param2.toPrecision(5) + ", " + param3.toPrecision(5) + ", " + param4.toPrecision(5) + ")");
         }
         return this.fmod.set3dListenerPosition(param1,param2,param3,param4) as Boolean;
      }
      
      public function set3dNumListeners(param1:int) : Boolean
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.set3dNumListeners " + param1);
         }
         return this.fmod.set3dNumListeners(param1) as Boolean;
      }
      
      public function set3dEventPosition(param1:ISoundEventId, param2:Number, param3:Number, param4:Number) : Boolean
      {
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.set3dEventPosition " + this.getEventNameOrDesc(param1) + " (" + param2.toPrecision(5) + ", " + param3.toPrecision(5) + ", " + param4.toPrecision(5) + ")");
         }
         return this.fmod.set3dEventPosition(getEventId(param1),param2,param3,param4) as Boolean;
      }
      
      public function getNumEventCategories(param1:String) : int
      {
         var _loc2_:int = this.fmod.getNumBusChildren(param1) as int;
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.getNumEventCategories " + param1 + " result: " + _loc2_);
         }
         return _loc2_;
      }
      
      public function getEventCategoryName(param1:String, param2:int) : String
      {
         param1 = this.fmod.getBusChildName(param1,param2) as String;
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.getEventCategoryName " + param1 + " " + param2 + " result: " + param1);
         }
         return param1;
      }
      
      public function getEventCategoryMute(param1:String) : Boolean
      {
         var _loc2_:Boolean = this.fmod.getBusMute(param1) as Boolean;
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.getEventCategoryMute " + param1 + " result: " + _loc2_);
         }
         return _loc2_;
      }
      
      public function getEventCategoryVolume(param1:String) : Number
      {
         var _loc2_:Number = this.fmod.getBusVolume(param1) as Number;
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.getEventCategoryVolume " + param1 + " result: " + _loc2_.toPrecision(5));
         }
         return _loc2_;
      }
      
      public function setEventCategoryVolume(param1:String, param2:Number) : Boolean
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setEventCategoryVolume " + param1 + " " + param2);
         }
         return this.fmod.setBusVolume(param1,param2) as Boolean;
      }
      
      public function setEventCategoryMute(param1:String, param2:Boolean) : Boolean
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setEventCategoryMute " + param1 + " " + param2);
         }
         if(param1 == SFX_BUS)
         {
            this.fmod.setBusMute(REVERB_BUS,param2);
         }
         return this.fmod.setBusMute(param1,param2) as Boolean;
      }
      
      public function getMusicCategoryMute() : Boolean
      {
         var _loc1_:Boolean = this.fmod.getBusMute(MUSIC_BUS) as Boolean;
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.getMusicCategoryMute result: " + _loc1_);
         }
         return _loc1_;
      }
      
      public function getMusicCategoryVolume() : Number
      {
         var _loc1_:Number = this.fmod.getBusVolume(MUSIC_BUS) as Number;
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.getMusicCategoryVolume result: " + _loc1_);
         }
         return _loc1_;
      }
      
      public function setMusicCategoryVolume(param1:Number) : Boolean
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setMusicCategoryVolume " + param1.toPrecision(5));
         }
         return this.fmod.setBusVolume(MUSIC_BUS,param1) as Boolean;
      }
      
      public function setMusicCategoryMute(param1:Boolean) : Boolean
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setMusicCategoryMute " + param1);
         }
         return this.fmod.setBusMute(MUSIC_BUS,param1) as Boolean;
      }
      
      public function setEventVolume(param1:ISoundEventId, param2:Number) : Boolean
      {
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setEventVolume " + this.getEventNameOrDesc(param1) + " " + param2.toPrecision(5));
         }
         return this.fmod.setEventVolume(getEventId(param1),param2) as Boolean;
      }
      
      public function setEventPitchSemitones(param1:ISoundEventId, param2:Number) : Boolean
      {
         if(_debug && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.setEventPitchSemitones " + this.getEventNameOrDesc(param1) + " " + param2);
         }
         return this.fmod.setEventPitchMultiplier(getEventId(param1),param2) as Boolean;
      }
      
      public function getEventVolume(param1:ISoundEventId) : Number
      {
         var _loc2_:Number = this.fmod.getEventVolume(getEventId(param1)) as Number;
         if(_debug && this._debugVerbose && this.logger.isDebugEnabled)
         {
            this.logger.d("fmod","FmodStudioSoundDriver.getEventVolume " + this.getEventNameOrDesc(param1) + " result: " + _loc2_);
         }
         return _loc2_;
      }
      
      public function get debugSoundDriver() : Boolean
      {
         return _debug;
      }
      
      public function set debugSoundDriver(param1:Boolean) : void
      {
         _debug = param1;
      }
      
      public function createEventIdFromDesc(param1:String) : ISoundEventId
      {
         return FmodStudioSoundEventId.createFromDesc(param1);
      }
   }
}
