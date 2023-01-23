package game.gui.page
{
   import engine.saga.save.SagaSave;
   import flash.events.IEventDispatcher;
   
   public interface IGuiSaveLoadListener extends IEventDispatcher
   {
       
      
      function guiSaveLoadFromSave(param1:SagaSave) : void;
      
      function guiSaveLoadFromBookmark(param1:String) : void;
      
      function guiSaveLoadClose() : void;
      
      function guiSaveLoadDelete(param1:SagaSave, param2:String) : void;
   }
}
