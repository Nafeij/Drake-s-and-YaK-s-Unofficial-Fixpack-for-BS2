package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import engine.core.logging.ILogger;
   import engine.core.util.CloudSave;
   import engine.core.util.CloudSaveConfig;
   import engine.core.util.CloudSaveEvent;
   import engine.saga.save.SaveManager;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   public final class CloudSaveSteam extends EventDispatcher implements CloudSave
   {
      
      private static const pullEvent:CloudSaveEvent = new CloudSaveEvent(CloudSaveEvent.EVENT_PULL_COMPLETE);
      
      private static const pushEvent:CloudSaveEvent = new CloudSaveEvent(CloudSaveEvent.EVENT_PUSH_COMPLETE);
       
      
      private var logger:ILogger;
      
      private var _pull_complete:Boolean;
      
      private var _push_complete:Boolean;
      
      private var _pull_error:Boolean;
      
      private var _push_error:Boolean;
      
      private var steamworks:SteamworksAne;
      
      private var known_snapshots:Dictionary;
      
      public function CloudSaveSteam(param1:SteamworksAne, param2:ILogger)
      {
         this.known_snapshots = new Dictionary();
         super();
         this.logger = param2;
         this.steamworks = param1;
         this._pull_complete = false;
         this._push_complete = false;
         this._pull_error = false;
         this._push_error = false;
      }
      
      public function init() : Boolean
      {
         return true;
      }
      
      final public function get enabled() : Boolean
      {
         return true;
      }
      
      final public function get id() : String
      {
         return "Steam";
      }
      
      final public function get url() : String
      {
         return null;
      }
      
      final public function get pull_complete() : Boolean
      {
         return this._pull_complete;
      }
      
      final public function get push_complete() : Boolean
      {
         return this._push_complete;
      }
      
      final public function get pull_error() : Boolean
      {
         return this._pull_error;
      }
      
      final public function get push_error() : Boolean
      {
         return this._push_error;
      }
      
      final public function enumerateSavedGames(param1:RegExp, param2:Function) : void
      {
         var fileIdx:int = 0;
         var fileList:Vector.<String> = null;
         var self:CloudSave = null;
         var fileName:String = null;
         var m:Array = null;
         var filter:RegExp = param1;
         var callback:Function = param2;
         var fileCount:int = this.steamworks.SteamRemoteStorage_GetFileCount();
         fileList = new Vector.<String>();
         fileIdx = 0;
         while(fileIdx < fileCount)
         {
            fileName = this.steamworks.SteamRemoteStorage_GetFileName(fileIdx);
            if(CloudSaveConfig.PURGE_REMOTE)
            {
               fileList.push(fileName);
            }
            else
            {
               m = fileName.match(filter);
               if(Boolean(m) && Boolean(m.length))
               {
                  fileList.push(fileName);
               }
               else
               {
                  this.logger.debug("CloudSaveSteam ignoring filtered file [" + fileName + "]");
               }
            }
            fileIdx++;
         }
         if(CloudSaveConfig.PURGE_REMOTE)
         {
            this.logger.info("CloudSaveSteam: PURGING " + fileList.length + " REMOTES");
            for each(fileName in fileList)
            {
               this.logger.info("CloudSaveSteam: PURGING REMOTE " + fileName);
               this.deleteSavedGame(fileName);
            }
         }
         self = this;
         setTimeout(function():void
         {
            callback(self,filter,fileList);
         },1);
      }
      
      final private function getScreenshotPath(param1:String) : String
      {
         var _loc2_:String = param1;
         if(SaveManager.SAVE_SCREENSHOT_PNG)
         {
            _loc2_ = _loc2_.replace(".save.json",SaveManager.SAVE_SCREENSHOT_PNG_EXT);
         }
         else
         {
            _loc2_ = _loc2_.replace(".save.json",SaveManager.SAVE_SCREENSHOT_BMPZIP_EXT);
         }
         return _loc2_;
      }
      
      final public function saveGame(param1:String, param2:ByteArray, param3:ByteArray) : void
      {
         var _loc4_:Boolean = this.steamworks.SteamRemoteStorage_FileWrite(param1,param2);
         if(_loc4_)
         {
            if(Boolean(param3) && Boolean(param3.length))
            {
               this.steamworks.SteamRemoteStorage_FileWrite(this.getScreenshotPath(param1),param3);
            }
         }
      }
      
      final public function readSavedGame(param1:String, param2:Function) : void
      {
         var _loc4_:ByteArray = null;
         var _loc5_:Boolean = false;
         var _loc3_:int = this.steamworks.SteamRemoteStorage_GetFileSize(param1);
         if(_loc3_ > 0)
         {
            _loc4_ = new ByteArray();
            _loc5_ = this.steamworks.SteamRemoteStorage_FileRead(param1,_loc4_,_loc3_);
            if(_loc5_)
            {
               _loc4_.position = 0;
               param2(this,param1,_loc4_);
               return;
            }
         }
         this.logger.info("CloudSaveSteam: Reading [" + param1 + "]: fileSize is 0...");
         param2(this,param1,null);
      }
      
      final public function readScreenshot(param1:String, param2:Function) : void
      {
         var _loc5_:ByteArray = null;
         var _loc6_:Boolean = false;
         var _loc3_:String = this.getScreenshotPath(param1);
         var _loc4_:int = this.steamworks.SteamRemoteStorage_GetFileSize(_loc3_);
         if(_loc4_ > 0)
         {
            _loc5_ = new ByteArray();
            _loc6_ = this.steamworks.SteamRemoteStorage_FileRead(_loc3_,_loc5_,_loc4_);
            if(_loc6_)
            {
               _loc5_.position = 0;
               param2(this,param1,_loc5_);
               return;
            }
         }
         param2(this,param1,null);
      }
      
      final public function deleteSavedGame(param1:String) : void
      {
         this.steamworks.SteamRemoteStorage_FileDelete(param1);
      }
      
      final public function pullFolder(param1:RegExp) : void
      {
         var filter:RegExp = param1;
         this._pull_error = false;
         this._pull_complete = true;
         setTimeout(function():void
         {
            dispatchEvent(pullEvent);
         },1);
      }
      
      final public function pushFolder() : void
      {
         this._push_error = false;
         this._push_complete = true;
         setTimeout(function():void
         {
            dispatchEvent(pushEvent);
         },1);
      }
   }
}
