package engine.sound
{
   import engine.fmod.FmodManifest;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.ISoundDef;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   public interface ISoundDriver extends IEventDispatcher
   {
       
      
      function get system() : ISoundSystem;
      
      function getGroup(param1:String) : void;
      
      function preloadSoundDefData(param1:String, param2:Vector.<ISoundDef>) : ISoundDefBundle;
      
      function playEvent(param1:String) : ISoundEventId;
      
      function normalizeEventId(param1:String) : String;
      
      function stopEvent(param1:ISoundEventId, param2:Boolean) : Boolean;
      
      function isLooping(param1:ISoundEventId) : Boolean;
      
      function isPlaying(param1:ISoundEventId) : Boolean;
      
      function dispose() : void;
      
      function get disposed() : Boolean;
      
      function get preloader() : ISoundPreloader;
      
      function init(param1:Boolean, param2:int) : Boolean;
      
      function pause() : void;
      
      function unpause() : void;
      
      function reverbAmbientPreset(param1:String) : Boolean;
      
      function setEventParameter(param1:String, param2:String, param3:Number) : Boolean;
      
      function getEventParameter(param1:String, param2:String) : Number;
      
      function hasEventParameter(param1:String, param2:String) : Boolean;
      
      function systemUpdate() : Boolean;
      
      function netEventSystem_Init(param1:int) : Boolean;
      
      function netEventSystem_Update() : Boolean;
      
      function netEventSystem_Shutdown() : Boolean;
      
      function get playing() : Dictionary;
      
      function getParams(param1:String) : Dictionary;
      
      function get reverb() : String;
      
      function checkPlaying() : void;
      
      function getNumEventParameters(param1:ISoundEventId) : int;
      
      function getEventParameterName(param1:ISoundEventId, param2:int) : String;
      
      function getEventParameterValue(param1:ISoundEventId, param2:int) : Number;
      
      function getEventParameterValueByName(param1:ISoundEventId, param2:String) : Number;
      
      function getEventParameterVelocity(param1:ISoundEventId, param2:int) : Number;
      
      function getEventParameterSeekSpeed(param1:ISoundEventId, param2:int) : Number;
      
      function getEventTimelinePosition(param1:ISoundEventId) : int;
      
      function setEventParameterValue(param1:ISoundEventId, param2:int, param3:Number) : Boolean;
      
      function setEventParameterValueByName(param1:ISoundEventId, param2:String, param3:Number) : Boolean;
      
      function setEventVolume(param1:ISoundEventId, param2:Number) : Boolean;
      
      function getEventVolume(param1:ISoundEventId) : Number;
      
      function setEventPitchSemitones(param1:ISoundEventId, param2:Number) : Boolean;
      
      function set3dListenerPosition(param1:int, param2:Number, param3:Number, param4:Number) : Boolean;
      
      function set3dNumListeners(param1:int) : Boolean;
      
      function set3dEventPosition(param1:ISoundEventId, param2:Number, param3:Number, param4:Number) : Boolean;
      
      function getNumEventCategories(param1:String) : int;
      
      function getEventCategoryName(param1:String, param2:int) : String;
      
      function getEventCategoryMute(param1:String) : Boolean;
      
      function getEventCategoryVolume(param1:String) : Number;
      
      function setEventCategoryVolume(param1:String, param2:Number) : Boolean;
      
      function setEventCategoryMute(param1:String, param2:Boolean) : Boolean;
      
      function getMusicCategoryMute() : Boolean;
      
      function getMusicCategoryVolume() : Number;
      
      function setMusicCategoryVolume(param1:Number) : Boolean;
      
      function setMusicCategoryMute(param1:Boolean) : Boolean;
      
      function get allSoundDefBundles() : Vector.<ISoundDefBundle>;
      
      function getWaveBankInfo(param1:String) : Array;
      
      function get fmodManfest() : FmodManifest;
      
      function get debugSoundDriver() : Boolean;
      
      function set debugSoundDriver(param1:Boolean) : void;
      
      function createEventIdFromDesc(param1:String) : ISoundEventId;
      
      function inferSkuFromEventPath(param1:String) : String;
   }
}
