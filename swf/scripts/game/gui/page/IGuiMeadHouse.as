package game.gui.page
{
   import engine.entity.def.IPurchasableUnit;
   import game.gui.IGuiContext;
   
   public interface IGuiMeadHouse
   {
       
      
      function init(param1:IGuiContext, param2:GuiMeadHouseConfig, param3:Vector.<IPurchasableUnit>, param4:IGuiMeadHouseListener) : void;
   }
}
