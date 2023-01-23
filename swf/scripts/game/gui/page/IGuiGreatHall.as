package game.gui.page
{
   import game.gui.IGuiContext;
   
   public interface IGuiGreatHall
   {
       
      
      function init(param1:IGuiContext, param2:IGuiGreatHallListener) : void;
      
      function cleanup() : void;
   }
}
