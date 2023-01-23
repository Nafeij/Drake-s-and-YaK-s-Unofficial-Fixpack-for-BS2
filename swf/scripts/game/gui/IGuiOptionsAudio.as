package game.gui
{
   public interface IGuiOptionsAudio
   {
       
      
      function init(param1:IGuiContext, param2:IGuiOptionsAudioListener) : void;
      
      function cleanup() : void;
      
      function closeOptionsAudio() : Boolean;
      
      function showOptionsAudio() : void;
      
      function get visible() : Boolean;
      
      function ensureTopGp() : void;
   }
}
