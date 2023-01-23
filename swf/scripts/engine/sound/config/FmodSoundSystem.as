package engine.sound.config
{
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.core.util.AppInfo;
   import engine.def.EngineJsonDef;
   import engine.resource.IResourceManager;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefResource;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.ISoundDriver;
   import engine.sound.NullSoundDriver;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.ISoundLibrary;
   import engine.sound.def.SoundDef;
   import engine.sound.def.SoundLibrary;
   import engine.sound.def.SoundLibraryVars;
   import engine.sound.view.ISound;
   import engine.sound.view.ISoundController;
   import engine.sound.view.SampleSound;
   import engine.sound.view.SoundController;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class FmodSoundSystem extends EventDispatcher implements ISoundSystem, ISoundDefBundleListener
   {
       
      
      private var _driver:ISoundDriver;
      
      private var staticSoundLibrary:ISoundLibrary;
      
      private var staticSoundLibraryUrl:String;
      
      private var soundDriverClazz:Class;
      
      private var _ready:Boolean;
      
      private var _enabled:Boolean = true;
      
      public var _resman:ResourceManager;
      
      public var fsbWaitLoad:Dictionary;
      
      public var streamWaitLoad:Dictionary;
      
      private var _music:ISound;
      
      private var _voDuckingMultiplier:Number = 0.4;
      
      private var _voDuckingSpeed:Number = 0.0004;
      
      private var _popDuckingMultiplier:Number = 0.5;
      
      private var soundReadyCallback:Function;
      
      public var logger:ILogger;
      
      private var _appInfo:AppInfo;
      
      private var staticSoundController:SoundController;
      
      private var _pauseCount:uint = 0;
      
      private var _mixer:SoundMixer;
      
      private var callbackSoundControllerComplete:Function;
      
      private var me_id:int = 0;
      
      private var _voDuck:Number = 1;
      
      private var _vo:ISound;
      
      private var bundlePlayingBySound:Dictionary;
      
      private var clearPlayingBundleDefs:Vector.<ISound>;
      
      private var _ducking:Boolean;
      
      public function FmodSoundSystem(param1:ResourceManager, param2:String, param3:Class, param4:Function, param5:AppInfo, param6:PrefBag)
      {
         this.fsbWaitLoad = new Dictionary();
         this.streamWaitLoad = new Dictionary();
         this.bundlePlayingBySound = new Dictionary();
         this.clearPlayingBundleDefs = new Vector.<ISound>();
         super();
         this.logger = param5.logger;
         this._appInfo = param5;
         this._resman = param1;
         this.soundDriverClazz = param3;
         this.soundReadyCallback = param4;
         this.staticSoundLibraryUrl = param2;
         this._mixer = new SoundMixer(this,this.logger,this._appInfo,param6);
      }
      
      public function get mixer() : ISoundMixer
      {
         return this._mixer;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
      }
      
      public function init(param1:Boolean, param2:int) : void
      {
         var edr:DefResource;
         var profile:Boolean = param1;
         var profilePort:int = param2;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("FmodSoundSystem.init");
         }
         if(this.enabled)
         {
            try
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("FmodSoundSystem.init creating soundDriver from class: " + this.soundDriverClazz);
               }
               this.driver = new this.soundDriverClazz(this,this.logger);
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("FmodSoundSystem.init created soundDriver: " + this.driver);
               }
               if(!this.driver.init(profile,profilePort))
               {
                  this.logger.error("SoundDriver init failed");
                  this.driver = null;
               }
            }
            catch(e:Error)
            {
               logger.error("FmodSoundSystem.init Error creating SoundDriver: " + e + ": " + e.message);
               driver = null;
            }
         }
         if(!this.driver)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("FmodSoundSystem.init creating NullSoundDriver");
            }
            this.driver = new NullSoundDriver(this,this.logger);
            this._ready = true;
            this.soundReadyCallback();
            return;
         }
         edr = this.resman.getResource(this.staticSoundLibraryUrl,DefResource) as DefResource;
         edr.addResourceListener(this.staticSoundLibraryLoaded);
      }
      
      public function pause() : void
      {
         if(this._pauseCount == 0)
         {
            if(this.driver)
            {
               this.driver.pause();
            }
         }
         ++this._pauseCount;
      }
      
      public function unpause() : void
      {
         if(this._pauseCount > 0)
         {
            --this._pauseCount;
            if(this._pauseCount == 0)
            {
               this.driver.unpause();
            }
         }
      }
      
      private function checkSoundReady() : void
      {
         if(this._ready)
         {
            return;
         }
         if(this.staticSoundLibrary)
         {
            this._ready = true;
            this.soundReadyCallback();
         }
      }
      
      private function staticSoundLibraryLoaded(param1:Event) : void
      {
         var event:Event = param1;
         var sdr:DefResource = !!event ? event.target as DefResource : null;
         if(Boolean(sdr) && sdr.ok)
         {
            try
            {
               EngineJsonDef.validateThrow(sdr.jo,SoundLibraryVars.schema,this.logger);
            }
            catch(err:Error)
            {
               logger.error("Fmod fail: " + err);
            }
            this.staticSoundLibrary = new SoundLibraryVars(this.staticSoundLibraryUrl,sdr.jo,this.logger);
         }
         if(!this.staticSoundLibrary)
         {
            this.logger.info("Creating null staticSoundLibrary");
            this.staticSoundLibrary = new SoundLibrary("null_library",this.logger);
         }
         sdr.removeResourceListener(this.staticSoundLibraryLoaded);
         sdr.release();
         this.checkSoundReady();
      }
      
      public function createSoundController(param1:Function) : void
      {
         this.staticSoundController = new SoundController("static_sounds",this._driver,this.staticSoundControllerCompleteHandler,this.logger);
         this.staticSoundController.library = this.staticSoundLibrary;
      }
      
      private function staticSoundControllerCompleteHandler(param1:SoundController) : void
      {
         if(param1 == this.staticSoundController)
         {
            this._mixer.driver = this._driver;
            if(this.callbackSoundControllerComplete != null)
            {
               this.callbackSoundControllerComplete(this);
            }
         }
      }
      
      public function get ready() : Boolean
      {
         return this._ready;
      }
      
      public function set driver(param1:ISoundDriver) : void
      {
         if(this._driver != param1)
         {
            this._driver = param1;
         }
      }
      
      public function get resman() : IResourceManager
      {
         return this._resman;
      }
      
      public function get controller() : ISoundController
      {
         return this.staticSoundController;
      }
      
      public function get driver() : ISoundDriver
      {
         return this._driver;
      }
      
      public function stopMusicDef(param1:ISoundDef) : void
      {
         if(!param1)
         {
            this.music = null;
         }
         else if(this._music && this._music.def && param1.eventName == this._music.def.eventName)
         {
            this.music = null;
         }
      }
      
      public function stopMusicName(param1:String, param2:ISoundLibrary) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc3_:ISoundDef = param2.getSoundDef(param1);
         this.stopMusicDef(_loc3_);
      }
      
      public function playMusicEvent(param1:String, param2:String, param3:Boolean = false) : ISound
      {
         var _loc4_:SoundDef = new SoundDef();
         var _loc5_:String = "me_" + ++this.me_id;
         _loc4_.setup(param1,_loc5_,param2,param3);
         return this.playMusicDef(_loc4_);
      }
      
      public function get voDuck() : Number
      {
         return this._voDuck;
      }
      
      public function set voDuck(param1:Number) : void
      {
         if(this._voDuck == param1)
         {
            return;
         }
         this._voDuck = param1;
         this.driver.setEventCategoryVolume("music",this._voDuck * this.mixer.volumeMaster * this.mixer.volumeSfx);
         this.driver.setEventCategoryVolume("sfx",this._voDuck * this.mixer.volumeMaster * this.mixer.volumeSfx);
      }
      
      public function get vo() : ISound
      {
         return this._vo;
      }
      
      public function set vo(param1:ISound) : void
      {
         if(this._vo == param1)
         {
            return;
         }
         if(this._vo)
         {
            this._vo.stop(false);
         }
         this._vo = param1;
      }
      
      public function playVoDef(param1:ISoundDef) : ISound
      {
         if(!param1)
         {
            this.vo = null;
            return null;
         }
         if(param1.eventName)
         {
            this.vo = new SampleSound(param1,this.driver,null,this.logger);
            this._vo.start();
         }
         return this._vo;
      }
      
      public function playMusicDef(param1:ISoundDef) : ISound
      {
         if(!param1)
         {
            this.music = null;
            return null;
         }
         if(!this._music || !this._music.def || param1.eventName != this._music.def.eventName || !this._music.playing)
         {
            this.music = new SampleSound(param1,this.driver,null,this.logger);
         }
         return this.music;
      }
      
      public function playMusicName(param1:String, param2:ISoundLibrary) : ISound
      {
         if(!param1)
         {
            this.music = null;
            return null;
         }
         var _loc3_:ISoundDef = param2.getSoundDef(param1);
         return this.playMusicDef(_loc3_);
      }
      
      public function set music(param1:ISound) : void
      {
         if(this._music == param1)
         {
            return;
         }
         if(this._music && param1 && !this._music.def.allowDuplicateSounds && this._music.def.eventName == param1.def.eventName)
         {
            return;
         }
         if(this._music)
         {
            this._music.stop(false);
         }
         this._music = param1;
         if(Boolean(this._music) && !this._music.playing)
         {
            this._music.start();
            this.addSoundToBundle("music",this._music);
         }
      }
      
      private function addSoundToBundle(param1:String, param2:ISound) : void
      {
         var _loc3_:Vector.<ISoundDef> = null;
         var _loc4_:ISoundDefBundle = null;
         if(param2.playing)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("FmodSoundSystem grabbing bundle for " + param2);
            }
            _loc3_ = new Vector.<ISoundDef>();
            _loc3_.push(this._music.def);
            _loc4_ = this._driver.preloadSoundDefData(param1,_loc3_);
            this.bundlePlayingBySound[this._music] = _loc4_;
            _loc4_.addListener(this);
         }
      }
      
      public function updateSoundSystem(param1:int) : void
      {
         var _loc2_:ISound = null;
         var _loc3_:* = null;
         var _loc5_:ISoundDefBundle = null;
         for(_loc3_ in this.bundlePlayingBySound)
         {
            _loc2_ = _loc3_ as ISound;
            if(!_loc2_.playing)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("FmodSoundSystem releasing bundle for unplaying " + _loc2_.def);
               }
               _loc5_ = this.bundlePlayingBySound[_loc2_] as ISoundDefBundle;
               _loc5_.removeListener(this);
               this.clearPlayingBundleDefs.push(_loc2_);
            }
         }
         if(this.clearPlayingBundleDefs.length > 0)
         {
            for each(_loc2_ in this.clearPlayingBundleDefs)
            {
               delete this.bundlePlayingBySound[_loc2_];
            }
            this.clearPlayingBundleDefs.splice(0,this.clearPlayingBundleDefs.length);
         }
         this.driver.checkPlaying();
         var _loc4_:Boolean = Boolean(this._vo) && this._vo.playing && this._mixer.sfxEnabled;
         if(Boolean(this._vo) && !this._vo.playing)
         {
            this._vo = null;
         }
         if(_loc4_ && this._voDuck > this._voDuckingMultiplier)
         {
            this.voDuck = Math.max(this._voDuckingMultiplier,this._voDuck - param1 * this._voDuckingSpeed);
         }
         else if(!_loc4_ && this._voDuck < 1)
         {
            this.voDuck = Math.min(1,this._voDuck + param1 * this._voDuckingSpeed);
         }
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
      }
      
      public function get music() : ISound
      {
         return this._music;
      }
      
      public function get isMusicPlaying() : Boolean
      {
         return Boolean(this._music) && this._music.playing;
      }
      
      public function get ducking() : Boolean
      {
         return this._ducking;
      }
      
      public function set ducking(param1:Boolean) : void
      {
         this._ducking = param1;
         if(this._ducking)
         {
            this.driver.setEventCategoryVolume("sfx/duckable",this._popDuckingMultiplier * this.mixer.volumeMaster * this.mixer.volumeSfx);
         }
         else
         {
            this.driver.setEventCategoryVolume("sfx/duckable",this.mixer.volumeMaster * this.mixer.volumeSfx);
         }
      }
      
      public function set voDuckingMultiplier(param1:Number) : void
      {
         this._voDuckingMultiplier = param1;
      }
      
      public function set voDuckingSpeed(param1:Number) : void
      {
         this._voDuckingSpeed = param1;
      }
      
      public function set popDuckingMultiplier(param1:Number) : void
      {
         this._popDuckingMultiplier = param1;
      }
   }
}
