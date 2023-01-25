package engine.saga.save
{
   import com.adobe.crypto.MD5;
   import engine.achievement.AchievementDef;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.StableJson;
   import engine.def.BooleanVars;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ItemDef;
   import engine.landscape.travel.def.TravelLocator;
   import engine.math.RngSampler_SeedArray;
   import engine.saga.Caravan;
   import engine.saga.CaravanDef;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaSurvivalRecord;
   import engine.saga.SagaVar;
   import engine.saga.vars.VariableBag;
   import engine.saga.vars.VariableDef;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class SagaSave extends EventDispatcher
   {
      
      public static var EVENT_THUMBNAIL_BITMAP:String = "SagaSave.EVENT_THUMBNAIL_BITMAP";
      
      public static var VERSION:int = 2;
      
      public static var REDUCE_SAVE_SIZE:Boolean = false;
      
      public static var SAVE_PLATFORM_DATA:Boolean = true;
      
      public static var SURVIVAL_RECORD_ENABLED:Boolean;
      
      public static var DEBUG_HASHED_SAVES:Boolean;
       
      
      public var id:String;
      
      public var saga_id:String;
      
      public var date:Date;
      
      public var date_start:Date;
      
      public var thumbnail:String;
      
      private var _thumbnailBmp:Bitmap;
      
      public var caravans:Vector.<CaravanSave>;
      
      public var caravansByName:Dictionary;
      
      public var globalVars:Dictionary;
      
      public var caravanName:String;
      
      public var travelLocator:TravelLocator;
      
      public var sceneUrl:String;
      
      public var camped:Boolean;
      
      public var campSeed:int;
      
      public var campSceneStateStoreUrl:String;
      
      public var campSceneStateStoreTravelLocator:TravelLocator;
      
      public var day:int;
      
      public var rng:Object;
      
      public var version:int;
      
      public var build:String = "unknown";
      
      public var halted:Boolean;
      
      public var currentMusicId:String;
      
      public var currentMusicParams:Dictionary;
      
      public var cast_info:Dictionary;
      
      public var last_chapter_save_id:String;
      
      public var last_checkpoint_save_id:String;
      
      public var selectedVariable:String;
      
      public var marketItemDefIds:Vector.<String>;
      
      public var metrics:SagaMetricsSave;
      
      public var build_first:String = "unknown";
      
      public var battleMusicDefUrl:String;
      
      public var pageView:String;
      
      public var achievements:Array;
      
      public var startHappening:String;
      
      public var execHappening:String;
      
      public var imported:SagaSave;
      
      public var cheat:Boolean;
      
      public var survival_record:SagaSurvivalRecord;
      
      private var _hasOldTravelLocators:Boolean;
      
      public function SagaSave(param1:String)
      {
         this.caravans = new Vector.<CaravanSave>();
         this.caravansByName = new Dictionary();
         this.globalVars = new Dictionary();
         this.version = VERSION;
         this.marketItemDefIds = new Vector.<String>();
         this.achievements = [];
         super();
         this.id = param1;
      }
      
      public static function deserialize(param1:ByteArray, param2:ILogger, param3:Boolean, param4:String) : SagaSave
      {
         var str:String;
         var cheat:Boolean = false;
         var json:Object = null;
         var ss:SagaSave = null;
         var data:ByteArray = param1;
         var logger:ILogger = param2;
         var hashCheck:Boolean = param3;
         var url:String = param4;
         if(!data)
         {
            return null;
         }
         str = data.readUTFBytes(data.length);
         if(!str)
         {
            logger.error("SagaSave.deserialize Could not read UTF bytes from data length=" + data.length);
            return null;
         }
         try
         {
            json = StableJson.parse(str);
            if(json["cheat"])
            {
               logger.info("Save Cheat ENABLED [" + url + "]");
               cheat = true;
            }
            if(hashCheck && !checkTheHash(url,json,logger,cheat))
            {
               return null;
            }
            ss = new SagaSave(null).fromJson(json,logger);
            return ss;
         }
         catch(err:Error)
         {
            logger.error("SagaSave.deserialize Could not parse json: " + err.getStackTrace());
            return null;
         }
      }
      
      private static function checkTheHash(param1:String, param2:Object, param3:ILogger, param4:Boolean) : Boolean
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(SaveManager.SAVE_HASH_ENABLED)
         {
            if(Boolean(param2.travelLocator) && param2.travelLocator.travel_position != undefined)
            {
               param3.info("Save hash skip due to old travel locator " + param1);
               return true;
            }
            if(Boolean(param2.campSceneStateStoreTravelLocator) && param2.campSceneStateStoreTravelLocator.travel_position != undefined)
            {
               param3.info("Save hash skip due to old camp travel locator " + param1);
               return true;
            }
            _loc5_ = String(param2["_"]);
            if(!_loc5_)
            {
               param3.error("Save hash missing [" + param1 + "]");
               return false;
            }
            delete param2["_"];
            _loc6_ = StableJson.stringifyObject(param2,"  ");
            _loc7_ = MD5.hash(_loc6_);
            if(Capabilities.isDebugger)
            {
               if(_loc5_ == "locally" || _loc5_ == "ignore")
               {
                  param3.info("SAVE DEBUGGER HASH [" + param1 + "] [" + _loc7_ + "]");
                  _loc7_ = _loc5_;
               }
            }
            if(_loc5_ != _loc7_)
            {
               if(param4)
               {
                  param3.info("Save Cheat allowing tampered save file");
                  return true;
               }
               if(Capabilities.isDebugger)
               {
                  param3.error("Save Corrupted [" + param1 + "][" + _loc7_ + "]");
                  AppInfo.instance.saveFileString(AppInfo.DIR_APPLICATION_STORAGE,"corrupted/" + _loc7_ + ".json",_loc6_,true);
               }
               else
               {
                  param3.error("Save Corrupted [" + param1 + "]");
               }
               return false;
            }
         }
         return true;
      }
      
      override public function toString() : String
      {
         var _loc1_:int = !!this.globalVars ? int(this.globalVars[SagaVar.VAR_DAY]) : 0;
         return this.sceneUrl + "/" + this.travelLocator + "/day=" + _loc1_;
      }
      
      public function get dateTime() : Number
      {
         return !!this.date ? this.date.time : 0;
      }
      
      private function fromSagaMarket(param1:Saga) : void
      {
         var _loc3_:ItemDef = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.market.numItemDefs)
         {
            _loc3_ = param1.market.getItemDef(_loc2_);
            if(_loc3_)
            {
               this.marketItemDefIds.push(_loc3_.id);
            }
            _loc2_++;
         }
      }
      
      public function fromSaga(param1:Saga, param2:String) : SagaSave
      {
         var _loc3_:CaravanDef = null;
         var _loc4_:String = null;
         var _loc5_:Caravan = null;
         var _loc6_:CaravanSave = null;
         var _loc7_:AchievementDef = null;
         if(param2)
         {
            if(!param1.def.happenings.getHappeningDef(param2))
            {
               throw new ArgumentError("Cannot makesave for non-global happening");
            }
         }
         if(SURVIVAL_RECORD_ENABLED)
         {
            if(param1.survival)
            {
               this.survival_record = param1.survival.record;
            }
         }
         this.cheat = param1.isDevCheat;
         this.build = param1.appinfo.buildVersion;
         this.last_chapter_save_id = param1.lastChapterSaveId;
         this.last_checkpoint_save_id = param1.lastCheckpointSaveId;
         this.selectedVariable = param1.selectedVariable;
         if(this.isSaveCheckpoint)
         {
            this.last_checkpoint_save_id = this.id;
            if(this.isSaveChapter)
            {
               this.last_checkpoint_save_id = this.id;
            }
         }
         this.startHappening = param1.startHappening;
         this.build_first = param1.firstBuildVersion;
         for each(_loc3_ in param1.def.caravans)
         {
            _loc5_ = param1.caravans[_loc3_.name];
            if(_loc5_)
            {
               if(_loc5_.def.saves || _loc5_ == param1.caravan)
               {
                  _loc6_ = new CaravanSave().fromCaravan(_loc5_);
                  this.caravans.push(_loc6_);
                  this.caravansByName[_loc6_.name] = _loc6_;
               }
            }
         }
         for each(_loc4_ in SagaAchievements.unlocked)
         {
            _loc7_ = param1.def.achievements.fetch(_loc4_);
            if(Boolean(_loc7_) && !_loc7_.local)
            {
               this.achievements.push(_loc4_);
            }
         }
         this.pageView = param1.pageView;
         this.date = new Date();
         this.date_start = param1.date_start;
         this.saga_id = param1.def.id;
         this.globalVars = param1.global.toDictionary(param1.logger);
         if(this.globalVars)
         {
            this.day = this.globalVars[SagaVar.VAR_DAY];
         }
         this.fromSagaMarket(param1);
         this.caravanName = !!param1.caravan ? param1.caravan.def.name : null;
         this.camped = param1.camped;
         this.campSeed = param1.campSeed;
         this.cast_info = this.saveCastInfo(param1);
         this.campSceneStateStoreUrl = param1.campSceneStateUrl;
         this.campSceneStateStoreTravelLocator = param1.campSceneStateTravelLocator;
         if(this.campSceneStateStoreTravelLocator)
         {
            this.campSceneStateStoreTravelLocator = this.campSceneStateStoreTravelLocator.clone();
         }
         this._fromSaga_Music(param1);
         if(param1.sceneLoaded)
         {
            this.travelLocator = param1.travelLocator.clone();
            this.sceneUrl = param1.sceneUrl;
         }
         this.rng = (param1.rng.sampler as RngSampler_SeedArray).toJson();
         this.halted = param1.halted;
         this.metrics = new SagaMetricsSave();
         if(param1.metrics)
         {
            this.metrics.fromSagaMetrics(param1.metrics);
         }
         this.battleMusicDefUrl = param1.battleMusicDefUrl;
         if(param1.imported)
         {
            this.imported = param1.imported;
         }
         this.execHappening = param2;
         return this;
      }
      
      private function _fromSaga_Music(param1:Saga) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         this.currentMusicId = param1.sound.currentMusicId;
         var _loc2_:Dictionary = param1.sound.currentMusicParams;
         if(_loc2_)
         {
            for(_loc3_ in _loc2_)
            {
               if(!this.currentMusicParams)
               {
                  this.currentMusicParams = new Dictionary();
               }
               _loc4_ = Number(_loc2_[_loc3_]);
               this.currentMusicParams[_loc3_] = _loc4_;
            }
         }
      }
      
      public function applyCastInfo(param1:Saga, param2:Dictionary) : void
      {
         var _loc4_:String = null;
         var _loc5_:SagaSaveCastEntity = null;
         var _loc6_:IEntityDef = null;
         var _loc3_:ILogger = param1.logger;
         for(_loc4_ in this.cast_info)
         {
            _loc5_ = this.cast_info[_loc4_];
            if(!_loc5_)
            {
               param1.logger.error("SagaSave.applyCastInfo problem loading SagaSaveCastEntity [" + _loc4_ + "]");
            }
            else
            {
               _loc6_ = param1.def.cast.getEntityDefById(_loc4_);
               if(!_loc6_)
               {
                  param1.logger.info("SagaSave.applyCastInfo no such entity [" + _loc4_ + "], skipping...");
               }
               else
               {
                  _loc5_.applyCastInfo(_loc6_,param1,_loc3_,param2);
               }
            }
         }
      }
      
      private function saveCastInfo(param1:Saga) : Dictionary
      {
         var _loc4_:IEntityDef = null;
         var _loc5_:SagaSaveCastEntity = null;
         var _loc2_:Dictionary = new Dictionary();
         var _loc3_:int = 0;
         while(_loc3_ < param1.def.cast.numEntityDefs)
         {
            _loc4_ = param1.def.cast.getEntityDef(_loc3_);
            if(_loc4_.saves)
            {
               _loc5_ = new SagaSaveCastEntity().fromEntity(_loc4_,param1.logger);
               if(!_loc5_.isEmpty)
               {
                  _loc2_[_loc4_.id] = _loc5_;
               }
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function fromJsonCastInfo(param1:*) : Dictionary
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:SagaSaveCastEntity = null;
         var _loc2_:Dictionary = new Dictionary();
         if(param1 != undefined)
         {
            for(_loc3_ in param1)
            {
               _loc4_ = param1[_loc3_];
               _loc5_ = new SagaSaveCastEntity().fromJson(_loc4_);
               _loc5_.fromJson(_loc4_);
               if(!_loc5_.isEmpty)
               {
                  _loc2_[_loc3_] = _loc5_;
               }
            }
         }
         return _loc2_;
      }
      
      private function toJsonCastInfo() : Object
      {
         var _loc2_:String = null;
         var _loc3_:SagaSaveCastEntity = null;
         var _loc1_:Object = {};
         for(_loc2_ in this.cast_info)
         {
            _loc3_ = this.cast_info[_loc2_];
            if(!_loc3_.isEmpty)
            {
               _loc1_[_loc2_] = _loc3_.toJson();
            }
         }
         return _loc1_;
      }
      
      public function serialize(param1:Boolean, param2:ILogger) : ByteArray
      {
         var _loc7_:String = null;
         var _loc3_:Object = this.toJson();
         var _loc4_:String = REDUCE_SAVE_SIZE ? "" : "  ";
         var _loc5_:String = StableJson.stringifyObject(_loc3_,_loc4_);
         if(param1 && SaveManager.SAVE_HASH_ENABLED)
         {
            _loc7_ = MD5.hash(_loc5_);
            _loc3_["_"] = _loc7_;
            if(DEBUG_HASHED_SAVES)
            {
               AppInfo.instance.saveFileString(AppInfo.DIR_APPLICATION_STORAGE,"hashed/" + _loc7_ + ".json",_loc5_,true);
            }
            _loc5_ = StableJson.stringifyObject(_loc3_,"  ");
         }
         var _loc6_:ByteArray = new ByteArray();
         _loc6_.writeUTFBytes(_loc5_);
         return _loc6_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaSave
      {
         var _loc3_:Object = null;
         var _loc4_:CaravanSave = null;
         var _loc5_:String = null;
         var _loc6_:* = null;
         this.cheat = param1.cheat;
         this.version = param1.version;
         this.last_chapter_save_id = param1.last_chapter_save_id;
         this.last_checkpoint_save_id = param1.last_checkpoint_save_id;
         this.selectedVariable = param1.selectedVariable;
         if(param1.build != undefined)
         {
            this.build = param1.build;
         }
         this.startHappening = param1.startHappening;
         this.build_first = param1.build_first;
         this.id = param1.id;
         this.day = param1.day;
         this.saga_id = param1.saga_id;
         this.rng = param1.rng;
         this.halted = param1.halted;
         this.execHappening = param1.execHappening;
         this.battleMusicDefUrl = param1.battleMusicDefUrl;
         if(this.isSaveChapter)
         {
            this.last_chapter_save_id = this.id;
            this.last_checkpoint_save_id = this.id;
         }
         if(param1.achievements)
         {
            this.achievements = param1.achievements;
         }
         if(param1.caravans)
         {
            for each(_loc3_ in param1.caravans)
            {
               _loc4_ = new CaravanSave().fromJson(_loc3_,param2);
               this.caravans.push(_loc4_);
               this.caravansByName[_loc4_.name] = _loc4_;
            }
         }
         if(!SAVE_PLATFORM_DATA && Boolean(param1.globalVars))
         {
            delete param1.globalVars["dlc_survival"];
         }
         this.globalVars = VariableBag.fromJsonToDictionary(param1.globalVars);
         this.caravanName = param1.caravanName;
         this.cast_info = this.fromJsonCastInfo(param1.cast_info);
         if(param1.travelPosition != undefined)
         {
            this.travelLocator = new TravelLocator().setup(null,null,param1.travelPosition);
         }
         else if(param1.travelLocator)
         {
            this.travelLocator = new TravelLocator().fromJson(param1.travelLocator);
         }
         this.sceneUrl = param1.sceneUrl;
         this.camped = BooleanVars.parse(param1.camped,this.camped);
         this.campSeed = param1.campSeed;
         this.campSceneStateStoreUrl = param1.campSceneStateStoreUrl;
         this._fromJson_Music(param1);
         if(param1.campSceneStateStorePosition != undefined)
         {
            this.campSceneStateStoreTravelLocator = new TravelLocator().setup(null,null,param1.campSceneStateStorePosition);
         }
         else if(param1.campSceneStateStoreTravelLocator)
         {
            this.campSceneStateStoreTravelLocator = new TravelLocator().fromJson(param1.campSceneStateStoreTravelLocator);
         }
         this.date = new Date();
         this.date.setTime(param1.date);
         this.date_start = new Date();
         if(param1.date_start)
         {
            this.date_start.setTime(param1.date_start);
         }
         this.pageView = param1.pageView;
         if(param1.marketItemDefIds)
         {
            for each(_loc5_ in param1.marketItemDefIds)
            {
               this.marketItemDefIds.push(_loc5_);
            }
         }
         this.metrics = new SagaMetricsSave();
         if(param1.metrics != undefined)
         {
            this.metrics.fromJson(param1.metrics,param2);
         }
         if(!REDUCE_SAVE_SIZE)
         {
            if(param1.imported)
            {
               _loc6_ = (!!this.id ? this.id : "") + "_imported";
               this.imported = new SagaSave(_loc6_).fromJson(param1.imported,param2);
            }
            if(SURVIVAL_RECORD_ENABLED)
            {
               if(param1.survival_record)
               {
                  this.survival_record = new SagaSurvivalRecord().fromJson(param1.survival_record);
               }
            }
         }
         return this;
      }
      
      private function _fromJson_Music(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         this.currentMusicId = param1.currentMusicId;
         if(param1.currentMusicParams != undefined)
         {
            this.currentMusicParams = new Dictionary();
            for(_loc2_ in param1.currentMusicParams)
            {
               _loc3_ = Number(param1.currentMusicParams[_loc2_]);
               this.currentMusicParams[_loc2_] = _loc3_;
            }
         }
      }
      
      public function get isSaveChapter() : Boolean
      {
         return Boolean(this.id) && this.id.indexOf("sav_chapter") == 0;
      }
      
      public function get isSaveCheckpoint() : Boolean
      {
         return Boolean(this.id) && this.id.indexOf("sav_") == 0;
      }
      
      public function get isSaveQuick() : Boolean
      {
         return !this.isSaveResume && !this.isSaveCheckpoint;
      }
      
      public function get isSaveResume() : Boolean
      {
         return this.id == "resume";
      }
      
      public function toJson() : Object
      {
         var _loc2_:CaravanSave = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc1_:Object = {
            "version":this.version,
            "last_chapter_save_id":(!!this.last_chapter_save_id ? this.last_chapter_save_id : ""),
            "last_checkpoint_save_id":(!!this.last_checkpoint_save_id ? this.last_checkpoint_save_id : ""),
            "selectedVariable":(!!this.selectedVariable ? this.selectedVariable : ""),
            "caravans":[],
            "halted":this.halted,
            "saga_id":(!!this.saga_id ? this.saga_id : ""),
            "date":this.date.getTime(),
            "date_start":this.date_start.getTime(),
            "pageView":(!!this.pageView ? this.pageView : ""),
            "caravanName":(!!this.caravanName ? this.caravanName : ""),
            "sceneUrl":(!!this.sceneUrl ? this.sceneUrl : ""),
            "camped":this.camped,
            "campSeed":this.campSeed,
            "campSceneStateStoreUrl":(!!this.campSceneStateStoreUrl ? this.campSceneStateStoreUrl : ""),
            "currentMusicId":(!!this.currentMusicId ? this.currentMusicId : ""),
            "cast_info":this.toJsonCastInfo(),
            "id":(!!this.id ? this.id : ""),
            "day":this.day,
            "rng":this.rng,
            "thumbnail":(!!this.thumbnail ? this.thumbnail : ""),
            "build":(!!this.build ? this.build : ""),
            "build_first":(!!this.build_first ? this.build_first : ""),
            "startHappening":(!!this.startHappening ? this.startHappening : ""),
            "marketItemDefIds":[],
            "battleMusicDefUrl":this.battleMusicDefUrl
         };
         if(SURVIVAL_RECORD_ENABLED)
         {
            if(this.survival_record)
            {
               _loc1_.survival_record = this.survival_record.toJson();
            }
         }
         if(Boolean(this.currentMusicId) && Boolean(this.currentMusicParams))
         {
            _loc1_.currentMusicParams = {};
            for(_loc4_ in this.currentMusicParams)
            {
               _loc5_ = Number(this.currentMusicParams[_loc4_]);
               _loc1_.currentMusicParams[_loc4_] = _loc5_;
            }
         }
         if(this.execHappening)
         {
            _loc1_.execHappening = this.execHappening;
         }
         if(this.travelLocator)
         {
            _loc1_.travelLocator = this.travelLocator.toJson();
         }
         if(this.campSceneStateStoreTravelLocator)
         {
            _loc1_.campSceneStateStoreTravelLocator = this.campSceneStateStoreTravelLocator.toJson();
         }
         if(this.globalVars)
         {
            _loc1_.globalVars = VariableBag.toJsonFromDictionary(this.globalVars);
            if(!SAVE_PLATFORM_DATA)
            {
               delete _loc1_.globalVars["dlc_survival"];
            }
         }
         for each(_loc2_ in this.caravans)
         {
            _loc1_.caravans.push(_loc2_.toJson());
         }
         for each(_loc3_ in this.marketItemDefIds)
         {
            _loc1_.marketItemDefIds.push(_loc3_);
         }
         if(SAVE_PLATFORM_DATA)
         {
            _loc1_.achievements = this.achievements;
         }
         if(!REDUCE_SAVE_SIZE)
         {
            if(this.metrics)
            {
               _loc1_.metrics = this.metrics.toJson();
            }
            if(this.imported)
            {
               _loc1_.imported = this.imported.toJson();
            }
         }
         return _loc1_;
      }
      
      public function get thumbnailBmp() : Bitmap
      {
         return this._thumbnailBmp;
      }
      
      public function set thumbnailBmp(param1:Bitmap) : void
      {
         this._thumbnailBmp = param1;
         dispatchEvent(new Event(EVENT_THUMBNAIL_BITMAP));
      }
      
      public function stripForImport() : void
      {
         this.achievements = null;
         this.battleMusicDefUrl = null;
         this.rng = null;
         this.metrics = null;
         this.marketItemDefIds = null;
      }
      
      public function applyMusicToSaga(param1:Saga) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         param1.sound.setCurrentMusicById(this.currentMusicId);
         var _loc2_:String = param1.sound.currentMusicEvent;
         if(_loc2_)
         {
            if(Boolean(this.currentMusicId) && Boolean(this.currentMusicParams))
            {
               for(_loc3_ in this.currentMusicParams)
               {
                  _loc4_ = Number(this.currentMusicParams[_loc3_]);
                  param1.sound.setMusicParam(null,_loc2_,_loc3_,_loc4_);
               }
            }
         }
      }
      
      public function getVarBool(param1:Saga, param2:String) : Boolean
      {
         var _loc4_:VariableDef = null;
         var _loc5_:String = null;
         if(!this.globalVars)
         {
            return false;
         }
         var _loc3_:* = this.globalVars[param2];
         if(_loc3_ == undefined)
         {
            if(param1)
            {
               _loc4_ = param1.getVariableDefByName(param2);
               if(_loc4_)
               {
                  return _loc4_.start != 0;
               }
            }
            return false;
         }
         if(_loc3_ is String)
         {
            _loc5_ = _loc3_;
            return _loc5_ != "false";
         }
         return _loc3_;
      }
      
      public function setVar(param1:String, param2:*) : void
      {
         if(param2 == "false")
         {
            param2 = param2;
         }
         if(param2 == undefined)
         {
            if(this.globalVars)
            {
               delete this.globalVars[param1];
            }
         }
         else
         {
            if(!this.globalVars)
            {
               this.globalVars = new Dictionary();
            }
            this.globalVars[param1] = String(param2);
         }
      }
      
      public function getVarInt(param1:Saga, param2:String) : int
      {
         var _loc4_:VariableDef = null;
         var _loc3_:* = !!this.globalVars ? this.globalVars[param2] : undefined;
         if(_loc3_ != undefined)
         {
            return _loc3_;
         }
         if(param1)
         {
            _loc4_ = param1.getVariableDefByName(param2);
            if(_loc4_)
            {
               return _loc4_.start;
            }
         }
         return 0;
      }
      
      public function get survivalReloadCount() : int
      {
         return this.getVarInt(null,SagaVar.VAR_SURVIVAL_RELOAD_COUNT);
      }
      
      public function getSurvivalReloadLimit(param1:Saga) : int
      {
         return this.getVarInt(param1,SagaVar.VAR_SURVIVAL_RELOAD_LIMIT);
      }
      
      public function get survivalReloadRequired() : Boolean
      {
         return this.getVarBool(null,SagaVar.VAR_SURVIVAL_RELOAD_REQUIRED);
      }
      
      public function get survivalProgress() : int
      {
         return this.getVarInt(null,SagaVar.VAR_SURVIVAL_PROGRESS);
      }
      
      public function getDifficulty(param1:Saga) : int
      {
         return this.getVarInt(param1,SagaVar.VAR_DIFFICULTY);
      }
      
      public function get survivalElapsedSec() : int
      {
         return this.getVarInt(null,SagaVar.VAR_SURVIVAL_ELAPSED_SEC);
      }
   }
}
