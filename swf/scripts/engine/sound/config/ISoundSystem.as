package engine.sound.config
{
   import engine.resource.IResourceManager;
   import engine.sound.ISoundDriver;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.ISoundLibrary;
   import engine.sound.view.ISound;
   import engine.sound.view.ISoundController;
   import flash.events.IEventDispatcher;
   
   public interface ISoundSystem extends IEventDispatcher
   {
       
      
      function get mixer() : ISoundMixer;
      
      function get resman() : IResourceManager;
      
      function get ready() : Boolean;
      
      function get controller() : ISoundController;
      
      function get driver() : ISoundDriver;
      
      function get enabled() : Boolean;
      
      function set music(param1:ISound) : void;
      
      function get music() : ISound;
      
      function get isMusicPlaying() : Boolean;
      
      function get ducking() : Boolean;
      
      function set ducking(param1:Boolean) : void;
      
      function set voDuckingMultiplier(param1:Number) : void;
      
      function set voDuckingSpeed(param1:Number) : void;
      
      function set popDuckingMultiplier(param1:Number) : void;
      
      function playMusicName(param1:String, param2:ISoundLibrary) : ISound;
      
      function playMusicDef(param1:ISoundDef) : ISound;
      
      function stopMusicName(param1:String, param2:ISoundLibrary) : void;
      
      function stopMusicDef(param1:ISoundDef) : void;
      
      function playMusicEvent(param1:String, param2:String, param3:Boolean = false) : ISound;
      
      function playVoDef(param1:ISoundDef) : ISound;
      
      function get vo() : ISound;
      
      function set vo(param1:ISound) : void;
      
      function updateSoundSystem(param1:int) : void;
      
      function pause() : void;
      
      function unpause() : void;
   }
}
