package engine.saga.save
{
   import com.adobe.crypto.MD5;
   import engine.core.logging.ILogger;
   import engine.core.render.Screenshot;
   import engine.core.util.AppInfo;
   import engine.core.util.MemoryReporter;
   import engine.core.util.StableJson;
   import engine.resource.BitmapResource;
   import engine.resource.ResourceGroup;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.Saga;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class SaveManager extends EventDispatcher
   {
      
      public static var SAVE_HASH_ENABLED:Boolean = true;
      
      public static var SAVE_SCREENSHOT_PREGENERATED:Boolean = true;
      
      public static var SAVE_SCREENSHOT_REQUIRED:Boolean = false;
      
      public static var SAVE_SCREENSHOT_PNG:Boolean = true;
      
      public static const SAVE_SCREENSHOT_BMPZIP_EXT:String = ".bmpzip";
      
      public static const SAVE_SCREENSHOT_PNG_EXT:String = ".png";
      
      public static var SAVE_DIR:String = null;
      
      public static var IMPORT_SAVE_DIR:String = null;
      
      protected static const MASTER_SAVE_ID:String = "master";
      
      protected static var MASTER_PROFILE_ID:int = -1;
      
      protected static var PREFS_PROFILE_ID:int = -1;
      
      public static const EVENT_SAVE_DELETED:String = "SaveManager.EVENT_SAVE_DELETED";
      
      public static const EVENT_INITIALIZED:String = "SaveManager.EVENT_INITIALIZED";
       
      
      protected var appInfo:AppInfo;
      
      private var saveResourceGroup:ResourceGroup;
      
      private var saveBitmapResourceToSave:Dictionary;
      
      public var initialized:Boolean = false;
      
      public function SaveManager(param1:AppInfo)
      {
         this.saveBitmapResourceToSave = new Dictionary();
         super();
         this.appInfo = param1;
         this.saveResourceGroup = new ResourceGroup(this,this.logger);
      }
      
      public static function fixupMigrateSaveId(param1:String) : String
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(!SaveManager.SAVE_SCREENSHOT_PREGENERATED)
         {
            return param1;
         }
         if(param1.charAt(param1.length - 1) == "_")
         {
            Saga.instance.logger.info("Found duplicate save [" + param1 + "]");
            _loc2_ = param1.split("_");
            if(param1.search("resume") != -1)
            {
               param1 = "resume";
            }
            else if(_loc2_.length > 2)
            {
               param1 = "";
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length - 2)
               {
                  if(_loc3_ != 0)
                  {
                     param1 += "_";
                  }
                  param1 += _loc2_[_loc3_];
                  _loc3_++;
               }
               Saga.instance.logger.info("Replacing with new id [" + param1 + "]");
            }
            else
            {
               Saga.instance.logger.info("Found a save id that we failed to convert [" + param1 + "]. It might show up incorrectly with an invalid picture.");
            }
         }
         if(param1 == "sav_chapter8")
         {
            return "sav_chapter_08";
         }
         if(param1 == "sav_chapter9")
         {
            return "sav_chapter_09";
         }
         return param1;
      }
      
      protected function get logger() : ILogger
      {
         return this.appInfo.logger;
      }
      
      public function writeSave(param1:SagaSave, param2:int, param3:Boolean) : void
      {
         var _loc4_:WriteSaveSpec = new WriteSaveSpec(param1,param2,param3);
         _loc4_.addEventListener(WriteSaveSpec.EVENT_ATTACH_SCREENSHOT,this.onScreenshotAttached);
         this.getScreenshotForSave(_loc4_);
      }
      
      private function getScreenshotForSave(param1:WriteSaveSpec) : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:String = null;
         var _loc4_:SagaSave = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:* = null;
         var _loc8_:BitmapResource = null;
         if(!SaveManager.SAVE_SCREENSHOT_PREGENERATED)
         {
            _loc2_ = Saga.instance.takeScreenshot(SaveManager.SAVE_SCREENSHOT_PNG);
            _loc3_ = this.getSaveScreenshotUrl(param1.sagaId,param1.saveId,param1.profileId);
            this.appInfo.saveFile(SaveManager.SAVE_DIR,_loc3_,_loc2_,false);
            param1.sagaSave.thumbnail = _loc3_;
            param1.attachScreenshot(_loc2_);
         }
         else if(SaveManager.SAVE_SCREENSHOT_REQUIRED)
         {
            _loc4_ = param1.sagaSave;
            _loc5_ = _loc4_.id;
            if(_loc4_.isSaveQuick)
            {
               _loc5_ = "quicksave";
            }
            if(!_loc4_.isSaveCheckpoint)
            {
               if(_loc4_.last_chapter_save_id)
               {
                  _loc5_ = _loc4_.last_chapter_save_id;
               }
            }
            _loc6_ = SaveManager.fixupMigrateSaveId(_loc5_);
            _loc7_ = _loc4_.saga_id + "/save/" + _loc6_ + ".png";
            _loc8_ = Saga.instance.resman.getResource(_loc7_,BitmapResource,this.saveResourceGroup) as BitmapResource;
            this._registerBitmapResourceToSave(_loc8_,param1);
            _loc8_.addResourceListener(this._saveScreenshotResourceHandler);
         }
         else
         {
            param1.attachScreenshot(null);
         }
      }
      
      private function onScreenshotAttached(param1:Event) : void
      {
         var saveSpec:WriteSaveSpec = null;
         var ss:SagaSave = null;
         var data:ByteArray = null;
         var url:String = null;
         var saga:Saga = null;
         var event:Event = param1;
         saveSpec = event.target as WriteSaveSpec;
         saveSpec.removeEventListener(WriteSaveSpec.EVENT_ATTACH_SCREENSHOT,this.onScreenshotAttached);
         ss = saveSpec.sagaSave;
         data = ss.serialize(saveSpec.isSurvival,this.logger);
         if(!data || data.length == 0)
         {
            this.logger.error("SaveManager.writeSave invalid save file serialized: " + ss);
            return;
         }
         if(ss.isSaveCheckpoint)
         {
            saga = Saga.instance;
            saga.sendCheckpointGa(ss.id);
            saga.lastCheckpointSaveId = ss.id;
            if(ss.isSaveChapter)
            {
               saga.lastChapterSaveId = ss.id;
            }
         }
         url = this.getSaveUrl(saveSpec.sagaId,saveSpec.saveId,saveSpec.profileId);
         this._writeSaveAsync(url,saveSpec.profileId,data,function(param1:Boolean):void
         {
            var _loc2_:int = 0;
            var _loc3_:int = 0;
            if(param1)
            {
               _loc2_ = getTimer();
               _loc3_ = _loc2_ - saveSpec.startTime;
               logger.i("SAVE","Saved game [" + saveSpec.saveId + "] in " + _loc3_ + " ms: " + ss);
               GameSaveSynchronizer.instance.saveGameAndPush(url,data,saveSpec.screenshotData);
            }
         });
      }
      
      private function _registerBitmapResourceToSave(param1:BitmapResource, param2:WriteSaveSpec) : void
      {
         var _loc3_:Vector.<WriteSaveSpec> = this.saveBitmapResourceToSave[param1];
         if(!_loc3_)
         {
            _loc3_ = new Vector.<WriteSaveSpec>();
            this.saveBitmapResourceToSave[param1] = _loc3_;
         }
         _loc3_.push(param2);
      }
      
      private function _saveScreenshotResourceHandler(param1:ResourceLoadedEvent) : void
      {
         var vv:Vector.<WriteSaveSpec>;
         var br:BitmapResource = null;
         var screenshotData:ByteArray = null;
         var saveSpec:WriteSaveSpec = null;
         var event:ResourceLoadedEvent = param1;
         event.resource.removeResourceListener(this._saveScreenshotResourceHandler);
         if(!this.saveBitmapResourceToSave)
         {
            return;
         }
         br = event.resource as BitmapResource;
         vv = this.saveBitmapResourceToSave[br];
         if(vv)
         {
            screenshotData = null;
            if(Boolean(br) && Boolean(br.bitmapData))
            {
               try
               {
                  screenshotData = Screenshot.zipScreenshot(br.bitmapData);
               }
               catch(err:Error)
               {
                  logger.e("SAVE","Error encoding screenshot: {0} ({1}): {2} [bmp size {3} x {4}]",err.name,err.errorID,err.message,br.bitmapData.width,br.bitmapData.height);
               }
            }
            for each(saveSpec in vv)
            {
               saveSpec.attachScreenshot(screenshotData);
            }
         }
         delete this.saveBitmapResourceToSave[br];
         this.saveResourceGroup.releaseResource(event.resource.url);
      }
      
      protected function _writeSaveAsync(param1:String, param2:int, param3:ByteArray, param4:Function = null) : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function getSavesInProfile(param1:String, param2:int, param3:Boolean = false) : Array
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function getMostRecentSaveInProfile(param1:String, param2:Boolean, param3:int, param4:Boolean) : SagaSave
      {
         var _loc7_:SagaSave = null;
         var _loc5_:Array = this.getSavesInProfile(param1,param3,param4);
         var _loc6_:SagaSave = null;
         for each(_loc7_ in _loc5_)
         {
            if(_loc7_)
            {
               if(!(_loc7_.isSaveResume && !param2))
               {
                  if(!_loc6_ || _loc7_.date.time > _loc6_.date.time)
                  {
                     _loc6_ = _loc7_;
                  }
               }
            }
         }
         MemoryReporter.notifyModified();
         return _loc6_;
      }
      
      public function getResumeSaves(param1:String, param2:Boolean) : Array
      {
         var _loc5_:SagaSave = null;
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < Saga.PROFILE_COUNT)
         {
            _loc5_ = this.getMostRecentSaveInProfile(param1,true,_loc4_,param2);
            _loc3_.push(_loc5_);
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function getSave(param1:String, param2:String, param3:int, param4:Boolean = false) : SagaSave
      {
         if(param3 < 0)
         {
            this.appInfo.logger.error("SaveManager.getSaveLoad invalid profileId for [" + param2 + "]");
            return null;
         }
         if(!this.initialized)
         {
            return null;
         }
         var _loc5_:String = this.getSaveUrl(param1,param2,param3);
         var _loc6_:ByteArray = this._getSaveData(_loc5_,param3);
         if(!_loc6_)
         {
            return null;
         }
         var _loc7_:SagaSave = SagaSave.deserialize(_loc6_,this.logger,param4,_loc5_);
         if(!_loc7_)
         {
            this.appInfo.logger.error("SaveManager.getSaveLoad failed to deserialize [" + _loc5_ + "]");
            return null;
         }
         if(_loc7_.version < SagaSave.VERSION)
         {
            this.appInfo.logger.info("SagaSave IGNORING old save [" + _loc7_.id + "]");
            return null;
         }
         return _loc7_;
      }
      
      protected function _getSaveData(param1:String, param2:int, param3:Boolean = true) : ByteArray
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function deleteSave(param1:String, param2:String, param3:int) : void
      {
         var url:String = null;
         var surl:String = null;
         var sagaId:String = param1;
         var id:String = param2;
         var profileId:int = param3;
         this.appInfo.logger.info("SaveManager.saveDelete " + profileId + " " + id);
         url = this.getSaveUrl(sagaId,id,profileId);
         surl = this.getSaveScreenshotUrl(sagaId,id,profileId);
         this._deleteSaveAsync(url,surl,profileId,function(param1:Boolean):void
         {
            if(param1)
            {
               dispatchEvent(new Event(EVENT_SAVE_DELETED));
               GameSaveSynchronizer.instance.deleteGameAndPush(url,surl);
            }
         });
      }
      
      public function deleteProfile(param1:String, param2:int) : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      protected function _deleteSaveAsync(param1:String, param2:String, param3:int, param4:Function = null) : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function getSaveUrl(param1:String, param2:String, param3:int) : String
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function getSaveScreenshotUrl(param1:String, param2:String, param3:int) : String
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function getMasterSave(param1:String, param2:String) : Object
      {
         var r:Object;
         var url:String = null;
         var s:String = null;
         var md5_actual:String = null;
         var ss:String = null;
         var md5_expected:String = null;
         var sagaId:String = param1;
         var reason:String = param2;
         url = this.getSaveUrl(sagaId,MASTER_SAVE_ID,MASTER_PROFILE_ID);
         var data:ByteArray = this._getSaveData(url,MASTER_PROFILE_ID,false);
         if(!data)
         {
            this.logger.info("SaveManager.getMasterSave unable to load [" + url + "] for " + reason);
            return null;
         }
         r = null;
         try
         {
            s = data.readUTFBytes(data.length);
            r = StableJson.parse(s);
         }
         catch(err:Error)
         {
            appInfo.logger.error("SaveManager.getMasterSave - failed to parse JSON file [" + url + "] for " + reason);
            return null;
         }
         if(SAVE_HASH_ENABLED)
         {
            md5_actual = String(r["_"]);
            delete r["_"];
            ss = StableJson.stringifyObject(r," ");
            md5_expected = MD5.hash(ss);
            if(Capabilities.isDebugger)
            {
               if(md5_actual == "locally" || md5_actual == "ignore")
               {
                  r["_"] = md5_actual;
                  md5_actual = md5_expected;
               }
            }
            if(md5_expected != md5_actual)
            {
               this.appInfo.logger.error("Master Save Corrupted [" + url + "]");
               return null;
            }
         }
         if(r)
         {
            r.build_last = this.appInfo.buildVersion;
         }
         return r;
      }
      
      public function putMasterSave(param1:String, param2:Object) : void
      {
         var data:ByteArray = null;
         var url:String = null;
         var oldmd5:String = null;
         var ss:String = null;
         var md5:String = null;
         var sagaId:String = param1;
         var o:Object = param2;
         if(SAVE_HASH_ENABLED)
         {
            oldmd5 = String(o["_"]);
            if(oldmd5 != "ignore")
            {
               delete o["_"];
               ss = StableJson.stringifyObject(o," ");
               md5 = MD5.hash(ss);
               o["_"] = md5;
            }
         }
         ss = StableJson.stringifyObject(o," ");
         data = new ByteArray();
         data.writeUTFBytes(ss);
         url = this.getSaveUrl(sagaId,MASTER_SAVE_ID,MASTER_PROFILE_ID);
         this._writeSaveAsync(url,MASTER_PROFILE_ID,data,function(param1:Boolean):void
         {
            if(param1)
            {
               GameSaveSynchronizer.instance.saveGameAndPush(url,data,null);
            }
         });
      }
      
      public function savePrefs(param1:String, param2:Object) : void
      {
         var _loc3_:String = StableJson.stringifyObject(param2," ");
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.writeUTFBytes(_loc3_);
         this._writeSaveAsync(param1,PREFS_PROFILE_ID,_loc4_);
      }
      
      public function loadPrefs(param1:String) : Object
      {
         var r:Object;
         var s:String = null;
         var url:String = param1;
         var data:ByteArray = this._getSaveData(url,PREFS_PROFILE_ID);
         if(!data)
         {
            this.logger.info("SaveManager.getPrefs unable to load [" + url + "]");
            return null;
         }
         r = null;
         try
         {
            s = data.readUTFBytes(data.length);
            r = StableJson.parse(s);
         }
         catch(err:Error)
         {
            appInfo.logger.error("SaveManager.getPrefs - failed to parse JSON file [" + url + "]");
            return null;
         }
         return r;
      }
      
      public function migrateSavesToProfile(param1:String) : void
      {
      }
      
      public function getAllLocalSaveBuffers(param1:String) : Dictionary
      {
         return null;
      }
      
      public function getSaveBitmapAsync(param1:String, param2:String, param3:int, param4:*, param5:Function) : void
      {
         var _loc6_:String = this.getSaveScreenshotUrl(param1,param2,param3);
         this.appInfo.loadFileAsync(SAVE_DIR,_loc6_,param4,param5);
      }
      
      public function resetForNewUser() : void
      {
         if(Saga.instance)
         {
            Saga.instance.resetMasterSave();
         }
      }
   }
}

import engine.saga.save.SagaSave;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import flash.utils.getTimer;

class WriteSaveSpec extends EventDispatcher
{
   
   public static var EVENT_ATTACH_SCREENSHOT:String = "WriteSaveSpec.EVENT_ATTACH_SCREENSHOT";
    
   
   public var sagaSave:SagaSave;
   
   public var profileId:int;
   
   public var isSurvival:Boolean;
   
   public var startTime:int;
   
   private var _screenshotData:ByteArray;
   
   public function WriteSaveSpec(param1:SagaSave, param2:int, param3:Boolean)
   {
      super();
      this.sagaSave = param1;
      this.profileId = param2;
      this.isSurvival = param3;
      this.startTime = getTimer();
   }
   
   public function get sagaId() : String
   {
      return this.sagaSave.saga_id;
   }
   
   public function get saveId() : String
   {
      return this.sagaSave.id;
   }
   
   public function get screenshotData() : ByteArray
   {
      return this._screenshotData;
   }
   
   public function attachScreenshot(param1:ByteArray) : void
   {
      this._screenshotData = param1;
      dispatchEvent(new Event(EVENT_ATTACH_SCREENSHOT));
   }
}
