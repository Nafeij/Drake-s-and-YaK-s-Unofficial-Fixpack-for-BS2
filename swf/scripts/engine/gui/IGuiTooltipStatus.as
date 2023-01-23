package engine.gui
{
   public interface IGuiTooltipStatus
   {
       
      
      function init(param1:IEngineGuiContext) : void;
      
      function get maxLines() : int;
      
      function tooltipSetLeftText(param1:int, param2:String) : void;
      
      function tooltipSetRightText(param1:int, param2:String) : void;
      
      function tooltipSetTitle(param1:String) : void;
      
      function tooltipRender() : void;
   }
}
