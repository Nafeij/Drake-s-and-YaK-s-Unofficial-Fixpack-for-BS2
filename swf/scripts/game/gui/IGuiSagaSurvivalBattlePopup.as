package game.gui
{
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   
   public interface IGuiSagaSurvivalBattlePopup extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext, param2:String) : void;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
   }
}
