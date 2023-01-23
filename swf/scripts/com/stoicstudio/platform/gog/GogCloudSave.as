package com.stoicstudio.platform.gog
{
   import air.gog.ane.GogAne;
   import engine.core.util.CloudSave;
   import engine.core.util.CloudSaveConfig;
   import engine.core.util.CloudSaveEvent;
   import engine.saga.save.SaveManager;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   
   public class GogCloudSave extends EventDispatcher implements CloudSave
   {
      
      private static const pullEvent:CloudSaveEvent = new CloudSaveEvent(CloudSaveEvent.EVENT_PULL_COMPLETE);
      
      private static const pushEvent:CloudSaveEvent = new CloudSaveEvent(CloudSaveEvent.EVENT_PUSH_COMPLETE);
       
      
      private var galaxy:GogAne = null;
      
      private var _pull_complete:Boolean;
      
      private var _push_complete:Boolean;
      
      private var _pull_error:Boolean;
      
      private var _push_error:Boolean;
      
      public function GogCloudSave(param1:GogAne)
      {
         super();
         this.galaxy = param1;
         this._pull_complete = false;
         this._push_complete = false;
         this._pull_error = false;
         this._push_error = false;
      }
      
      public function get enabled() : Boolean
      {
         return true;
      }
      
      public function get id() : String
      {
         return "gog";
      }
      
      public function get url() : String
      {
         this.galaxy.logger.i("GOG","no gog cloudsave url");
         return null;
      }
      
      public function get pull_complete() : Boolean
      {
         this.galaxy.logger.i("GOG","pull complete");
         return this._pull_complete;
      }
      
      public function get push_complete() : Boolean
      {
         this.galaxy.logger.i("GOG","push complete");
         return this._push_complete;
      }
      
      public function get pull_error() : Boolean
      {
         this.galaxy.logger.i("GOG","pulling error");
         return this._pull_error;
      }
      
      public function get push_error() : Boolean
      {
         this.galaxy.logger.i("GOG","pushing error");
         return this._push_error;
      }
      
      public function pullFolder(param1:RegExp) : void
      {
         var filter:RegExp = param1;
         this.galaxy.logger.i("GOG","Pulling folder: " + filter);
         this._pull_error = false;
         this._pull_complete = true;
         setTimeout(function():void
         {
            dispatchEvent(pullEvent);
         },1);
      }
      
      public function pushFolder() : void
      {
         this.galaxy.logger.i("GOG","pushing folder");
         this._push_error = false;
         this._push_complete = true;
         setTimeout(function():void
         {
            dispatchEvent(pushEvent);
         },1);
      }
      
      public function enumerateSavedGames(param1:RegExp, param2:Function) : void
      {
         var fileCount:int;
         var fileIdx:int = 0;
         var fileList:Vector.<String> = null;
         var self:CloudSave = null;
         var fileName:String = null;
         var m:Array = null;
         var filter:RegExp = param1;
         var callback:Function = param2;
         this.galaxy.logger.i("GOG","Enumerating saved games filter.source: " + filter.source);
         fileCount = this.galaxy.GalaxyAPI_GetFileCount();
         this.galaxy.logger.i("GOG","file count is " + fileCount);
         fileList = new Vector.<String>();
         fileIdx = 0;
         while(fileIdx < fileCount)
         {
            fileName = this.galaxy.GalaxyAPI_GetFileName(fileIdx);
            if(CloudSaveConfig.PURGE_REMOTE)
            {
               this.galaxy.logger.i("GOG","purging remote");
               fileList.push(fileName);
            }
            else
            {
               m = fileName.match(filter);
               if(Boolean(m) && Boolean(m.length))
               {
                  this.galaxy.logger.i("GOG","pushing file");
                  fileList.push(fileName);
               }
               else
               {
                  this.galaxy.logger.debug("CloudSaveTgp ignoring filtered file [" + fileName + "]");
                  this.galaxy.logger.i("GOG","CloudSaveTgp ignoring filtered file [" + fileName + "]");
               }
            }
            fileIdx++;
         }
         if(CloudSaveConfig.PURGE_REMOTE)
         {
            this.galaxy.logger.info("CloudSaveTgp: PURGING " + fileList.length + " REMOTES");
            for each(fileName in fileList)
            {
               this.galaxy.logger.i("GOG","purging remote: " + fileName);
               this.deleteSavedGame(fileName);
            }
         }
         self = this;
         setTimeout(function():void
         {
            galaxy.logger.i("GOG","file list length: " + fileList.length);
            callback(self,filter,fileList);
         },1);
      }
      
      public function saveGame(param1:String, param2:ByteArray, param3:ByteArray) : void
      {
         var _loc5_:Boolean = false;
         this.galaxy.logger.i("GOG","Saving path: " + param1);
         var _loc4_:Boolean = this.galaxy.GalaxyAPI_SaveGame(param1,param2);
         if(!_loc4_)
         {
            this.galaxy.logger.e("GOG","Unable to save game: " + param1);
         }
         if(Boolean(param3) && param3.length > 0)
         {
            _loc5_ = this.galaxy.GalaxyAPI_SaveGame(this.getScreenshotPath(param1),param3);
            if(!_loc5_)
            {
               this.galaxy.logger.e("GOG","Unable to save screenshot: " + this.getScreenshotPath(param1));
            }
         }
      }
      
      public function readSavedGame(param1:String, param2:Function) : void
      {
         var _loc4_:ByteArray = null;
         var _loc5_:Boolean = false;
         var _loc3_:int = this.galaxy.GalaxyAPI_GetFileSize(param1);
         if(_loc3_ > 0)
         {
            _loc4_ = new ByteArray();
            _loc5_ = this.galaxy.GalaxyAPI_FileRead(param1,_loc4_,_loc3_);
            if(_loc5_)
            {
               _loc4_.position = 0;
               param2(this,param1,_loc4_);
               return;
            }
         }
         this.galaxy.logger.info("GogCloudSave: Reading [" + param1 + "]: fileSize is 0...");
         param2(this,param1,null);
      }
      
      public function readScreenshot(param1:String, param2:Function) : void
      {
         this.galaxy.logger.i("GOG","Read Screenshot at: " + param1);
         param2(this,param1,null);
      }
      
      public function deleteSavedGame(param1:String) : void
      {
         this.galaxy.logger.i("GOG","Deleting saved game at: " + param1);
         this.galaxy.GalaxyAPI_DeleteSavedGame(param1);
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
   }
}
