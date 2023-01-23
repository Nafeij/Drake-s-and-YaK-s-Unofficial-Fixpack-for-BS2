package game.gui.battle
{
   import game.gui.IGuiContext;
   
   public interface IGuiOptionsGp
   {
       
      
      function init(param1:IGuiContext, param2:IGuiOptionsGpListener) : void;
      
      function cleanup() : void;
      
      function closeOptionsGp() : Boolean;
   }
}
