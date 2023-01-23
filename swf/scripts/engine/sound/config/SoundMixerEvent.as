package engine.sound.config
{
   import flash.events.Event;
   
   public class SoundMixerEvent extends Event
   {
      
      public static const SFX_ENABLED:String = "SoundSystemConfigEvent._sfxEnabled = value;";
      
      public static const MUSIC_ENABLED:String = "SoundSystemConfigEvent.MUSIC";
       
      
      public function SoundMixerEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}
