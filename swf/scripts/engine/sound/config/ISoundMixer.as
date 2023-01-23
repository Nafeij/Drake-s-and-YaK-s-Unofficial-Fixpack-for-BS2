package engine.sound.config
{
   import flash.events.IEventDispatcher;
   
   public interface ISoundMixer extends IEventDispatcher
   {
       
      
      function set volumeMaster(param1:Number) : void;
      
      function get volumeMaster() : Number;
      
      function set volumeSfx(param1:Number) : void;
      
      function get volumeSfx() : Number;
      
      function set volumeMusic(param1:Number) : void;
      
      function get volumeMusic() : Number;
      
      function get volumeVideo() : Number;
      
      function set videoMixerMode(param1:Boolean) : void;
      
      function get videoMixerMode() : Boolean;
      
      function set muteMaster(param1:Boolean) : void;
      
      function get muteMaster() : Boolean;
      
      function set muteSfx(param1:Boolean) : void;
      
      function get muteSfx() : Boolean;
      
      function set muteMusic(param1:Boolean) : void;
      
      function get muteMusic() : Boolean;
      
      function get muteVideo() : Boolean;
      
      function setMute(param1:String, param2:Boolean) : void;
      
      function getMute(param1:String) : Boolean;
      
      function setVolume(param1:String, param2:Number) : void;
      
      function getVolume(param1:String) : Number;
      
      function set musicEnabled(param1:Boolean) : void;
      
      function get musicEnabled() : Boolean;
      
      function set sfxEnabled(param1:Boolean) : void;
      
      function get sfxEnabled() : Boolean;
      
      function get videoEnabled() : Boolean;
   }
}
