package engine.core.util
{
   import flash.events.IEventDispatcher;
   import flash.utils.ByteArray;
   
   public interface CloudSave extends IEventDispatcher
   {
       
      
      function get enabled() : Boolean;
      
      function get id() : String;
      
      function get url() : String;
      
      function get pull_complete() : Boolean;
      
      function get push_complete() : Boolean;
      
      function get pull_error() : Boolean;
      
      function get push_error() : Boolean;
      
      function pullFolder(param1:RegExp) : void;
      
      function pushFolder() : void;
      
      function enumerateSavedGames(param1:RegExp, param2:Function) : void;
      
      function saveGame(param1:String, param2:ByteArray, param3:ByteArray) : void;
      
      function readSavedGame(param1:String, param2:Function) : void;
      
      function readScreenshot(param1:String, param2:Function) : void;
      
      function deleteSavedGame(param1:String) : void;
   }
}
