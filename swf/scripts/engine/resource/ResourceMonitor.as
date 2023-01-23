package engine.resource
{
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class ResourceMonitor
   {
       
      
      private var resources:Dictionary;
      
      private var callback:Function;
      
      private var remaining:int;
      
      private var total:int;
      
      private var logger:ILogger;
      
      private var callbackTimer:Timer;
      
      public var resmans:Vector.<ResourceManager>;
      
      public var name:String;
      
      public function ResourceMonitor(param1:String, param2:ILogger, param3:Function)
      {
         this.resources = new Dictionary();
         this.callbackTimer = new Timer(1,1);
         this.resmans = new Vector.<ResourceManager>();
         super();
         this.name = param1;
         if(param3 == null)
         {
            throw new ArgumentError("dangit");
         }
         this.callback = param3;
         this.logger = param2;
         this.callbackTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
      }
      
      public function cleanup() : void
      {
         var _loc2_:ResourceManager = null;
         var _loc3_:Resource = null;
         var _loc1_:Vector.<ResourceManager> = this.resmans;
         this.resmans = null;
         for each(_loc2_ in _loc1_)
         {
            _loc2_.removeMonitor(this);
         }
         this.resmans = null;
         for each(_loc3_ in this.resources)
         {
            this.unlistenToResource(_loc3_);
         }
         this.resources = null;
         if(this.callbackTimer)
         {
            this.callbackTimer.stop();
            this.callbackTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
            this.callbackTimer = null;
            this.callback = null;
         }
      }
      
      public function removeResourceManager(param1:ResourceManager) : void
      {
         if(!this.resmans)
         {
            return;
         }
         var _loc2_:int = this.resmans.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.resmans.splice(_loc2_,1);
         }
      }
      
      public function addResourceManager(param1:ResourceManager) : void
      {
         if(!this.resmans)
         {
            return;
         }
         this.resmans.push(param1);
      }
      
      private function listenToResource(param1:Resource) : void
      {
         param1.addEventListener(Event.COMPLETE,this.resourceCompleteHandler);
         param1.addEventListener(Event.UNLOAD,this.resourceUnloadHandler);
      }
      
      private function unlistenToResource(param1:Resource) : void
      {
         param1.removeEventListener(Event.COMPLETE,this.resourceCompleteHandler);
         param1.removeEventListener(Event.UNLOAD,this.resourceUnloadHandler);
      }
      
      public function forceTimer() : void
      {
         if(this.callbackTimer.running)
         {
            this.callbackTimer.stop();
            this.timerCompleteHandler(null);
         }
      }
      
      protected function timerCompleteHandler(param1:TimerEvent) : void
      {
         if(this.callback != null)
         {
            this.callback(this);
         }
      }
      
      public function getRemainingResources(param1:Vector.<Resource>) : void
      {
         var _loc2_:Resource = null;
         for each(_loc2_ in this.resources)
         {
            param1.push(_loc2_);
         }
      }
      
      public function abort() : void
      {
         var _loc1_:Function = this.callback;
         this.cleanup();
         this.remaining = 0;
         this.total = 0;
         if(_loc1_ != null)
         {
            _loc1_(this);
         }
      }
      
      public function addResource(param1:Resource) : void
      {
         if(this.callback == null)
         {
            throw new IllegalOperationError("ResourceMonitor hanging around with no callback");
         }
         if(!param1.did_load)
         {
            if(this.resources[param1])
            {
               return;
            }
            this.resources[param1] = param1;
            this.listenToResource(param1);
            ++this.total;
            ++this.remaining;
            this.checkMonitorReady(param1);
         }
      }
      
      public function removeResource(param1:Resource) : void
      {
         if(this.callback == null)
         {
            throw new IllegalOperationError("ResourceMonitor hanging around with no callback");
         }
         this.unlistenToResource(param1);
         if(this.resources[param1])
         {
            delete this.resources[param1];
            --this.total;
            --this.remaining;
            this.checkMonitorReady(param1);
         }
      }
      
      protected function resourceUnloadHandler(param1:Event) : void
      {
         var _loc2_:Resource = param1.target as Resource;
         this.removeResource(_loc2_);
      }
      
      private function checkMonitorReady(param1:Resource) : void
      {
         this.finishIfEmpty();
      }
      
      public function finishIfEmpty() : void
      {
         if(this.callbackTimer.running)
         {
            this.callbackTimer.stop();
            this.callbackTimer.reset();
         }
         if(this.empty)
         {
            this.callbackTimer.reset();
            this.callbackTimer.start();
            return;
         }
         this.callback(this);
      }
      
      protected function resourceCompleteHandler(param1:Event) : void
      {
         if(this.callback == null)
         {
            throw new IllegalOperationError("ResourceMonitor hanging around with no callback");
         }
         var _loc2_:Resource = param1.target as Resource;
         if(_loc2_.url.indexOf(".anim.json.z") >= 0)
         {
            _loc2_ = _loc2_;
         }
         this.unlistenToResource(_loc2_);
         if(this.resources[_loc2_])
         {
            --this.remaining;
            delete this.resources[_loc2_];
            this.checkMonitorReady(_loc2_);
         }
      }
      
      public function get empty() : Boolean
      {
         return this.remaining == 0;
      }
      
      public function get percent() : Number
      {
         if(this.total)
         {
            return (this.total - this.remaining) / this.total;
         }
         return 0;
      }
      
      public function get percentInt() : int
      {
         return 100 * this.percent;
      }
      
      public function get waitingReport() : String
      {
         var _loc2_:Resource = null;
         var _loc1_:String = "";
         for each(_loc2_ in this.resources)
         {
            _loc1_ += _loc2_.url + "\n";
         }
         return _loc1_;
      }
   }
}
