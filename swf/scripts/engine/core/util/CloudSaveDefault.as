package engine.core.util
{
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   
   public final class CloudSaveDefault extends EventDispatcher implements CloudSave
   {
      
      private static const pullEvent:CloudSaveEvent = new CloudSaveEvent(CloudSaveEvent.EVENT_PULL_COMPLETE);
      
      private static const pushEvent:CloudSaveEvent = new CloudSaveEvent(CloudSaveEvent.EVENT_PUSH_COMPLETE);
       
      
      private var _id:String;
      
      private var _url:String;
      
      public function CloudSaveDefault(param1:String, param2:String)
      {
         super();
         this._id = param1;
      }
      
      public function get enabled() : Boolean
      {
         return false;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function get pull_complete() : Boolean
      {
         return true;
      }
      
      public function get push_complete() : Boolean
      {
         return true;
      }
      
      public function get pull_error() : Boolean
      {
         return false;
      }
      
      public function get push_error() : Boolean
      {
         return false;
      }
      
      public function pullFolder(param1:RegExp) : void
      {
         var filter:RegExp = param1;
         setTimeout(function():void
         {
            dispatchEvent(pullEvent);
         },1);
      }
      
      public function pushFolder() : void
      {
         setTimeout(function():void
         {
            dispatchEvent(pushEvent);
         },1);
      }
      
      public function enumerateSavedGames(param1:RegExp, param2:Function) : void
      {
         var self:CloudSave = null;
         var filter:RegExp = param1;
         var callback:Function = param2;
         self = this;
         setTimeout(function():void
         {
            callback(self,filter,new Vector.<String>());
         },1);
      }
      
      public function saveGame(param1:String, param2:ByteArray, param3:ByteArray) : void
      {
      }
      
      public function readSavedGame(param1:String, param2:Function) : void
      {
         param2(this,param1,null);
      }
      
      public function readScreenshot(param1:String, param2:Function) : void
      {
         param2(this,param1,null);
      }
      
      public function deleteSavedGame(param1:String) : void
      {
      }
   }
}
