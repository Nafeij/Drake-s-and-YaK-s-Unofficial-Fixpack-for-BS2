package game.gui
{
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   
   public interface IGuiSurvivalPitchPopup extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
      
      function get isAccepted() : Boolean;
      
      function get isRestore() : Boolean;
      
      function set priceString(param1:String) : void;
   }
}
