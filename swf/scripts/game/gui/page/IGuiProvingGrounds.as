package game.gui.page
{
   import game.gui.IGuiContext;
   
   public interface IGuiProvingGrounds
   {
       
      
      function init(param1:IGuiContext, param2:GuiProvingGroundsConfig, param3:IGuiProvingGroundsListener, param4:IGuiPgAbilityPopup) : void;
      
      function showPromotionClassId(param1:String, param2:String) : void;
      
      function set autoName(param1:Boolean) : void;
      
      function cleanup() : void;
      
      function update(param1:int) : void;
      
      function back() : void;
      
      function get canReady() : Boolean;
      
      function doReadyButton() : void;
      
      function doRandomButton() : void;
   }
}
