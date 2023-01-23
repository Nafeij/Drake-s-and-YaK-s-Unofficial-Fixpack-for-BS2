package engine.sound
{
   import engine.core.logging.ILogger;
   import engine.fmod.FmodManifest;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.ISoundDef;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class NullSoundDriver extends EventDispatcher implements ISoundDriver
   {
       
      
      private var _preloader:ISoundPreloader;
      
      private var _config:ISoundSystem;
      
      public function NullSoundDriver(param1:ISoundSystem, param2:ILogger)
      {
         this._preloader = new NullSoundPreloader();
         super();
         this._config = param1;
         if(param1)
         {
            param1.mixer.sfxEnabled = false;
            param1.mixer.musicEnabled = false;
         }
         param2.info("NullSoundDriver created");
      }
      
      public function normalizeEventId(param1:String) : String
      {
         return param1;
      }
      
      public function get system() : ISoundSystem
      {
         return this._config;
      }
      
      public function get enabled() : Boolean
      {
         return false;
      }
      
      public function setParameter() : void
      {
      }
      
      public function hasEventParameter(param1:String, param2:String) : Boolean
      {
         return false;
      }
      
      public function getGroup(param1:String) : void
      {
      }
      
      public function playEvent(param1:String) : ISoundEventId
      {
         return null;
      }
      
      public function stopEvent(param1:ISoundEventId, param2:Boolean) : Boolean
      {
         return false;
      }
      
      public function isLooping(param1:ISoundEventId) : Boolean
      {
         return false;
      }
      
      public function isPlaying(param1:ISoundEventId) : Boolean
      {
         return false;
      }
      
      public function dispose() : void
      {
      }
      
      public function preloadSoundDefData(param1:String, param2:Vector.<ISoundDef>) : ISoundDefBundle
      {
         return new NullSoundDefBundle();
      }
      
      public function get disposed() : Boolean
      {
         return false;
      }
      
      public function get preloader() : ISoundPreloader
      {
         return this._preloader;
      }
      
      public function init(param1:Boolean, param2:int) : Boolean
      {
         return true;
      }
      
      public function pause() : void
      {
      }
      
      public function unpause() : void
      {
      }
      
      public function reverbAmbientPreset(param1:String) : Boolean
      {
         return false;
      }
      
      public function setEventParameter(param1:String, param2:String, param3:Number) : Boolean
      {
         return false;
      }
      
      public function getEventParameter(param1:String, param2:String) : Number
      {
         return 0;
      }
      
      public function systemUpdate() : Boolean
      {
         return true;
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
         return null;
      }
      
      public function getParams(param1:String) : Dictionary
      {
         return null;
      }
      
      public function get reverb() : String
      {
         return null;
      }
      
      public function checkPlaying() : void
      {
      }
      
      public function getNumEventParameters(param1:ISoundEventId) : int
      {
         return 0;
      }
      
      public function getEventParameterName(param1:ISoundEventId, param2:int) : String
      {
         return null;
      }
      
      public function getEventParameterValue(param1:ISoundEventId, param2:int) : Number
      {
         return 0;
      }
      
      public function getEventParameterValueByName(param1:ISoundEventId, param2:String) : Number
      {
         return 0;
      }
      
      public function getEventParameterVelocity(param1:ISoundEventId, param2:int) : Number
      {
         return 0;
      }
      
      public function getEventParameterSeekSpeed(param1:ISoundEventId, param2:int) : Number
      {
         return 0;
      }
      
      public function setEventParameterValue(param1:ISoundEventId, param2:int, param3:Number) : Boolean
      {
         return false;
      }
      
      public function setEventParameterValueByName(param1:ISoundEventId, param2:String, param3:Number) : Boolean
      {
         return false;
      }
      
      public function getEventTimelinePosition(param1:ISoundEventId) : int
      {
         return 0;
      }
      
      public function set3dListenerPosition(param1:int, param2:Number, param3:Number, param4:Number) : Boolean
      {
         return false;
      }
      
      public function set3dNumListeners(param1:int) : Boolean
      {
         return false;
      }
      
      public function set3dEventPosition(param1:ISoundEventId, param2:Number, param3:Number, param4:Number) : Boolean
      {
         return false;
      }
      
      public function getNumEventCategories(param1:String) : int
      {
         return 0;
      }
      
      public function getEventCategoryName(param1:String, param2:int) : String
      {
         return null;
      }
      
      public function getEventCategoryMute(param1:String) : Boolean
      {
         return false;
      }
      
      public function getEventCategoryVolume(param1:String) : Number
      {
         return 0;
      }
      
      public function setEventCategoryVolume(param1:String, param2:Number) : Boolean
      {
         return false;
      }
      
      public function setEventCategoryMute(param1:String, param2:Boolean) : Boolean
      {
         return false;
      }
      
      public function getMusicCategoryMute() : Boolean
      {
         return false;
      }
      
      public function getMusicCategoryVolume() : Number
      {
         return 0;
      }
      
      public function setMusicCategoryVolume(param1:Number) : Boolean
      {
         return false;
      }
      
      public function setMusicCategoryMute(param1:Boolean) : Boolean
      {
         return false;
      }
      
      public function setEventVolume(param1:ISoundEventId, param2:Number) : Boolean
      {
         return false;
      }
      
      public function getEventVolume(param1:ISoundEventId) : Number
      {
         return 0;
      }
      
      public function setEventPitchSemitones(param1:ISoundEventId, param2:Number) : Boolean
      {
         return false;
      }
      
      public function get allSoundDefBundles() : Vector.<ISoundDefBundle>
      {
         return null;
      }
      
      public function getWaveBankInfo(param1:String) : Array
      {
         return [];
      }
      
      public function get fmodManfest() : FmodManifest
      {
         return null;
      }
      
      public function get debugSoundDriver() : Boolean
      {
         return false;
      }
      
      public function set debugSoundDriver(param1:Boolean) : void
      {
      }
      
      public function isFmodStudioVersion() : Boolean
      {
         return false;
      }
      
      public function createEventIdFromDesc(param1:String) : ISoundEventId
      {
         return null;
      }
      
      public function inferSkuFromEventPath(param1:String) : String
      {
         return null;
      }
   }
}

import engine.fmod.FmodProjectInfo;
import engine.sound.ISoundPreloader;

class NullSoundPreloader implements ISoundPreloader
{
    
   
   public function NullSoundPreloader()
   {
      super();
   }
   
   public function addSound(param1:String) : void
   {
   }
   
   public function addProjectInfo(param1:FmodProjectInfo) : void
   {
   }
   
   public function setPreloadUrl(param1:String) : void
   {
   }
   
   public function load(param1:Function) : void
   {
      param1(this);
   }
   
   public function get complete() : Boolean
   {
      return true;
   }
}
