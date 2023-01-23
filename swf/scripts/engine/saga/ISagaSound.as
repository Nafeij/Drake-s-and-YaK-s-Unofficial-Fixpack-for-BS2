package engine.saga
{
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.ISoundDef;
   import engine.sound.view.ISound;
   import engine.sound.view.SoundController;
   import flash.utils.Dictionary;
   
   public interface ISagaSound extends ISoundDefBundleListener
   {
       
      
      function checkMusicSituation() : void;
      
      function getSoundDef(param1:String, param2:String) : ISoundDef;
      
      function get system() : ISoundSystem;
      
      function outroMusic(param1:String, param2:String) : void;
      
      function setMusicParam(param1:String, param2:String, param3:String, param4:Number) : void;
      
      function setCurrentMusicById(param1:String) : void;
      
      function stopMusic(param1:String, param2:String) : void;
      
      function get currentMusicEvent() : String;
      
      function get currentMusicId() : String;
      
      function get currentMusicParams() : Dictionary;
      
      function prepareEventBundle(param1:String, param2:String) : ISoundDefBundle;
      
      function prepareDefBundle(param1:ISoundDef) : ISoundDefBundle;
      
      function playMusicOneShot(param1:String, param2:String, param3:String, param4:Number) : ISound;
      
      function playMusicIncidental(param1:String, param2:String, param3:String, param4:Number) : ISound;
      
      function playMusicStart(param1:String, param2:String, param3:String, param4:Number) : ISound;
      
      function checkReleaseCurrentMusicBundle() : void;
      
      function loadSagaSoundResources(param1:Function) : void;
      
      function stopAllSounds() : void;
      
      function get loaded() : Boolean;
      
      function pauseAllSounds() : void;
      
      function releaseCurrentMusicBundle(param1:String) : void;
      
      function unpauseAllSounds() : void;
      
      function get vo() : SoundController;
      
      function get music() : SoundController;
      
      function interruptMusicBattleTransition() : void;
   }
}
