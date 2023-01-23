package game.gui.page
{
   import flash.events.IEventDispatcher;
   
   public interface IGuiSaveProfileListener extends IEventDispatcher
   {
       
      
      function isImportOldSagaMode() : Boolean;
      
      function guiSaveProfileImportFile() : void;
      
      function guiSaveProfileSelect(param1:int, param2:int) : void;
      
      function guiSaveProfileClose() : void;
      
      function guiSaveProfileDelete(param1:int) : void;
   }
}
