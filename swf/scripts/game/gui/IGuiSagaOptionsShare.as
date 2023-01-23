package game.gui
{
   import engine.gui.GuiGpNav;
   
   public interface IGuiSagaOptionsShare
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaOptionsShareListener, param3:GuiGpNav) : void;
      
      function cleanup() : void;
   }
}
