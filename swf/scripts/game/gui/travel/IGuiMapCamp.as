package game.gui.travel
{
   import game.gui.IGuiContext;
   
   public interface IGuiMapCamp
   {
       
      
      function init(param1:IGuiContext, param2:IGuiMapCampListener) : void;
      
      function set guiMapCampEnabled(param1:Boolean) : void;
      
      function get guiMapCampEnabled() : Boolean;
      
      function get guiMapCampHoverExit() : Boolean;
      
      function cleanup() : void;
   }
}
