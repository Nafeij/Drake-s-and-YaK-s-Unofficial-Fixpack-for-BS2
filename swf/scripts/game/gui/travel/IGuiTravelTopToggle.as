package game.gui.travel
{
   import engine.saga.ISaga;
   import game.gui.IGuiContext;
   
   public interface IGuiTravelTopToggle
   {
       
      
      function init(param1:IGuiContext, param2:IGuiTravelTop, param3:ISaga) : void;
      
      function set guiEnabled(param1:Boolean) : void;
      
      function cleanup() : void;
      
      function resizeHandler() : void;
      
      function activateGp() : void;
      
      function deactivateGp() : void;
   }
}
