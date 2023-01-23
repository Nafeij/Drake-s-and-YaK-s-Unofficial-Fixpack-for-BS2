package game.gui.page
{
   import engine.gui.IGuiButton;
   import game.gui.IGuiContext;
   
   public interface IGuiCharacterStats
   {
       
      
      function init(param1:IGuiContext, param2:IGuiCharacterStatsListener, param3:IGuiPgAbilityPopup, param4:GuiCharacterStatsConfig, param5:IGuiButton, param6:Function) : void;
      
      function setAllStats() : void;
   }
}
