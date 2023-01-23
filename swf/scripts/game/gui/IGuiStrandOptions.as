package game.gui
{
   import flash.display.MovieClip;
   
   public interface IGuiStrandOptions
   {
       
      
      function init(param1:IGuiContext, param2:IGuiStrandOptionsListener) : void;
      
      function setSize(param1:Number, param2:Number) : void;
      
      function chatEnabled() : Boolean;
      
      function get movieClip() : MovieClip;
      
      function toggleOptions() : void;
   }
}
