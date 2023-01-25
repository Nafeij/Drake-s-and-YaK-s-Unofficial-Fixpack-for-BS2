package lib.engine.sound.fmod
{
   import engine.core.logging.ILogger;
   import engine.resource.Resource;
   import engine.resource.ResourceManager;
   import engine.resource.URLBinaryResource;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.ISoundEventId;
   import engine.sound.def.ISoundDef;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class FmodSoundDefBundle implements ISoundDefBundle
   {
      
      public static var allBundles:Vector.<ISoundDefBundle> = new Vector.<ISoundDefBundle>();
      
      public static var bundlesFinishing:Vector.<ISoundDefBundle> = new Vector.<ISoundDefBundle>();
      
      private static var _lastNonce:int;
      
      private static var FORCE_FINISH_MS:int = 6 * 1000;
       
      
      private var _id:String;
      
      private var _defs:Vector.<ISoundDef>;
      
      protected var soundDriver:IFmodSoundDriver;
      
      private var _complete:Boolean;
      
      private var listeners:Vector.<ISoundDefBundleListener>;
      
      private var logger:ILogger;
      
      private var numBanksWaiting:int;
      
      private var loading:Boolean;
      
      private var errors:int;
      
      protected var resman:ResourceManager;
      
      protected var resources:Vector.<URLBinaryResource>;
      
      protected var banks:Dictionary;
      
      private var _bankNames:Vector.<String>;
      
      private var _nonce:int;
      
      private var _waitingSounds:Vector.<ISoundEventId>;
      
      private var _startWaitingSoundsFinishedTime:int;
      
      public function FmodSoundDefBundle(param1:String, param2:IFmodSoundDriver, param3:ILogger, param4:ResourceManager, param5:Vector.<ISoundDef>)
      {
         var _loc6_:ISoundDef = null;
         var _loc7_:String = null;
         this._defs = new Vector.<ISoundDef>();
         this.listeners = new Vector.<ISoundDefBundleListener>();
         this.resources = new Vector.<URLBinaryResource>();
         this.banks = new Dictionary();
         this._bankNames = new Vector.<String>();
         super();
         this._nonce = ++_lastNonce;
         this._id = param1;
         this._defs = param5.concat();
         this.soundDriver = param2;
         this.logger = param3;
         this.resman = param4;
         for each(_loc6_ in this._defs)
         {
            if(!_loc6_.sku)
            {
               _loc7_ = String(param2.inferSkuFromEventPath(_loc6_.eventName));
               _loc6_.updateSku(_loc7_);
            }
         }
      }
      
      public static function getFsbPath(param1:String, param2:String, param3:String) : String
      {
         return param1 + "/fmod/" + param2 + param3;
      }
      
      private static function addBank(param1:Vector.<String>, param2:String) : void
      {
         if(param1.indexOf(param2) >= 0)
         {
            return;
         }
         param1.push(param2);
      }
      
      public static function checkBundlesFinishing(param1:ILogger) : void
      {
         var _loc4_:ISoundDefBundle = null;
         if(!bundlesFinishing.length)
         {
            return;
         }
         param1.debug("FmodSoundDefBundle.checkBundlesFinishing n=" + bundlesFinishing.length);
         var _loc2_:int = int(bundlesFinishing.length);
         var _loc3_:int = _loc2_ - 1;
         while(_loc3_ >= 0)
         {
            _loc4_ = bundlesFinishing[_loc3_];
            if(_loc4_.checkSoundsFinished())
            {
               param1.debug("FmodSoundDefBundle.checkBundlesFinishing done " + _loc4_);
               _loc2_--;
               bundlesFinishing[_loc3_] = bundlesFinishing[_loc2_];
            }
            _loc3_--;
         }
         if(_loc2_ < bundlesFinishing.length)
         {
            bundlesFinishing.splice(_loc2_,bundlesFinishing.length - _loc2_);
            param1.info("FmodSoundDefBundle.checkBundlesFinishing waiting for " + _loc2_ + " more bundles to finish");
         }
      }
      
      public function toString() : String
      {
         var _loc1_:int = !!this.listeners ? int(this.listeners.length) : 0;
         return "Fsdb[ " + this._nonce + " [" + this._id + "] ls=" + _loc1_ + " wait=" + this.numBanksWaiting + "]";
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function debugPrint(param1:ILogger) : void
      {
         var _loc2_:ISoundDef = null;
         var _loc3_:String = null;
         param1.i("FMOD","__BUNDLE__: " + this._id);
         param1.i("FMOD","     Defs:");
         for each(_loc2_ in this._defs)
         {
            param1.i("FMOD","           " + _loc2_.eventName);
         }
         param1.i("FMOD","    Banks:");
         for each(_loc3_ in this._bankNames)
         {
            param1.i("FMOD","           " + _loc3_);
         }
      }
      
      public function get defs() : Vector.<ISoundDef>
      {
         return this._defs;
      }
      
      public function get bankNames() : Vector.<String>
      {
         return this._bankNames;
      }
      
      private function load() : void
      {
         if(this.loading)
         {
            throw new IllegalOperationError("already loading");
         }
         if(this.complete)
         {
            throw new IllegalOperationError("already complete");
         }
         this.loading = true;
         allBundles.push(this);
         this.startLoadingFsbs();
      }
      
      private function startLoadingFsbs() : void
      {
         var _loc1_:ISoundDef = null;
         var _loc2_:Array = null;
         var _loc3_:* = null;
         var _loc4_:String = null;
         for each(_loc1_ in this._defs)
         {
            if(_loc1_.eventName)
            {
               _loc2_ = this.soundDriver.getWaveBankInfo(_loc1_.eventName);
               if(_loc2_)
               {
                  _loc3_ = "";
                  for each(_loc4_ in _loc2_)
                  {
                     if(this.logger.isDebugEnabled)
                     {
                        if(_loc2_.length > 1)
                        {
                           if(_loc3_)
                           {
                              _loc3_ += ",";
                           }
                           _loc3_ += _loc4_;
                        }
                     }
                     if(!this.banks[_loc4_])
                     {
                        this._bankNames.push(_loc4_);
                        ++this.numBanksWaiting;
                        this.banks[_loc4_] = _loc1_;
                     }
                  }
                  if(_loc3_)
                  {
                     if(this.logger.isDebugEnabled)
                     {
                        this.logger.d("FMOD","FmodSoundDefBundle multi-bank event [" + _loc1_.eventName + "] " + _loc2_.length + " banks [" + _loc3_ + "]");
                     }
                  }
               }
            }
         }
         this.loadBanks();
      }
      
      protected function loadBanks() : void
      {
         var _loc1_:Resource = null;
         for each(_loc1_ in this.resources)
         {
            if(_loc1_.ok || _loc1_.error)
            {
               --this.numBanksWaiting;
            }
            else
            {
               _loc1_.addResourceListener(this.resourceLoadedHandler);
            }
         }
         this.checkBundleFinished();
      }
      
      private function resourceLoadedHandler(param1:ResourceLoadedEvent) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("FmodSoundDefBundle.fsbLoadedHandler " + param1.resource.loader.url + " for " + this);
         }
         param1.resource.removeResourceListener(this.resourceLoadedHandler);
         if(!param1.resource.ok)
         {
            this.logger.error("FmodSoundDefBundle.fsbLoadedHandler something is wrong with " + param1.resource.url);
            ++this.errors;
         }
         --this.numBanksWaiting;
         this.checkBundleFinished();
      }
      
      private function checkBundleFinished() : void
      {
         if(this.numBanksWaiting == 0)
         {
            if(!this._complete)
            {
               this._complete = true;
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("FmodSoundDefBundle.checkBundleFinished COMPLETE for " + this);
               }
               this.notifyListeners();
            }
         }
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
      
      public function get ok() : Boolean
      {
         return this.complete && this.errors == 0;
      }
      
      private function notifyListeners() : void
      {
         var _loc2_:ISoundDefBundleListener = null;
         var _loc1_:Number = 0;
         while(_loc1_ < this.listeners.length)
         {
            _loc2_ = this.listeners[_loc1_];
            _loc2_.soundDefBundleComplete(this);
            _loc1_++;
         }
      }
      
      public function addListener(param1:ISoundDefBundleListener) : void
      {
         this.listeners.push(param1);
         if(this.listeners.length == 1)
         {
            this.load();
         }
      }
      
      public function removeListener(param1:ISoundDefBundleListener) : void
      {
         var _loc2_:int = this.listeners.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.listeners.splice(_loc2_,1);
         }
         var _loc3_:int = !!this.listeners ? int(this.listeners.length) : 0;
         var _loc4_:Boolean = this.soundDriver.isDebug && this.logger.isDebugEnabled;
         if(_loc4_)
         {
            this.logger.debug("FmodSoundDefBundle.removeListener " + this._id + " n=" + _loc3_ + " l=" + param1);
         }
         if(_loc3_ == 0)
         {
            if(this.isWaitingSounds)
            {
               if(_loc4_)
               {
                  this.logger.debug("FmodSoundDefBundle.removeListener " + this._id + " push finish");
               }
               bundlesFinishing.push(this);
            }
            else
            {
               if(_loc4_)
               {
                  this.logger.debug("FmodSoundDefBundle.removeListener " + this._id + " release now");
               }
               this.releaseResources();
            }
         }
      }
      
      private function releaseResources() : void
      {
         var _loc1_:Resource = null;
         var _loc3_:int = 0;
         var _loc2_:Boolean = this.soundDriver.isDebug;
         if(_loc2_ && this.logger.isDebugEnabled)
         {
            this.logger.debug("FmodSoundDefBundle.releaseResources " + this._id + ":");
         }
         for each(_loc1_ in this.resources)
         {
            if(_loc2_ && this.logger.isDebugEnabled)
            {
               this.logger.debug("                                             -> " + _loc1_ + " (refs=" + _loc1_.refcount.refcount + ")");
            }
            _loc1_.removeResourceListener(this.resourceLoadedHandler);
            _loc1_.release();
         }
         this.resources.splice(0,this.resources.length);
         _loc3_ = allBundles.indexOf(this);
         if(_loc3_ >= 0)
         {
            allBundles.splice(_loc3_,1);
         }
         this.loading = false;
         this._complete = false;
         this.numBanksWaiting = 0;
         this.errors = 0;
      }
      
      public function get isWaitingSounds() : Boolean
      {
         return Boolean(this._waitingSounds) && Boolean(this._waitingSounds.length);
      }
      
      public function waitForSoundToFinish(param1:ISoundEventId) : void
      {
         if(!this._waitingSounds)
         {
            this._waitingSounds = new Vector.<ISoundEventId>();
            this._startWaitingSoundsFinishedTime = getTimer();
         }
         this.logger.info("FmodSoundDefBundle.waitForSoundToFinish " + param1);
         this._waitingSounds.push(param1);
      }
      
      public function checkSoundsFinished() : Boolean
      {
         var _loc5_:ISoundEventId = null;
         if(!this._waitingSounds || this._waitingSounds.length == 0)
         {
            return true;
         }
         var _loc1_:int = getTimer() - this._startWaitingSoundsFinishedTime;
         var _loc2_:* = _loc1_ >= FORCE_FINISH_MS;
         var _loc3_:int = int(this._waitingSounds.length);
         var _loc4_:int = _loc3_ - 1;
         for(; _loc4_ >= 0; _loc4_--)
         {
            _loc5_ = this._waitingSounds[_loc4_];
            if(this.soundDriver.isPlaying(_loc5_))
            {
               if(!_loc2_)
               {
                  this.logger.debug("FmodSoundDefBundle.checkSoundsFinished " + this.id + " still playing " + _loc5_);
                  continue;
               }
               this.logger.debug("FmodSoundDefBundle.checkSoundsFinished " + this.id + " FORCE FINISHING " + _loc5_);
               this.soundDriver.stopEvent(_loc5_,true);
            }
            this.logger.debug("FmodSoundDefBundle.checkSoundsFinished " + this.id + " " + _loc5_);
            _loc3_--;
            this._waitingSounds[_loc4_] = this._waitingSounds[_loc3_];
         }
         if(_loc3_ < this._waitingSounds.length)
         {
            if(_loc3_ == 0)
            {
               this.logger.debug("FmodSoundDefBundle.checkSoundsFinished " + this.id + " ALL DONE");
               this._waitingSounds = null;
               return true;
            }
            this._waitingSounds.splice(_loc3_,this._waitingSounds.length - _loc3_);
            this.logger.debug("FmodSoundDefBundle.checkSoundsFinished " + this.id + " waiting for " + _loc3_ + " more sounds to finish");
         }
         return false;
      }
   }
}
