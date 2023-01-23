package game.gui
{
   import engine.gui.IGuiGpNavButton;
   import engine.gui.IGuiTalkie;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   
   public interface IGuiIconSlot extends IEventDispatcher, IGuiGpNavButton, IGuiTalkie
   {
       
      
      function get icon() : GuiIcon;
      
      function set icon(param1:GuiIcon) : void;
      
      function get nameText() : String;
      
      function set nameText(param1:String) : void;
      
      function get rankText() : String;
      
      function set rankText(param1:String) : void;
      
      function get iconEnabled() : Boolean;
      
      function set iconEnabled(param1:Boolean) : void;
      
      function init(param1:IGuiContext) : void;
      
      function get dragEnabled() : Boolean;
      
      function set dragEnabled(param1:Boolean) : void;
      
      function get guiIconMouseEnabled() : Boolean;
      
      function set guiIconMouseEnabled(param1:Boolean) : void;
      
      function cleanup() : void;
      
      function handleLocaleChange() : void;
      
      function get dropglowVisible() : Boolean;
      
      function set dropglowVisible(param1:Boolean) : void;
      
      function createClone(param1:DisplayObjectContainer) : GuiIcon;
      
      function get movieClip() : MovieClip;
      
      function set showStatsTooltip(param1:Boolean) : void;
      
      function get showStatsTooltip() : Boolean;
   }
}
