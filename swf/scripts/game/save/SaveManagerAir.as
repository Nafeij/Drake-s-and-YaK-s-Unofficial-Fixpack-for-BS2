package game.save
{
   import engine.core.util.AppInfo;
   import engine.core.util.StringUtil;
   import engine.saga.Saga;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SaveManager;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class SaveManagerAir extends SaveManager
   {
       
      
      public function SaveManagerAir(param1:AppInfo)
      {
         super(param1);
         initialized = true;
      }
      
      override protected function _writeSaveAsync(param1:String, param2:int, param3:ByteArray, param4:Function = null) : void
      {
         var _loc5_:Boolean = appInfo.saveFile(SaveManager.SAVE_DIR,param1,param3,false);
         if(param4 != null)
         {
            param4(_loc5_);
         }
      }
      
      override public function getSavesInProfile(param1:String, param2:int, param3:Boolean = false) : Array
      {
         var _loc6_:String = null;
         var _loc7_:SagaSave = null;
         var _loc4_:Array = this.getSaveList(param1,param2);
         var _loc5_:Array = [];
         for each(_loc6_ in _loc4_)
         {
            _loc7_ = getSave(param1,_loc6_,param2,param3);
            if(_loc7_)
            {
               _loc5_.push(_loc7_);
            }
         }
         return _loc5_;
      }
      
      override protected function _getSaveData(param1:String, param2:int, param3:Boolean = true) : ByteArray
      {
         var _loc4_:ByteArray = appInfo.loadFile(SAVE_DIR,param1);
         if(!_loc4_)
         {
            if(param3)
            {
               logger.error("SaveManager.getSaveLoad failed to load root=[" + SAVE_DIR + "] url=[" + param1 + "]");
            }
            return null;
         }
         return _loc4_;
      }
      
      override public function deleteProfile(param1:String, param2:int) : void
      {
         var _loc4_:String = null;
         logger.info("SaveManager.saveProfileDelete Deleting entire profile " + param2);
         var _loc3_:Array = this.getSaveList(param1,param2);
         for each(_loc4_ in _loc3_)
         {
            deleteSave(param1,_loc4_,param2);
         }
      }
      
      override protected function _deleteSaveAsync(param1:String, param2:String, param3:int, param4:Function = null) : void
      {
         appInfo.deleteFile(SAVE_DIR,param1,true);
         appInfo.deleteFile(SAVE_DIR,param2,true);
         if(param4 != null)
         {
            param4(true);
         }
      }
      
      override public function getSaveUrl(param1:String, param2:String, param3:int) : String
      {
         if(param3 < 0)
         {
            return "save/" + param1 + "/" + param2 + ".save.json";
         }
         return "save/" + param1 + "/" + param3 + "/" + param2 + ".save.json";
      }
      
      override public function getSaveScreenshotUrl(param1:String, param2:String, param3:int) : String
      {
         return "save/" + param1 + "/" + param3 + "/" + param2 + (SAVE_SCREENSHOT_PNG ? SAVE_SCREENSHOT_PNG_EXT : SAVE_SCREENSHOT_BMPZIP_EXT);
      }
      
      override public function getAllLocalSaveBuffers(param1:String) : Dictionary
      {
         var _loc3_:String = null;
         var _loc2_:Dictionary = new Dictionary();
         this._fillAllLocalSaveBuffers(param1,_loc2_);
         for each(_loc3_ in appInfo.saveSkus)
         {
            this._fillAllLocalSaveBuffers(_loc3_,_loc2_);
         }
         return _loc2_;
      }
      
      private function _fillAllLocalSaveBuffers(param1:String, param2:Dictionary) : Dictionary
      {
         var _loc3_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:ByteArray = null;
         var _loc4_:int = 0;
         while(_loc4_ < Saga.PROFILE_COUNT)
         {
            _loc5_ = this.getSaveList(param1,_loc4_);
            for each(_loc6_ in _loc5_)
            {
               _loc3_ = this.getSaveUrl(param1,_loc6_,_loc4_);
               _loc7_ = this._getSaveData(_loc3_,_loc4_,true);
               if(_loc7_)
               {
                  param2[_loc3_] = _loc7_;
               }
            }
            _loc4_++;
         }
         _loc3_ = this.getSaveUrl(param1,MASTER_SAVE_ID,MASTER_PROFILE_ID);
         _loc7_ = this._getSaveData(_loc3_,MASTER_PROFILE_ID,false);
         if(_loc7_)
         {
            param2[_loc3_] = _loc7_;
         }
         return param2;
      }
      
      override public function migrateSavesToProfile(param1:String) : void
      {
         var _loc4_:String = null;
         logger.info("SaveManager.MigrateSavesToProfile " + param1);
         var _loc2_:SagaSave = getMostRecentSaveInProfile(param1,true,0,false);
         if(_loc2_)
         {
            logger.debug("migrateSavesToProfile, profile zero (0) already occupied by " + _loc2_ + ", skipping");
            return;
         }
         var _loc3_:Array = this.getSaveList(param1,-1);
         if(!_loc3_ || _loc3_.length == 0)
         {
            logger.debug("migrateSavesToProfile, no old saves, skipping");
            return;
         }
         appInfo.createDirectory(SaveManager.SAVE_DIR,"save/" + param1 + "/0");
         for each(_loc4_ in _loc3_)
         {
            this.migrateSaveToProfile(_loc4_,param1);
         }
      }
      
      private function migrateSaveToProfile(param1:String, param2:String) : void
      {
         if(param1 == "master")
         {
            return;
         }
         this.migrateFileToProfile(param1 + ".save.json",param2);
         this.migrateFileToProfile(param1 + ".png",param2);
      }
      
      private function migrateFileToProfile(param1:String, param2:String) : void
      {
         var _loc3_:* = "save/" + param2 + "/";
         var _loc4_:String = _loc3_ + param1;
         var _loc5_:String = _loc3_ + "0/" + param1;
         if(appInfo.moveFile(SaveManager.SAVE_DIR,_loc4_,_loc5_,true))
         {
            logger.info("Migrated save file [" + _loc4_ + "] to [" + _loc5_ + "]");
         }
         else
         {
            logger.error("Failed to migrate save file [" + _loc4_ + "] to [" + _loc5_ + "]");
         }
      }
      
      private function getSaveList(param1:String, param2:int) : Array
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc3_:String = "save/" + param1;
         if(param2 >= 0)
         {
            _loc3_ += "/" + param2;
         }
         var _loc4_:Array = appInfo.listDirectory(SAVE_DIR,_loc3_);
         var _loc5_:Array = [];
         for each(_loc6_ in _loc4_)
         {
            _loc7_ = StringUtil.stripSuffix(_loc6_,".save.json");
            if(_loc7_ != _loc6_)
            {
               _loc5_.push(_loc7_);
            }
         }
         return _loc5_;
      }
   }
}
