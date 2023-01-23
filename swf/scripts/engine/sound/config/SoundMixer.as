package engine.sound.config
{
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.core.util.AppInfo;
   import engine.sound.ISoundDriver;
   import flash.events.EventDispatcher;
   
   public class SoundMixer extends EventDispatcher implements ISoundMixer
   {
      
      public static const _PREF_OPTION_SFX:String = "option_sfx";
      
      public static const _PREF_OPTION_MUSIC:String = "option_music";
      
      public static const PREF_MUTE_MASTER:String = "mixer_mute_master";
      
      public static const PREF_MUTE_SFX:String = "mixer_mute_sfx";
      
      public static const PREF_MUTE_MUSIC:String = "mixer_mute_music";
      
      public static const PREF_VOLUME_MASTER:String = "mixer_volume_master";
      
      public static const PREF_VOLUME_SFX:String = "mixer_volume_sfx";
      
      public static const PREF_VOLUME_MUSIC:String = "mixer_volume_music";
       
      
      private var _volumeMusic:Number = 1;
      
      private var _volumeMaster:Number = 1;
      
      private var _volumeSfx:Number = 1;
      
      private var _muteMaster:Boolean;
      
      private var _muteSfx:Boolean;
      
      private var _muteMusic:Boolean;
      
      private var system:ISoundSystem;
      
      private var logger:ILogger;
      
      private var _driver:ISoundDriver;
      
      private var _appInfo:AppInfo;
      
      private var prefs:PrefBag;
      
      private var _initializing:Boolean;
      
      private var _videoMixerMode:Boolean;
      
      public function SoundMixer(param1:ISoundSystem, param2:ILogger, param3:AppInfo, param4:PrefBag)
      {
         super();
         this.system = param1;
         this.logger = param2;
         this._appInfo = param3;
         this.prefs = param4;
         param4.assignDefault(PREF_VOLUME_MASTER,1);
         param4.assignDefault(PREF_VOLUME_SFX,1);
         param4.assignDefault(PREF_VOLUME_MUSIC,1);
         param4.addEventListener(PrefBag.EVENT_LOADED,this.refreshPrefs);
         this.refreshPrefs();
      }
      
      public function set driver(param1:ISoundDriver) : void
      {
         this._driver = param1;
         this.updateDriver();
      }
      
      private function _migrateOldPrefs() : void
      {
         this._migrateOldPref(_PREF_OPTION_SFX,PREF_MUTE_SFX,true);
         this._migrateOldPref(_PREF_OPTION_MUSIC,PREF_MUTE_MUSIC,true);
      }
      
      private function _migrateOldPref(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc4_:* = this.prefs.getPref(param1);
         if(_loc4_ != undefined)
         {
            this.prefs.setPref(param2,param3 ? !_loc4_ : _loc4_);
            this.prefs.setPref(param1,undefined);
         }
      }
      
      public function refreshPrefs() : void
      {
         this._initializing = true;
         this.volumeMaster = this.prefs.getPref(PREF_VOLUME_MASTER,1);
         this.volumeSfx = this.prefs.getPref(PREF_VOLUME_SFX,1);
         this.volumeMusic = this.prefs.getPref(PREF_VOLUME_MUSIC,1);
         this.muteMaster = this.prefs.getPref(PREF_MUTE_MASTER);
         this.muteSfx = this.prefs.getPref(PREF_MUTE_SFX);
         this.muteMusic = this.prefs.getPref(PREF_MUTE_MUSIC);
         this._initializing = false;
         this.updateDriver();
      }
      
      private function updateDriver() : void
      {
         var _loc1_:Number = NaN;
         if(this._driver)
         {
            _loc1_ = this.volumeVideo * this.volumeMaster;
            if(this._videoMixerMode)
            {
               this._driver.setMusicCategoryVolume(_loc1_);
               this._driver.setMusicCategoryMute(this._muteMaster || _loc1_ <= 0);
               this._driver.setEventCategoryVolume("sfx",_loc1_);
               this._driver.setEventCategoryVolume("vo",_loc1_);
               this._driver.setEventCategoryMute("sfx",this._muteMaster || _loc1_ <= 0);
            }
            else
            {
               this._driver.setMusicCategoryVolume(this._volumeMusic * this._volumeMaster) || this.logger.error("unable to set music volume");
               this._driver.setMusicCategoryMute(this._muteMaster || this._muteMusic) || this.logger.error("unable to set music mute");
               this._driver.setEventCategoryVolume("sfx",this._volumeSfx * this._volumeMaster) || this.logger.error("unable to set sfx volume");
               this._driver.setEventCategoryVolume("vo",this._volumeSfx * this._volumeMaster) || this.logger.error("unable to set vo volume");
               this._driver.setEventCategoryMute("sfx",this._muteMaster || this._muteSfx) || this.logger.error("unable to set sfx mute");
               this._driver.setEventCategoryMute("vo",this._muteMaster || this._muteSfx) || this.logger.error("unable to set vo mute");
            }
         }
         this._appInfo.emitPlatformEvent("mute_videos",_loc1_ <= 0);
      }
      
      public function set musicEnabled(param1:Boolean) : void
      {
         this.muteMusic = !param1;
      }
      
      public function get musicEnabled() : Boolean
      {
         return !this._muteMusic;
      }
      
      public function set sfxEnabled(param1:Boolean) : void
      {
         this.muteSfx = !param1;
      }
      
      public function get sfxEnabled() : Boolean
      {
         return !this._muteSfx;
      }
      
      public function set volumeMaster(param1:Number) : void
      {
         if(this._volumeMaster == param1)
         {
            return;
         }
         this._volumeMaster = param1;
         if(!this._initializing)
         {
            this.updateDriver();
            this.prefs.setPref(PREF_VOLUME_MASTER,this._volumeMaster);
         }
      }
      
      public function get volumeMaster() : Number
      {
         return this._volumeMaster;
      }
      
      public function set volumeSfx(param1:Number) : void
      {
         if(this._volumeSfx == param1)
         {
            return;
         }
         this._volumeSfx = param1;
         if(!this._initializing)
         {
            this.updateDriver();
            this.prefs.setPref(PREF_VOLUME_SFX,this._volumeSfx);
         }
      }
      
      public function get volumeSfx() : Number
      {
         return this._volumeSfx;
      }
      
      public function set volumeMusic(param1:Number) : void
      {
         if(this._volumeMusic == param1)
         {
            return;
         }
         this._volumeMusic = param1;
         if(!this._initializing)
         {
            this.updateDriver();
            this.prefs.setPref(PREF_VOLUME_MUSIC,this._volumeMusic);
         }
      }
      
      public function get volumeMusic() : Number
      {
         return this._volumeMusic;
      }
      
      public function get volumeVideo() : Number
      {
         return this.videoEnabled ? Math.max(this._volumeMusic,this._volumeSfx) : 0;
      }
      
      public function get videoEnabled() : Boolean
      {
         return !this.muteVideo;
      }
      
      public function get muteVideo() : Boolean
      {
         return !this.system.enabled || this._muteMaster || this._muteMusic && this._muteSfx;
      }
      
      public function set videoMixerMode(param1:Boolean) : void
      {
         if(this._videoMixerMode == param1)
         {
            return;
         }
         this._videoMixerMode = param1;
         this.updateDriver();
      }
      
      public function get videoMixerMode() : Boolean
      {
         return this._videoMixerMode;
      }
      
      public function set muteMaster(param1:Boolean) : void
      {
         if(this._muteMaster == param1)
         {
            return;
         }
         this._muteMaster = param1;
         if(!this._initializing)
         {
            this.updateDriver();
            this.prefs.setPref(PREF_MUTE_MASTER,this._muteMaster);
         }
      }
      
      public function get muteMaster() : Boolean
      {
         return this._muteMaster;
      }
      
      public function set muteSfx(param1:Boolean) : void
      {
         if(this._muteSfx == param1)
         {
            return;
         }
         this._muteSfx = param1;
         if(!this._initializing)
         {
            this.updateDriver();
            this.prefs.setPref(PREF_MUTE_SFX,this._muteSfx);
            dispatchEvent(new SoundMixerEvent(SoundMixerEvent.SFX_ENABLED));
         }
      }
      
      public function get muteSfx() : Boolean
      {
         return this._muteSfx;
      }
      
      public function set muteMusic(param1:Boolean) : void
      {
         if(this._muteMusic == param1)
         {
            return;
         }
         this._muteMusic = param1;
         if(!this._initializing)
         {
            this.updateDriver();
            this.prefs.setPref(PREF_MUTE_MUSIC,this._muteMusic);
            dispatchEvent(new SoundMixerEvent(SoundMixerEvent.MUSIC_ENABLED));
         }
      }
      
      public function get muteMusic() : Boolean
      {
         return this._muteMusic;
      }
      
      public function setMute(param1:String, param2:Boolean) : void
      {
         var _loc3_:String = "mute" + param1.charAt(0).toUpperCase() + param1.substring(1);
         this[_loc3_] = param2;
      }
      
      public function getMute(param1:String) : Boolean
      {
         var _loc2_:String = "mute" + param1.charAt(0).toUpperCase() + param1.substring(1);
         return this[_loc2_];
      }
      
      public function setVolume(param1:String, param2:Number) : void
      {
         var _loc3_:String = "volume" + param1.charAt(0).toUpperCase() + param1.substring(1);
         this[_loc3_] = param2;
      }
      
      public function getVolume(param1:String) : Number
      {
         var _loc2_:String = "volume" + param1.charAt(0).toUpperCase() + param1.substring(1);
         return this[_loc2_];
      }
   }
}
