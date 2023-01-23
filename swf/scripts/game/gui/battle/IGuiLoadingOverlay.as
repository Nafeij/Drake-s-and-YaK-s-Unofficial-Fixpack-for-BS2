package game.gui.battle
{
   import flash.display.DisplayObject;
   import game.gui.IGuiContext;
   import game.gui.page.BattleHudPage;
   
   public interface IGuiLoadingOverlay
   {
       
      
      function init(param1:IGuiContext, param2:BattleHudPage) : void;
      
      function cleanup() : void;
      
      function resizeHandler(param1:Number, param2:Number) : void;
      
      function update(param1:int) : void;
      
      function get displayObject() : DisplayObject;
      
      function set visible(param1:Boolean) : void;
   }
}
