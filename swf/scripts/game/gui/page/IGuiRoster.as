package game.gui.page
{
   import flash.display.MovieClip;
   import game.gui.IGuiContext;
   
   public interface IGuiRoster
   {
       
      
      function init(param1:IGuiContext, param2:GuiRosterConfig, param3:MovieClip, param4:MovieClip, param5:Function) : void;
      
      function cleanup() : void;
   }
}
