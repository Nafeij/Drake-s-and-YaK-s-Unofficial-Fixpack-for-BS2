package engine.sound
{
   import engine.core.logging.ILogger;
   import engine.sound.def.ISoundDef;
   
   public interface ISoundDefBundle
   {
       
      
      function get id() : String;
      
      function addListener(param1:ISoundDefBundleListener) : void;
      
      function removeListener(param1:ISoundDefBundleListener) : void;
      
      function get defs() : Vector.<ISoundDef>;
      
      function get bankNames() : Vector.<String>;
      
      function get complete() : Boolean;
      
      function get ok() : Boolean;
      
      function debugPrint(param1:ILogger) : void;
      
      function waitForSoundToFinish(param1:ISoundEventId) : void;
      
      function checkSoundsFinished() : Boolean;
   }
}
