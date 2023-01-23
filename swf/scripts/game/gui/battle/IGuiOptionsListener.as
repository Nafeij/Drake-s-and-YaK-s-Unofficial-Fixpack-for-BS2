package game.gui.battle
{
   public interface IGuiOptionsListener
   {
       
      
      function guiOptionsSetMusic(param1:Boolean) : void;
      
      function guiOptionsSetSfx(param1:Boolean) : void;
      
      function guiOptionsSurrenderMatch() : void;
      
      function guiOptionsQuitGame() : void;
      
      function guiOptionsSetChat(param1:Boolean) : void;
      
      function guiOptionsToggleFullcreen() : void;
   }
}
