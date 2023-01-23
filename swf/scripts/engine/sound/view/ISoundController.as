package engine.sound.view
{
   import engine.sound.ISoundDriver;
   import engine.sound.def.ISoundLibrary;
   
   public interface ISoundController
   {
       
      
      function getSound(param1:String, param2:Function, param3:Boolean = true) : ISound;
      
      function playSound(param1:String, param2:Function) : ISound;
      
      function get complete() : Boolean;
      
      function get soundDriver() : ISoundDriver;
      
      function get library() : ISoundLibrary;
   }
}
