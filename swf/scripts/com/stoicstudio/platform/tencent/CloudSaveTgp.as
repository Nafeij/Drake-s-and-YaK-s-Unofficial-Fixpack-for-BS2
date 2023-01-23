package com.stoicstudio.platform.tencent
{
   import air.tencent.ane.TencentAne;
   import engine.core.logging.ILogger;
   import engine.core.util.CloudSave;
   import engine.core.util.CloudSaveConfig;
   import engine.core.util.CloudSaveEvent;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   
   public final class CloudSaveTgp extends EventDispatcher implements CloudSave
   {
      
      private static const pullEvent:CloudSaveEvent = new CloudSaveEvent(CloudSaveEvent.EVENT_PULL_COMPLETE);
      
      private static const pushEvent:CloudSaveEvent = new CloudSaveEvent(CloudSaveEvent.EVENT_PUSH_COMPLETE);
       
      
      private var tencent:TencentAne = null;
      
      private var logger:ILogger = null;
      
      private var _pull_complete:Boolean;
      
      private var _push_complete:Boolean;
      
      private var _pull_error:Boolean;
      
      private var _push_error:Boolean;
      
      public function CloudSaveTgp(param1:TencentAne, param2:ILogger)
      {
         super();
         this.tencent = param1;
         this.logger = param2;
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
         return "tgp";
      }
      
      public function get url() : String
      {
         this.logger.i("TENCENT","attempting to get the ulr");
         return null;
      }
      
      public function get pull_complete() : Boolean
      {
         this.logger.i("TENCENT","pull complete");
         return this._pull_complete;
      }
      
      public function get push_complete() : Boolean
      {
         this.logger.i("TENCENT","push complete");
         return this._push_complete;
      }
      
      public function get pull_error() : Boolean
      {
         this.logger.i("TENCENT","pulling error");
         return this._pull_error;
      }
      
      public function get push_error() : Boolean
      {
         this.logger.i("TENCENT","pushing error");
         return this._push_error;
      }
      
      public function pullFolder(param1:RegExp) : void
      {
         var filter:RegExp = param1;
         this.logger.i("TENCENT","Pulling folder: " + filter);
         this._pull_error = false;
         this._pull_complete = true;
         setTimeout(function():void
         {
            dispatchEvent(pullEvent);
         },1);
      }
      
      public function pushFolder() : void
      {
         this.logger.i("TENCENT","pushing folder");
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
         this.logger.i("TENCENT","Enumerating saved games filter.source: " + filter.source);
         fileCount = this.tencent.TencentAPI_GetFileCount();
         this.logger.i("TENCENT","file count is " + fileCount);
         fileList = new Vector.<String>();
         fileIdx = 0;
         while(fileIdx < fileCount)
         {
            fileName = this.tencent.TencentAPI_GetFileName(fileIdx);
            this.logger.i("TENCENT","iterating: " + fileName);
            if(CloudSaveConfig.PURGE_REMOTE)
            {
               this.logger.i("TENCENT","purging remote");
               fileList.push(fileName);
            }
            else
            {
               m = fileName.match(filter);
               if(Boolean(m) && Boolean(m.length))
               {
                  this.logger.i("TENCENT","pushing file");
                  fileList.push(fileName);
               }
               else
               {
                  this.logger.debug("CloudSaveTgp ignoring filtered file [" + fileName + "]");
                  this.logger.i("TENCENT","CloudSaveTgp ignoring filtered file [" + fileName + "]");
               }
            }
            fileIdx++;
         }
         if(CloudSaveConfig.PURGE_REMOTE)
         {
            this.logger.info("CloudSaveTgp: PURGING " + fileList.length + " REMOTES");
            for each(fileName in fileList)
            {
               this.logger.info("CloudSaveTgp: PURGING REMOTE " + fileName);
               this.logger.i("TENCENT","purging remote: " + fileName);
               this.deleteSavedGame(fileName);
            }
         }
         self = this;
         setTimeout(function():void
         {
            logger.i("TENCENT","file list length: " + fileList.length);
            callback(self,filter,fileList);
         },1);
      }
      
      public function saveGame(param1:String, param2:ByteArray, param3:ByteArray) : void
      {
         this.logger.i("TENCENT","Saving file at location: " + param1 + " byte array len: " + param2.length);
         var _loc4_:Boolean = this.tencent.TencentAPI_SaveGame(param1,param2);
         if(!_loc4_)
         {
            this.logger.e("TENCENT","Unable to save game: " + param1);
         }
      }
      
      public function readSavedGame(param1:String, param2:Function) : void
      {
         var _loc4_:ByteArray = null;
         var _loc5_:Boolean = false;
         this.logger.i("TENCENT","trying to read file: " + param1);
         var _loc3_:int = this.tencent.TencentAPI_GetFileSize(param1);
         this.logger.i("TENCENT","The returned file size is: " + _loc3_);
         if(_loc3_ > 0)
         {
            _loc4_ = new ByteArray();
            _loc5_ = this.tencent.TencentAPI_FileRead(param1,_loc4_,_loc3_);
            if(_loc5_)
            {
               _loc4_.position = 0;
               param2(this,param1,_loc4_);
               return;
            }
            this.logger.i("TENCENT","EVERYTHING IS NOT OK " + _loc4_.length);
         }
         this.logger.info("CloudSaveTgp: Reading [" + param1 + "]: fileSize is 0...");
         param2(this,param1,null);
      }
      
      public function readScreenshot(param1:String, param2:Function) : void
      {
         this.logger.i("TENCENT","Read Screenshot at: " + param1);
         param2(this,param1,null);
      }
      
      public function deleteSavedGame(param1:String) : void
      {
         this.logger.i("TENCENT","Deleting saved game at: " + param1);
         this.tencent.TencentAPI_FileDelete(param1);
      }
   }
}
