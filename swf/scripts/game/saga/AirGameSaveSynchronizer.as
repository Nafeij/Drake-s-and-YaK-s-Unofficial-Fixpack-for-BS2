package game.saga
{
   import engine.core.util.CloudSave;
   import engine.core.util.CloudSaveSynchronizer;
   import engine.saga.Saga;
   import engine.saga.save.GameSaveSynchronizer;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import game.cfg.GameConfig;
   import game.gui.IGuiDialog;
   
   public class AirGameSaveSynchronizer extends GameSaveSynchronizer
   {
      
      private static const PULL_STATE_CANCEL_RESTART:int = -2;
      
      private static const PULL_STATE_CANCEL:int = -1;
      
      private static const PULL_STATE_NONE:int = 0;
      
      private static const PULL_STATE_START:int = 1;
      
      private static const PULL_STATE_PULL:int = 2;
      
      private static const PULL_STATE_ENUMERATE:int = 3;
      
      private static const PULL_STATE_COMPARISONS:int = 4;
      
      public static const DEFAULT_PULL_TIMEOUT:int = 15 * 1000;
      
      public static const PULL_TIMEOUT_EXTENSION:int = 10 * 1000;
       
      
      public var cloudSaves:CloudSaveSynchronizer;
      
      public var config:GameConfig;
      
      private var comparisons:Vector.<SaveComparison>;
      
      private var comparison_cursor:int;
      
      private var waits_enumerateFilePaths:int;
      
      private var local_saves:Dictionary;
      
      private var isInitialized:Boolean = false;
      
      private var pullState:int = 0;
      
      private var pullTimer:Timer;
      
      private var last_update:int;
      
      private var lastComparisonTimes:Dictionary;
      
      private var _statusMsg:String = "";
      
      private var pull_total_elapsed:int;
      
      private var pull_start_time:int;
      
      private var compare_start_time:int;
      
      public var pull_timeout:int;
      
      private var _skuFilter:RegExp = null;
      
      private var resolvingConflict:Boolean;
      
      private var dialog:IGuiDialog;
      
      public function AirGameSaveSynchronizer(param1:GameConfig, param2:CloudSaveSynchronizer)
      {
         this.lastComparisonTimes = new Dictionary();
         super(param1.logger);
         this.cloudSaves = param2;
         this.config = param1;
         if(!this.isInitialized)
         {
            param2.addEventListener(CloudSaveSynchronizer.EVENT_PULL_COMPLETE,this.cloudSavesPullCompleteHandler);
            param2.addEventListener(CloudSaveSynchronizer.EVENT_PUSH_COMPLETE,this.cloudSavesPushCompleteHandler);
            this.isInitialized = true;
         }
         else
         {
            logger.i("GameSaveSynchronizer","Re-initializing");
         }
      }
      
      public static function init(param1:GameConfig, param2:CloudSaveSynchronizer) : AirGameSaveSynchronizer
      {
         return new AirGameSaveSynchronizer(param1,param2);
      }
      
      public function get statusMsg() : String
      {
         return this._statusMsg;
      }
      
      override public function saveGame(param1:String, param2:ByteArray, param3:ByteArray) : void
      {
         if(GameSaveSynchronizer.PULL_ENABLED)
         {
            if(param2 == null)
            {
               logger.e("SAVE","Game data is null!");
            }
            this.cloudSaves.saveGame(param1,param2,param3);
         }
      }
      
      override public function deleteFile(param1:String) : void
      {
         this.cloudSaves.deleteGame(param1);
      }
      
      private function get skuFilter() : RegExp
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:* = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(this._skuFilter == null)
         {
            _loc1_ = this.config.skuSaga;
            _loc2_ = this.config.context.appInfo.saveSkus;
            _loc3_ = "(?:" + _loc1_ + "/.*\\.save\\.json";
            for each(_loc4_ in _loc2_)
            {
               _loc3_ = _loc3_ + "|" + _loc4_ + "/.*\\.save\\.json";
            }
            for each(_loc5_ in this.config.context.appInfo.finaleSaveSkus)
            {
               _loc3_ = _loc3_ + "|" + _loc5_ + "/.*/sav_finale\\.save\\.json";
            }
            _loc3_ += ")$";
            this._skuFilter = new RegExp("save/" + _loc3_,"i");
         }
         return this._skuFilter;
      }
      
      override public function pull() : void
      {
         if(this.pullState == PULL_STATE_NONE)
         {
            logger.i("SAVE","Request pull of remote folders.");
            this.pullState = PULL_STATE_START;
         }
         else if(this.pullState == PULL_STATE_CANCEL)
         {
            logger.i("SAVE","Pull requested while waiting for cancel - flag to restart when cancel completes.");
            this.pullState = PULL_STATE_CANCEL_RESTART;
         }
         else
         {
            logger.i("SAVE","Already pulling remote folders - waiting for original pull to complete.");
         }
         if(Boolean(this.pullTimer) && this.pullTimer.running)
         {
            logger.i("SAVE","Already running a pull - not starting a new timer.");
            return;
         }
         this.last_update = getTimer();
         this.pullTimer = new Timer(20,0);
         this.pullTimer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.pullTimer.start();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(this.pullState == PULL_STATE_NONE || this.pullState == PULL_STATE_CANCEL || this.pullState == PULL_STATE_CANCEL_RESTART)
         {
            this.pullTimer.stop();
            this.pullTimer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.pullTimer = null;
            return;
         }
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - this.last_update;
         this.last_update = _loc2_;
         this.update(_loc3_);
      }
      
      override public function update(param1:int) : void
      {
         var delta:int = param1;
         if(this.pullState == PULL_STATE_NONE || this.pullState == PULL_STATE_CANCEL || this.pullState == PULL_STATE_CANCEL_RESTART)
         {
            return;
         }
         if(this.pullState == PULL_STATE_START)
         {
            this.pull_timeout = DEFAULT_PULL_TIMEOUT;
            this.pull_start_time = getTimer();
            this.pullState = PULL_STATE_PULL;
            if(hasPulled && !GameSaveSynchronizer.MULTIPLE_PULL)
            {
               logger.i("SAVE","Have already pulled once - skipping repeat.");
               setTimeout(function():void
               {
                  if(pullState == PULL_STATE_PULL || pullState == PULL_STATE_CANCEL_RESTART)
                  {
                     pullState = PULL_STATE_NONE;
                     dispatchEvent(new Event(EVENT_PULL_COMPLETE));
                  }
               },1);
            }
            else if(GameSaveSynchronizer.PULL_ENABLED)
            {
               logger.d("SAVE","Starting pull of remote folders.");
               hasPulled = true;
               this.cloudSaves.pullFolders(this.skuFilter);
            }
            else
            {
               logger.i("SAVE","Pull disabled - not actually pulling any remote folders.");
               setTimeout(function():void
               {
                  if(pullState == PULL_STATE_PULL || pullState == PULL_STATE_CANCEL_RESTART)
                  {
                     pullState = PULL_STATE_NONE;
                     dispatchEvent(new Event(EVENT_PULL_COMPLETE));
                  }
               },1);
            }
         }
         this.processComparisons();
         if(this.pullState == PULL_STATE_PULL)
         {
            this.pull_total_elapsed += delta;
            if(this.pull_total_elapsed > this.pull_timeout)
            {
               logger.i("SAVE","Update CANCELING pull_total_elapsed={0}",this.pull_total_elapsed);
               this.cancelPull();
               return;
            }
         }
      }
      
      override public function cancelPull() : void
      {
         logger.i("SAVE","Cancel Pull");
         if(this.pullState == PULL_STATE_CANCEL || this.pullState == PULL_STATE_NONE)
         {
            return;
         }
         this.pullState = PULL_STATE_CANCEL;
         dispatchEvent(new Event(EVENT_PULL_COMPLETE));
      }
      
      private function cleanupAfterCancel() : void
      {
         var _loc1_:int = 0;
         var _loc2_:SaveComparison = null;
         if(this.comparisons)
         {
            _loc1_ = 0;
            while(_loc1_ < this.comparisons.length)
            {
               _loc2_ = this.comparisons[_loc1_];
               this._statusMsg = "canceling " + _loc2_.saveFilePath;
               _loc2_.cleanup();
               _loc1_++;
            }
         }
         this.resolvingConflict = false;
         if(this.dialog)
         {
            this.dialog.closeDialog(null);
         }
         this._statusMsg = "canceled";
         logger.i("SAVE","cancelPull finished");
         this.comparison_cursor = 0;
         this.comparisons = null;
      }
      
      private function finishCancel() : void
      {
         if(this.pullState == PULL_STATE_NONE)
         {
            return;
         }
         if(this.pullState == PULL_STATE_CANCEL)
         {
            this.cleanupAfterCancel();
            this.pullState = PULL_STATE_NONE;
         }
         else if(this.pullState == PULL_STATE_CANCEL_RESTART)
         {
            this.cleanupAfterCancel();
            this.pullState = PULL_STATE_NONE;
            this.pull();
         }
      }
      
      private function saveComparisonHandler(param1:SaveComparison) : void
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         logger.d("SAVE","GameSaveSynchronizer.saveComparisonHandler: comparing {0}",param1);
         if(this.pullState != PULL_STATE_COMPARISONS)
         {
            logger.i("SAVE","GameSaveSynchronizer.saveComparisonHandler: ignoring because pull is not active");
            this.finishCancel();
            return;
         }
         var _loc2_:int = this.pull_total_elapsed + PULL_TIMEOUT_EXTENSION;
         if(_loc2_ > this.pull_timeout)
         {
            _loc3_ = _loc2_ - this.pull_timeout;
            logger.i("SAVE","GameSaveSynchronizer.saveComparisonHandler: extending timeout by {0}",_loc3_);
            this.pull_timeout = _loc2_;
         }
         if(param1.conflict)
         {
            this.resolvingConflict = true;
            logger.i("SAVE","GameSaveSynchronizer.saveComparisonHandler: detected conflict with {0}",param1);
            this.dialog = this.config.gameGuiContext.createDialog();
            _loc4_ = this.config.gameGuiContext.translate("cloudsave_conflict_title");
            _loc5_ = param1.getUserMessage();
            _loc6_ = this.config.gameGuiContext.translate("cloudsave_conflict_overwrite");
            _loc7_ = this.config.gameGuiContext.translate("no");
            this.dialog.openTwoBtnDialog(_loc4_,_loc5_,_loc6_,_loc7_,this.conflictDialogCloseHandler);
            return;
         }
         if(param1.hasRemote && !param1.hasLocal)
         {
            ++this.comparison_cursor;
            logger.d("SAVE","GameSaveSynchronizer.saveComparisonHandler: missing local for {0}",param1);
            param1.copyRemoteToLocal(this.comparisonCopyCompleteHandler);
            this.lastComparisonTimes[param1.saveFilePath] = new Date();
         }
         else if(!param1.hasRemote && param1.hasLocal)
         {
            ++this.comparison_cursor;
            logger.d("SAVE","GameSaveSynchronizer.saveComparisonHandler: missing remote for {0}",param1);
            param1.copyLocalToRemote(this.comparisonCopyCompleteHandler);
            this.lastComparisonTimes[param1.saveFilePath] = new Date();
         }
         else
         {
            this.lastComparisonTimes[param1.saveFilePath] = new Date();
            this.comparisonResolutionCompleteHandler(param1);
         }
         dispatchEvent(new Event(EVENT_PULL_UPDATE));
      }
      
      private function comparisonResolutionCompleteHandler(param1:SaveComparison) : void
      {
         if(this.pullState != PULL_STATE_COMPARISONS)
         {
            this.finishCancel();
            return;
         }
         ++this.comparison_cursor;
         param1.cleanup();
         dispatchEvent(new Event(EVENT_PULL_UPDATE));
         logger.d("SAVE","GameSaveSynchronizer: Completed comparison resolution.");
      }
      
      private function comparisonCopyCompleteHandler(param1:SaveComparison) : void
      {
         param1.cleanup();
      }
      
      private function createComparisonForPath(param1:CloudSave, param2:String, param3:Boolean) : void
      {
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc4_:Array = param2.split("/");
         if(_loc4_.length >= 3)
         {
            _loc7_ = String(_loc4_[2]);
            _loc8_ = int(_loc7_);
            if(_loc8_ >= Saga.PROFILE_COUNT)
            {
               logger.i("SAVE","GameSaveSynchronizer found an invalid profile index for remote [{0}]",param2);
               this.deleteFile(param2);
               return;
            }
         }
         var _loc5_:ByteArray = this.local_saves[param2];
         delete this.local_saves[param2];
         if(logger.isDebugEnabled)
         {
            logger.i("SAVE","Creating comparison for {0}",param2);
         }
         var _loc6_:SaveComparison = new SaveComparison(param1,param2,_loc5_,this.config,param3);
         this.comparisons.push(_loc6_);
      }
      
      private function cloudSaveEnumerateFilePathsHandler(param1:CloudSave, param2:RegExp, param3:Vector.<String>) : void
      {
         var _loc4_:String = null;
         var _loc6_:ByteArray = null;
         if(this.pullState != PULL_STATE_ENUMERATE)
         {
            this.finishCancel();
            return;
         }
         this.pullState = PULL_STATE_COMPARISONS;
         if(param3 != null)
         {
            logger.i("SAVE","Enumerated {0} paths in remote folder {1}.",param3.length,param1.id);
            for each(_loc4_ in param3)
            {
               logger.d("SAVE","Creating comparison for enumerated remote path {0}",_loc4_);
               this.createComparisonForPath(param1,_loc4_,false);
            }
         }
         else
         {
            logger.d("SAVE","Enumeration failed to enumerate remote folder {0} - using local data",param1.id);
         }
         var _loc5_:Vector.<String> = new Vector.<String>();
         for(_loc4_ in this.local_saves)
         {
            _loc6_ = this.local_saves[_loc4_];
            if(_loc6_)
            {
               logger.d("SAVE","Creating comparison based on local file {0}",_loc4_);
               _loc5_.push(_loc4_);
            }
         }
         for each(_loc4_ in _loc5_)
         {
            this.createComparisonForPath(param1,_loc4_,true);
         }
         --this.waits_enumerateFilePaths;
         this.checkComparisonsReady();
      }
      
      private function handleSynchronization() : void
      {
         var _loc1_:SaveComparison = null;
         var _loc2_:CloudSave = null;
         this.comparisons = new Vector.<SaveComparison>();
         this.comparison_cursor = 0;
         this.waits_enumerateFilePaths = this.cloudSaves.folders.length;
         this._statusMsg = "enumerating " + this.waits_enumerateFilePaths + " file paths";
         if(!this.waits_enumerateFilePaths)
         {
            logger.info("GameSaveSynchronizer: No paths to enumerate.");
            setTimeout(this.checkComparisonsReady,1);
            return;
         }
         for each(_loc2_ in this.cloudSaves.folders)
         {
            if(_loc2_.enabled)
            {
               logger.d("SAVE","GameSaveSynchronizer.handleSynchronization enumerating file paths in {0} using filter {1}",_loc2_.id,this.skuFilter);
               _loc2_.enumerateSavedGames(this.skuFilter,this.cloudSaveEnumerateFilePathsHandler);
            }
            else
            {
               logger.d("SAVE","GameSaveSynchronizer.handleSynchronization skipping files paths in disabled folder {0}",_loc2_.id);
               --this.waits_enumerateFilePaths;
            }
         }
         if(this.waits_enumerateFilePaths == 0)
         {
            logger.i("SAVE","GameSaveSynchronizer: After checking cloud save, no file paths.");
            setTimeout(this.checkComparisonsReady,1);
         }
      }
      
      private function checkComparisonsReady() : void
      {
         if(this.waits_enumerateFilePaths == 0)
         {
            logger.d("SAVE","GameSaveSynchronizer: enumeration complete - performing comparisons");
            this.pullState = PULL_STATE_COMPARISONS;
            this.processComparisons();
         }
         else
         {
            this._statusMsg = "enumerating " + this.waits_enumerateFilePaths + " file paths";
         }
      }
      
      private function processComparisons() : void
      {
         var _loc2_:SaveComparison = null;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(this.resolvingConflict)
         {
            return;
         }
         if(this.pullState != PULL_STATE_COMPARISONS)
         {
            this.finishCancel();
            return;
         }
         if(!this.compare_start_time)
         {
            this.compare_start_time = getTimer();
         }
         var _loc1_:Date = new Date();
         if(this.comparisons)
         {
            while(this.comparisons != null && this.comparison_cursor < this.comparisons.length)
            {
               this._statusMsg = "processing " + this.comparisons[this.comparison_cursor].saveFilePath;
               _loc2_ = this.comparisons[this.comparison_cursor];
               _loc3_ = !!this.lastComparisonTimes[_loc2_.saveFilePath] ? _loc1_.valueOf() - (this.lastComparisonTimes[_loc2_.saveFilePath] as Date).valueOf() : 999999;
               if(_loc3_ >= 30000)
               {
                  logger.d("SAVE","Process comparison for {0}",_loc2_.saveFilePath);
                  _loc4_ = this.comparison_cursor;
                  _loc2_.process(this.saveComparisonHandler);
                  if(_loc4_ == this.comparison_cursor)
                  {
                     return;
                  }
               }
               else
               {
                  dispatchEvent(new Event(EVENT_PULL_UPDATE));
                  logger.d("SAVE","Compared {0} recently - skipping",_loc2_.saveFilePath);
                  ++this.comparison_cursor;
               }
            }
            this._statusMsg = "finished";
            logger.i("SAVE","Done with save conflict resolution in {0} ms",this.pull_total_elapsed);
            this.comparisons = null;
            this.pullState = PULL_STATE_NONE;
            pull_complete = true;
            if(logger.isDebugEnabled)
            {
               _loc5_ = getTimer() - this.compare_start_time;
               _loc6_ = getTimer() - this.pull_start_time;
               logger.d("SAVE","Pull complete.  Comparisions completed in {0} ms, total duration {1} ms",_loc5_,_loc6_);
            }
            dispatchEvent(new Event(EVENT_PULL_COMPLETE));
         }
         else
         {
            logger.i("SAVE","GameSaveSynchronizer: comparisons is null");
         }
      }
      
      private function conflictDialogCloseHandler(param1:String) : void
      {
         if(this.pullState != PULL_STATE_COMPARISONS)
         {
            this.finishCancel();
            return;
         }
         this.dialog = null;
         this.resolvingConflict = false;
         var _loc2_:String = this.config.gameGuiContext.translate("cloudsave_conflict_overwrite");
         var _loc3_:String = this.config.gameGuiContext.translate("no");
         var _loc4_:SaveComparison = this.comparisons[this.comparison_cursor];
         ++this.comparison_cursor;
         if(param1 == _loc2_)
         {
            _loc4_.copyRemoteToLocal(this.comparisonCopyCompleteHandler);
         }
         else if(param1 == _loc3_)
         {
            _loc4_.copyLocalToRemote(this.comparisonCopyCompleteHandler);
         }
         logger.d("SAVE","Conflict dialog closed.");
         this.processComparisons();
      }
      
      private function cloudSavesPullCompleteHandler(param1:Event) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Object = null;
         if(this.pullState != PULL_STATE_PULL)
         {
            this.finishCancel();
            return;
         }
         this.pullState = PULL_STATE_ENUMERATE;
         logger.i("SAVE","GameSaveSynchronizer completed pull of cloud saves");
         var _loc2_:String = this.config.skuSaga;
         this.local_saves = this.config.saveManager.getAllLocalSaveBuffers(_loc2_);
         for(_loc4_ in this.local_saves)
         {
            if(logger.isDebugEnabled)
            {
               logger.debug("GameSaveSynchronizer: found local save " + _loc4_);
            }
            _loc3_ = true;
         }
         if(!_loc3_)
         {
            this.pull_timeout *= 3;
            logger.i("SAVE","GameSaveSynchronizer has no local saves, increased pull_timeout to {0}",this.pull_timeout);
         }
         this.handleSynchronization();
      }
      
      private function cloudSavesPushCompleteHandler(param1:Event) : void
      {
      }
   }
}

import com.adobe.crypto.MD5;
import engine.core.locale.LocaleCategory;
import engine.core.logging.ILogger;
import engine.core.util.CloudSave;
import engine.core.util.StringUtil;
import engine.saga.save.SagaSave;
import engine.saga.save.SaveManager;
import flash.utils.ByteArray;
import game.cfg.GameConfig;
import game.gui.IGuiContext;

class SaveComparison
{
    
   
   public var cloudSave:CloudSave;
   
   public var saveFilePath:String;
   
   public var remoteSave:SagaSave;
   
   public var remoteData:ByteArray;
   
   public var localSave:SagaSave;
   
   public var localData:ByteArray;
   
   public var remoteMaster:Object;
   
   public var localMaster:Object;
   
   public var sameCampaign:Boolean;
   
   private var profile_index:int;
   
   public var conflict:Boolean;
   
   public var config:GameConfig;
   
   private var callback:Function;
   
   public var hasRemote:Boolean;
   
   public var hasLocal:Boolean;
   
   private var cleanedup:Boolean;
   
   private var skipRemote:Boolean;
   
   private var logger:ILogger;
   
   private var isWaitingOnRemote:Boolean;
   
   public function SaveComparison(param1:CloudSave, param2:String, param3:ByteArray, param4:GameConfig, param5:Boolean)
   {
      super();
      this.skipRemote = param5;
      this.cloudSave = param1;
      this.saveFilePath = param2;
      this.localData = param3;
      this.config = param4;
      this.logger = param4.logger;
      this.isWaitingOnRemote = false;
      var _loc6_:Array = param2.split("/");
      if(_loc6_.length > 2)
      {
         this.profile_index = _loc6_[2];
      }
   }
   
   public static function createSaveDisplay(param1:SagaSave, param2:IGuiContext) : String
   {
      var _loc4_:String = null;
      if(!param1 || !param2)
      {
         return "NONE";
      }
      var _loc3_:int = param1.day;
      var _loc5_:Number = Number(param1.id);
      if(_loc5_.toString() != param1.id)
      {
         _loc4_ = String(param2.translateCategory(param1.id,LocaleCategory.LOCATION));
      }
      else
      {
         _loc4_ = param1.id;
      }
      var _loc6_:String = _loc4_;
      var _loc7_:String = String(param2.translate("day"));
      var _loc8_:* = ", <font size=\'-5\'>" + _loc7_ + " " + _loc3_ + "</font>";
      var _loc9_:Date = param1.date;
      var _loc10_:* = ", <font size=\'-10\'>" + StringUtil.dateStringSansTZ(_loc9_) + "</font>";
      return _loc6_ + _loc8_ + _loc10_;
   }
   
   public static function createMasterDisplay(param1:Object, param2:IGuiContext) : String
   {
      if(!param1 || !param2)
      {
         return "NONE";
      }
      return "master " + param1["_"];
   }
   
   private function get screenshotPath() : String
   {
      var _loc1_:String = String(this.saveFilePath);
      if(SaveManager.SAVE_SCREENSHOT_PNG)
      {
         _loc1_ = _loc1_.replace(".save.json",SaveManager.SAVE_SCREENSHOT_PNG_EXT);
      }
      else
      {
         _loc1_ = _loc1_.replace(".save.json",SaveManager.SAVE_SCREENSHOT_BMPZIP_EXT);
      }
      return _loc1_;
   }
   
   public function toString() : String
   {
      return "[" + this.saveFilePath + "]";
   }
   
   public function cleanup() : void
   {
      this.cleanedup = true;
      this.callback = null;
      this.cloudSave = null;
      this.remoteSave = null;
      if(this.remoteData)
      {
         this.remoteData.clear();
         this.remoteData = null;
      }
      this.localSave = null;
      if(this.localData)
      {
         this.localData.clear();
         this.localData = null;
      }
      this.config = null;
   }
   
   public function process(param1:Function) : void
   {
      if(this.cleanedup)
      {
         this.logger.e("SAVE","SaveComparison: Attempting to process save comparison for {0} that is already cleaned up.",this.saveFilePath);
         return;
      }
      this.callback = param1;
      if(this.skipRemote)
      {
         this.logger.d("SAVE","SaveComparison: Skipping remote on save comparison of {0}.",this.saveFilePath);
         this.performComparison();
      }
      else if(!this.isWaitingOnRemote)
      {
         this.isWaitingOnRemote = true;
         this.logger.d("SAVE","SaveComparison: Reading remote saved game for {0}.",this.saveFilePath);
         this.cloudSave.readSavedGame(this.saveFilePath,this.cloudSaveReadFileHandler_sagaSave);
      }
      else
      {
         this.logger.d("SAVE","SaveComparison: still waiting on remote to finish loading {0}",this.saveFilePath);
      }
   }
   
   private function cloudSaveReadFileHandler_sagaSave(param1:CloudSave, param2:String, param3:ByteArray) : void
   {
      if(this.cleanedup)
      {
         this.logger.i("SAVE","Finished reading remote save for {0}, but already cleaned up!",param2);
         if(param3)
         {
            param3.clear();
         }
         return;
      }
      if(param3)
      {
         this.logger.d("SAVE","SaveComparison: loaded {0} bytes from remote {1}",param3.length,param2);
         param3.position = 0;
      }
      else
      {
         this.logger.i("SAVE","SaveComparison: remote claimed to have file {0} but returned null data",param2);
      }
      this.remoteData = param3;
      this.performComparison();
   }
   
   private function cloudSaveReadFileHandler_screenshot(param1:CloudSave, param2:String, param3:ByteArray) : void
   {
      var _loc4_:String = null;
      if(this.cleanedup)
      {
         this.logger.i("SAVE","GameSaveSynchronizer loaded remote screenshot but already cleaned up for {0}",param2);
         return;
      }
      if(param3 != null)
      {
         _loc4_ = String(this.saveFilePath);
         if(SaveManager.SAVE_SCREENSHOT_PNG)
         {
            _loc4_ = _loc4_.replace(".save.json",SaveManager.SAVE_SCREENSHOT_PNG_EXT);
         }
         else
         {
            _loc4_ = _loc4_.replace(".save.json",SaveManager.SAVE_SCREENSHOT_BMPZIP_EXT);
         }
         this.logger.i("SAVE","GameSaveSynchronizer writing screenshot data for {0}",param2);
         this.config.context.appInfo.saveFile(SaveManager.SAVE_DIR,_loc4_,param3,false);
      }
      else
      {
         this.logger.i("SAVE","GameSaveSynchronizer loaded remote screenshot : data is NULL for {0}",param2);
      }
      if(this.callback != null)
      {
         this.callback(this);
      }
   }
   
   private function performComparison() : void
   {
      var localHash:String = null;
      var remoteHash:String = null;
      var remoteSeed:int = 0;
      var localSeed:int = 0;
      if(this.cleanedup)
      {
         return;
      }
      this.hasLocal = this.localData != null && this.localData.length > 0;
      this.hasRemote = this.remoteData != null && this.remoteData.length > 0;
      this.conflict = false;
      if(this.saveFilePath.indexOf("master") >= 0)
      {
         this.performComparison_master();
         return;
      }
      if(Boolean(this.hasLocal) && Boolean(this.hasRemote))
      {
         localHash = MD5.hashBinary(this.localData);
         remoteHash = MD5.hashBinary(this.remoteData);
         if(localHash != remoteHash)
         {
            try
            {
               this.localSave = SagaSave.deserialize(this.localData,this.logger,false,null);
            }
            catch(e:Error)
            {
               hasLocal = false;
               logger.e("SAVE","GameSaveSynchronizer: failed to deserialize local save file " + saveFilePath);
            }
            try
            {
               this.remoteSave = SagaSave.deserialize(this.remoteData,this.logger,false,null);
            }
            catch(e:Error)
            {
               hasRemote = false;
               logger.e("SAVE","GameSaveSynchronizer: failed to deserialize remote save file " + saveFilePath);
            }
            if(Boolean(this.localSave) && Boolean(this.remoteSave))
            {
               this.logger.i("SAVE","GameSaveSynchronizer SaveComparison: Mismatch between remote and local hash for [{0}]",this.saveFilePath);
               remoteSeed = !!this.remoteSave.rng ? int(this.remoteSave.rng.seed) : 0;
               localSeed = !!this.localSave.rng ? int(this.localSave.rng.seed) : 0;
               if(remoteSeed != localSeed)
               {
                  this.logger.i("SAVE","GameSaveSynchronizer SaveComparison: mismatch campaign [{0}]",this.saveFilePath);
                  this.conflict = true;
                  this.sameCampaign = false;
               }
               else if(this.remoteSave.date > this.localSave.date)
               {
                  if(this.remoteSave.day >= this.localSave.day)
                  {
                     this.logger.i("SAVE","GameSaveSynchronizer SaveComparison: remote newer [{0}]",this.saveFilePath);
                     this.conflict = true;
                     this.sameCampaign = true;
                  }
               }
            }
         }
      }
      else if(Boolean(this.hasRemote) && !this.hasLocal)
      {
         this.logger.d("SAVE","GameSaveSynchronizer SaveComparison: no local [{0}]",this.saveFilePath);
      }
      else if(!this.hasRemote && Boolean(this.hasLocal))
      {
         this.logger.d("SAVE","GameSaveSynchronizer SaveComparison: no remote [{0}]",this.saveFilePath);
      }
      else
      {
         this.logger.d("SAVE","SaveComparison: No remote and no local for {0}?",this.saveFilePath);
      }
      if(this.callback != null)
      {
         this.callback(this);
      }
   }
   
   private function performComparison_master() : void
   {
      var localHash:String = null;
      var remoteHash:String = null;
      var localDataStr:String = null;
      var remoteDataStr:String = null;
      if(this.cleanedup)
      {
         return;
      }
      this.hasLocal = this.localData != null && this.localData.length > 0;
      this.hasRemote = this.remoteData != null && this.remoteData.length > 0;
      this.conflict = false;
      if(Boolean(this.hasLocal) && Boolean(this.hasRemote))
      {
         localHash = MD5.hashBinary(this.localData);
         remoteHash = MD5.hashBinary(this.remoteData);
         if(localHash != remoteHash)
         {
            try
            {
               localDataStr = String(this.localData.readUTFBytes(this.localData.length));
               this.localMaster = JSON.parse(localDataStr);
            }
            catch(e:Error)
            {
               hasLocal = false;
               logger.e("SAVE","GameSaveSynchronizer: failed to deserialize local master save file " + saveFilePath);
            }
            try
            {
               remoteDataStr = String(this.remoteData.readUTFBytes(this.remoteData.length));
               this.remoteMaster = JSON.parse(remoteDataStr);
            }
            catch(e:Error)
            {
               hasRemote = false;
               logger.e("SAVE","GameSaveSynchronizer: failed to deserialize remote master save file " + saveFilePath);
            }
            if(Boolean(this.localMaster) && Boolean(this.remoteMaster))
            {
               this.logger.i("SAVE","GameSaveSynchronizer SaveComparison: Mismatch between remote and local master hash for [{0}]",this.saveFilePath);
               this.conflict = true;
            }
         }
      }
      else if(Boolean(this.hasRemote) && !this.hasLocal)
      {
         this.logger.d("SAVE","GameSaveSynchronizer SaveComparison: no local master [{0}]",this.saveFilePath);
      }
      else if(!this.hasRemote && Boolean(this.hasLocal))
      {
         this.logger.d("SAVE","GameSaveSynchronizer SaveComparison: no remote  master[{0}]",this.saveFilePath);
      }
      else
      {
         this.logger.d("SAVE","SaveComparison: No remote and no local master for {0}?",this.saveFilePath);
      }
      if(this.callback != null)
      {
         this.callback(this);
      }
   }
   
   private function localScreenshotLoaded(param1:String, param2:ByteArray, param3:ByteArray) : void
   {
      if(this.cleanedup)
      {
         return;
      }
      this.logger.d("SAVE","GameSaveSynchronizer SaveComparison: Uploading local save of [{0}] to cloud.",this.saveFilePath);
      this.cloudSave.saveGame(this.saveFilePath,this.localData,param3);
      if(this.callback != null)
      {
         this.callback(this);
      }
   }
   
   public function copyRemoteToLocal(param1:Function) : void
   {
      if(this.cleanedup)
      {
         return;
      }
      this.logger.d("SAVE","GameSaveSynchronizer SaveComparison: Downloading cloud save of [{0}] to local.",this.saveFilePath);
      this.callback = param1;
      if(this.remoteData)
      {
         this.config.context.appInfo.saveFile(SaveManager.SAVE_DIR,this.saveFilePath,this.remoteData,false);
         this.remoteData.clear();
         this.remoteData = null;
         if(!SaveManager.SAVE_SCREENSHOT_PREGENERATED)
         {
            this.logger.d("SAVE","GameSaveSynchronizer SaveComparison: loading remote screenshot for {0}",this.saveFilePath);
            this.cloudSave.readScreenshot(this.saveFilePath,this.cloudSaveReadFileHandler_screenshot);
         }
      }
      else
      {
         this.logger.i("SAVE","GameSaveSynchronizer SaveComparison:  Copy remote save to local for {0}: NO REMOTE DATA?",this.saveFilePath);
      }
   }
   
   public function copyLocalToRemote(param1:Function) : void
   {
      if(this.cleanedup)
      {
         return;
      }
      this.logger.d("SAVE","GameSaveSynchronizer SaveComparison:  Copy local save to remote for {0}",this.saveFilePath);
      if(!this.localData)
      {
         this.logger.e("SAVE","GameSaveSynchronizer SaveComparison: Copy NO LOCAL " + this.saveFilePath);
         return;
      }
      this.callback = param1;
      this.config.context.appInfo.loadFileAsync(SaveManager.SAVE_DIR,this.screenshotPath,this.localData,this.localScreenshotLoaded);
   }
   
   public function getUserMessage() : String
   {
      var _loc1_:String = null;
      var _loc2_:* = null;
      var _loc3_:* = null;
      if(this.cleanedup)
      {
         return "cleanedup";
      }
      if(this.sameCampaign)
      {
         _loc1_ = String(this.config.context.locale.translateGui("cloudsave_conflict_newer"));
      }
      else
      {
         _loc1_ = String(this.config.context.locale.translateGui("cloudsave_conflict_mismatch"));
      }
      _loc1_ = _loc1_.replace("$REMOTE_FOLDER",this.cloudSave.id);
      _loc1_ = _loc1_.replace("$PROFILE_INDEX",this.profile_index.toString());
      if(Boolean(this.remoteMaster) || Boolean(this.localMaster))
      {
         _loc2_ = "[" + createMasterDisplay(this.remoteMaster,this.config.gameGuiContext) + "]";
         _loc3_ = "[" + createMasterDisplay(this.localMaster,this.config.gameGuiContext) + "]";
      }
      else
      {
         _loc2_ = "[" + createSaveDisplay(this.remoteSave,this.config.gameGuiContext) + "]";
         _loc3_ = "[" + createSaveDisplay(this.localSave,this.config.gameGuiContext) + "]";
      }
      _loc1_ = _loc1_.replace("$REMOTE_ID",_loc2_);
      return _loc1_.replace("$LOCAL_ID",_loc3_);
   }
}
