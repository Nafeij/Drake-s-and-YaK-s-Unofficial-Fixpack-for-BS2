package game.gui.page
{
   import engine.saga.save.SagaSave;
   import flash.display.BitmapData;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiSaveLoad extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSaveLoadListener) : void;
      
      function cleanup() : void;
      
      function setupSaves(param1:Boolean, param2:SagaSave, param3:Array, param4:BitmapData) : void;
      
      function clearSaves() : void;
      
      function get visible() : Boolean;
      
      function ensureTopGp() : void;
   }
}
