package engine.gui
{
   import engine.sound.ISoundDriver;
   
   public interface IGuiSound
   {
       
      
      function playSound(param1:String) : void;
      
      function get soundDriver() : ISoundDriver;
   }
}
