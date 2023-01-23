package engine.landscape
{
   import engine.core.cmd.IKeyBinder;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityListDef;
   import engine.math.Rng;
   import engine.resource.ResourceManager;
   import engine.saga.ISaga;
   import engine.saga.SpeakEvent;
   import engine.scene.view.ISpeechBubblePositioner;
   import engine.scene.view.SpeechBubble;
   
   public interface ILandscapeContext
   {
       
      
      function get resman() : ResourceManager;
      
      function get logger() : ILogger;
      
      function get locale() : Locale;
      
      function get keybinder() : IKeyBinder;
      
      function get saga() : ISaga;
      
      function get rng() : Rng;
      
      function get spawnables() : IEntityListDef;
      
      function createSpeechBubble(param1:SpeakEvent, param2:*, param3:ISpeechBubblePositioner) : SpeechBubble;
   }
}
