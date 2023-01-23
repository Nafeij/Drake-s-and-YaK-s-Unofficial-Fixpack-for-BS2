package lib.engine.sound.fmod
{
   import engine.sound.ISoundDriver;
   import flash.utils.ByteArray;
   
   public interface IFmodSoundDriver extends ISoundDriver
   {
       
      
      function loadBaseResource(param1:String, param2:ByteArray) : Boolean;
      
      function loadResource(param1:String, param2:ByteArray, param3:Boolean = false) : Boolean;
      
      function unloadResource(param1:String, param2:int) : Boolean;
      
      function getResourcePath(param1:String, param2:String) : String;
      
      function get isDebug() : Boolean;
   }
}
