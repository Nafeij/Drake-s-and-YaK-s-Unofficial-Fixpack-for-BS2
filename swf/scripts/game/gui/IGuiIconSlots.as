package game.gui
{
   public interface IGuiIconSlots
   {
       
      
      function get numSlots() : int;
      
      function getIconSlot(param1:int) : IGuiIconSlot;
      
      function init(param1:IGuiContext) : void;
      
      function handleLocaleChange() : void;
      
      function get statsTooltips() : Boolean;
      
      function set statsTooltips(param1:Boolean) : void;
   }
}
