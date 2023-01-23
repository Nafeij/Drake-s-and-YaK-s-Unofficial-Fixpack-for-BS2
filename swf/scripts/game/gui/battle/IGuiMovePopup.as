package game.gui.battle
{
   import flash.display.MovieClip;
   import game.gui.IGuiContext;
   
   public interface IGuiMovePopup
   {
       
      
      function init(param1:IGuiContext, param2:IGuiMovePopupListener) : void;
      
      function show(param1:int) : void;
      
      function hide() : void;
      
      function moveTo(param1:Number, param2:Number) : void;
      
      function get movieClip() : MovieClip;
      
      function handleConfirm() : Boolean;
      
      function cleanup() : void;
   }
}
