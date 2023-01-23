package engine.sound
{
   import engine.core.logging.ILogger;
   import engine.sound.def.ISoundDef;
   
   public class NullSoundDefBundle implements ISoundDefBundle
   {
       
      
      public function NullSoundDefBundle()
      {
         super();
      }
      
      public function get id() : String
      {
         return null;
      }
      
      public function addListener(param1:ISoundDefBundleListener) : void
      {
         param1.soundDefBundleComplete(this);
      }
      
      public function removeListener(param1:ISoundDefBundleListener) : void
      {
      }
      
      public function get complete() : Boolean
      {
         return true;
      }
      
      public function get ok() : Boolean
      {
         return true;
      }
      
      public function get defs() : Vector.<ISoundDef>
      {
         return null;
      }
      
      public function get bankNames() : Vector.<String>
      {
         return null;
      }
      
      public function debugPrint(param1:ILogger) : void
      {
      }
      
      public function waitForSoundToFinish(param1:ISoundEventId) : void
      {
      }
      
      public function checkSoundsFinished() : Boolean
      {
         return true;
      }
   }
}
