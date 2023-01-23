package engine.resource
{
   import com.greensock.TweenMax;
   import engine.anim.def.AnimClipDef;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.StringUtil;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getTimer;
   
   public class GenerateConsoleCacheSizes extends EventDispatcher
   {
      
      public static var ENABLED:Boolean = false;
      
      private static var NUM_TIMES_TO_LOAD_EACH_RESOURCE:int = 1;
       
      
      private var _resourceManager:ResourceManager;
      
      private var _logger:ILogger;
      
      private var _resource:Resource;
      
      private var _curIdx:int;
      
      private var _numTimes:int;
      
      private var _monitor:ResourceMonitor;
      
      private var _monitorBegTime:int;
      
      private var _mutexesBefore:int;
      
      private var _mutexBaseline:int;
      
      private var _results:Array;
      
      private var _assetUrlList:Vector.<String>;
      
      public function GenerateConsoleCacheSizes(param1:IResourceManager, param2:ILogger)
      {
         this._results = [];
         this._assetUrlList = new Vector.<String>(0);
         super();
         this._resourceManager = param1 as ResourceManager;
         this._logger = param2;
      }
      
      public function load() : void
      {
         this._logger.info("GenerateConsoleCacheSizes ****** WAITING for all other resources to be done loading ******");
         this._monitor = new ResourceMonitor("GenerateConsoleCacheSizes",this._logger,this.resourceMonitorChangedHandler);
         this._resourceManager.addMonitor(this._monitor);
         this._monitorBegTime = getTimer();
      }
      
      private function resourceMonitorChangedHandler(param1:ResourceMonitor) : void
      {
         this._logger.info("GenerateConsoleCacheSizes waiting report: " + this._monitor.waitingReport);
         if(this._monitor.empty)
         {
            TweenMax.delayedCall(2,this.checkAgainForAnyResources);
         }
         else
         {
            TweenMax.killDelayedCallsTo(this.checkAgainForAnyResources);
         }
      }
      
      private function checkAgainForAnyResources() : void
      {
         if(this._monitor.empty)
         {
            this._resourceManager.removeMonitor(this._monitor);
            this._monitor = null;
            this.loadBegin();
         }
      }
      
      private function loadBegin() : void
      {
         this._results = [];
         this._curIdx = -1;
         this._mutexBaseline = AppInfo.instance.getNumPs4Mutexes();
         this._logger.info("GenerateConsoleCacheSizes ****** BEGIN ****** (mutex baseline: {0})",this._mutexBaseline);
         this.loadNext();
      }
      
      private function loadNext() : void
      {
         ++this._numTimes;
         if(this._curIdx < 0 || this._numTimes > NUM_TIMES_TO_LOAD_EACH_RESOURCE)
         {
            ++this._curIdx;
            this._numTimes = 1;
         }
         if(this._curIdx >= this._assetUrlList.length)
         {
            this._logger.info("GenerateConsoleCacheSizes ****** END ******");
            this.printResults();
            dispatchEvent(new Event(Event.COMPLETE));
            return;
         }
         var _loc1_:String = this._assetUrlList[this._curIdx];
         var _loc2_:Class = StringUtil.endsWith(_loc1_,".png") ? BitmapResource : AnimClipBagResource;
         this._mutexesBefore = AppInfo.instance.getNumPs4Mutexes();
         this._resource = this._resourceManager.getResource(_loc1_,_loc2_) as Resource;
         this._resource.addEventListener(Event.COMPLETE,this.onLoadComplete);
         if(this._resource.did_load)
         {
            if(this._resource is AnimClipBagResource)
            {
               this._logger.error("GenerateConsoleCacheSizes: anim was already loaded, so we couldn\'t get its mutex cost: {0}",this._resource);
            }
            this.onLoadComplete(new Event(Event.COMPLETE));
         }
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         var _loc2_:int = this.calcNumBytes(this._resource);
         var _loc3_:Number = AppInfo.instance.getNumPs4Mutexes();
         var _loc4_:Number = _loc3_ - this._mutexesBefore;
         if(this._resource is BitmapResource && _loc4_ != 0)
         {
            this._logger.error("GenerateConsoleCacheSizes: we expect all pngs to use no mutexes, but this one used {0} mutexes: {1}",_loc4_,this._resource);
         }
         if(this._numTimes == 1)
         {
            if(this._resource is BitmapResource && _loc2_ < ConsoleResourceCache.PNG_EST_NUM_BYTES)
            {
               this._logger.info("GenerateConsoleCacheSizes: not recording png because it\'s small. {0} ({1})",this._resource,_loc2_);
            }
            else
            {
               this._results.push({
                  "url":this._resource.url,
                  "size":_loc2_,
                  "mutexes":_loc4_
               });
            }
         }
         this._logger.info("GenerateConsoleCacheSizes: onLoadComplete {0}/{1} {2} {3} mutex diff: {4}",this._curIdx + 1,this._assetUrlList.length,this._numTimes,this._resource,_loc4_);
         this._resource.removeEventListener(Event.COMPLETE,this.onLoadComplete);
         this._resource.release();
         this.waitUntilResourceDestroyed();
      }
      
      private function waitUntilResourceDestroyed() : void
      {
         TweenMax.killDelayedCallsTo(this.waitUntilResourceDestroyed);
         var _loc1_:Number = AppInfo.instance.getNumPs4Mutexes();
         if(_loc1_ <= this._mutexBaseline)
         {
            this.loadNext();
         }
         else
         {
            this._logger.info("GenerateConsoleCacheSizes: waiting for resource to be destroyed... mutexes: {0} refcount: {1}",_loc1_,this._resource.refcount.refcount);
            TweenMax.delayedCall(0.5,this.waitUntilResourceDestroyed);
         }
      }
      
      private function calcNumBytes(param1:Resource) : int
      {
         var _loc2_:Number = NaN;
         var _loc3_:AnimClipBagResource = null;
         var _loc4_:Number = NaN;
         var _loc5_:AnimClipDef = null;
         var _loc6_:Number = NaN;
         if(param1 is BitmapResource)
         {
            return param1.numBytes;
         }
         if(param1 is AnimClipBagResource)
         {
            _loc2_ = 0;
            _loc3_ = param1 as AnimClipBagResource;
            if(Boolean(_loc3_) && Boolean(_loc3_.bag))
            {
               _loc4_ = 0;
               for each(_loc5_ in _loc3_.bag.clips)
               {
                  _loc6_ = _loc5_.numBytes;
                  _loc4_ += _loc6_;
               }
               _loc2_ += _loc4_;
            }
            else
            {
               this._logger.error("GenerateConsoleCacheSizes.calcNumBytes: anim bag not found");
            }
            return _loc2_;
         }
         this._logger.error("GenerateConsoleCacheSizes.calcNumBytes: unknown resource type: " + param1);
         return 1;
      }
      
      private function printResults() : void
      {
         var _loc1_:Object = null;
         this._results.sortOn("url");
         for each(_loc1_ in this._results)
         {
            this._logger.info("\t\t{");
            this._logger.info("\t\t\t\"url\": \"{0}\",",_loc1_.url);
            this._logger.info("\t\t\t\"numBytes\": {0},",_loc1_.size);
            this._logger.info("\t\t\t\"numMutexes\": {0}",_loc1_.mutexes);
            this._logger.info("\t\t},");
         }
      }
      
      public function cleanup() : void
      {
         this._logger = null;
         this._resourceManager = null;
         this._results.length = 0;
         this._assetUrlList.length = 0;
      }
   }
}
