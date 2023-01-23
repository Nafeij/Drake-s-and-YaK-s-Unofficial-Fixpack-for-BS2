package engine.gui
{
   import flash.display.MovieClip;
   
   public interface IGuiBattleTooltip
   {
       
      
      function init(param1:IEngineGuiContext) : void;
      
      function cleanup() : void;
      
      function setTooltipStrings(param1:Array) : void;
      
      function get movieClip() : MovieClip;
   }
}
