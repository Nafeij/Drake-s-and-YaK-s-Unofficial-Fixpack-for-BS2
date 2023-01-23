package game.gui.page
{
   import engine.saga.save.SagaSaveCollection;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiSaveProfile extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSaveProfileListener) : void;
      
      function cleanup() : void;
      
      function setupProfiles(param1:Vector.<SagaSaveCollection>) : void;
      
      function showImportWaitDialog() : void;
      
      function hideImportWaitDialog() : void;
      
      function showImportFailedDialog(param1:String, param2:Function) : void;
      
      function get visible() : Boolean;
      
      function ensureTopGp() : void;
   }
}
