package engine.core.http
{
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class HttpAction
   {
      
      private static const ALLOW_OFFLINE_MOCK:Boolean = true;
       
      
      protected var m_url:String;
      
      private var m_callback:Function;
      
      private var _overrideCallback:Function;
      
      private var m_sent:Boolean;
      
      private var m_response:String;
      
      private var m_received:Boolean;
      
      private var m_sendTime:int;
      
      private var m_responseLatency:int;
      
      public var logger:ILogger;
      
      public var success:Boolean;
      
      public var responseCode:int;
      
      public var method:HttpRequestMethod;
      
      public var body:Object;
      
      private var aborted:Boolean;
      
      private var _communicator:HttpCommunicator;
      
      private var _timer:Timer;
      
      public var delay:int;
      
      public var txnName:String;
      
      public var delayStartTime:int;
      
      protected var resendOnFail:Boolean;
      
      protected var resendOnFailDelayMs:int = 2000;
      
      protected var consumedTxn:Boolean;
      
      private var _offlineResponse:String;
      
      private var _offlineResponseStatus:int;
      
      public var offlineTimer:Timer;
      
      public function HttpAction(param1:String, param2:HttpRequestMethod, param3:Object, param4:Function, param5:ILogger)
      {
         super();
         this.m_url = param1;
         this.m_callback = param4;
         this.logger = param5;
         this.method = param2;
         this.body = param3;
         this.txnName = getQualifiedClassName(this);
         this.txnName = this.txnName.substr(this.txnName.lastIndexOf(":") + 1,this.txnName.length);
      }
      
      public function resend(param1:HttpCommunicator, param2:int) : void
      {
         this.m_sent = false;
         this.success = false;
         this.responseCode = 0;
         this.aborted = false;
         this.m_response = null;
         this.m_received = false;
         this.m_responseLatency = 0;
         if(this._timer)
         {
            this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
            this._timer.stop();
            this._timer = null;
         }
         this.send(param1,this._overrideCallback,param2);
      }
      
      public function send(param1:HttpCommunicator, param2:Function = null, param3:int = 0) : void
      {
         if(this.m_sent)
         {
            throw new IllegalOperationError("Return to sender");
         }
         if(param2 != null)
         {
            this._overrideCallback = param2;
         }
         this._communicator = param1;
         this.delay = param3;
         if(param3 > 0)
         {
            this.delayStartTime = getTimer();
            this._timer = new Timer(param3,1);
            this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
            this._timer.start();
            return;
         }
         this.doSend();
      }
      
      public function get delayRemainingTime() : int
      {
         var _loc1_:int = 0;
         if(this.delay > 0)
         {
            _loc1_ = getTimer() - this.delayStartTime;
            return this.delay - _loc1_;
         }
         return 0;
      }
      
      private function doSend() : void
      {
         var _loc1_:HttpRequest = null;
         var _loc2_:Array = null;
         this.m_sendTime = getTimer();
         this.m_sent = true;
         if(this._communicator)
         {
            _loc1_ = this._communicator.request(this.url,this.method,this.body,this.onResponseReceived);
         }
         else if(ALLOW_OFFLINE_MOCK)
         {
            _loc2_ = this.url.split("/");
            this.offlineProcessRequest(_loc2_);
         }
         else
         {
            this.success = false;
            this.logger.error("No communicator -- can\'t send " + this);
            this.issueCallback();
         }
      }
      
      public function forceTimerTimeout() : void
      {
         this.timerCompleteHandler(null);
      }
      
      private function timerCompleteHandler(param1:TimerEvent) : void
      {
         if(this._timer)
         {
            this._timer = null;
            this.doSend();
         }
      }
      
      public function abort() : void
      {
         this.resendOnFail = false;
         this.aborted = true;
         this.m_callback = null;
         if(this._timer)
         {
            this._timer.stop();
            this._timer = null;
         }
      }
      
      protected function handleAbort() : void
      {
      }
      
      public function get url() : String
      {
         return this.m_url;
      }
      
      public function get response() : String
      {
         if(!this.m_received)
         {
            throw new IllegalOperationError("No response yet");
         }
         return this.m_response;
      }
      
      public function get latency() : int
      {
         if(!this.m_received)
         {
            return getTimer() - this.m_sendTime;
         }
         return this.m_responseLatency;
      }
      
      public function get received() : Boolean
      {
         return this.m_received;
      }
      
      public function get sent() : Boolean
      {
         return this.m_sent;
      }
      
      public function get shouldProcessResponse() : Boolean
      {
         return this.responseCode != 404;
      }
      
      public function get debugResponseString() : String
      {
         return !!this.m_response ? this.m_response.substring(0,500).split("\n").join("") : null;
      }
      
      protected function onResponseReceived(param1:String, param2:Boolean, param3:int) : void
      {
         var _loc4_:String = null;
         if(this.aborted)
         {
            this.logger.debug("Ignoring aborted response for " + this + " " + param3 + ": " + param1);
            return;
         }
         this.m_response = param1;
         if(!param2)
         {
            _loc4_ = this.txnName + " onResponseReceived ERROR url=" + this.url + " ok=" + param2 + " status=" + param3 + " response=" + this.debugResponseString;
            this.logger.info(_loc4_);
         }
         if(this.m_received)
         {
            throw new IllegalOperationError("Redundant response");
         }
         this.m_responseLatency = getTimer() - this.m_sendTime;
         this.m_response = param1;
         this.m_received = true;
         this.success = param2;
         this.responseCode = param3;
         if(this.shouldProcessResponse)
         {
            this.handleResponseProcessing();
         }
         if(Boolean(this.communicator) && (!this.consumedTxn || this.isMaintenance))
         {
            this.communicator.onHttpTxnResponseProcessed(this);
         }
         if(null != this._overrideCallback)
         {
            this._overrideCallback(this);
         }
         else
         {
            this.issueCallback();
         }
         if(this.received && !this.success)
         {
            if(this.resendOnFail)
            {
               if(this.canRetry)
               {
                  this.logger.error("Failed to " + this + " with code " + this.responseCode + ", retrying");
                  this.resend(this.communicator,this.resendOnFailDelayMs);
               }
               else
               {
                  this.logger.error("Failed to " + this + " with code " + this.responseCode + ", WILL NOT RETRY");
               }
            }
         }
      }
      
      public function issueCallback() : void
      {
         if(!this.m_received)
         {
            throw new IllegalOperationError("Cannot issue a callback prior to a response!");
         }
         if(null != this.m_callback)
         {
            this.m_callback(this);
         }
      }
      
      protected function handleResponseProcessing() : void
      {
      }
      
      protected function offlineProcessRequest(param1:Array) : void
      {
         this.setOfflineResponse(null,404);
      }
      
      public function setOfflineResponse(param1:Object, param2:int) : void
      {
         var _loc3_:String = null;
         if(param1 is String)
         {
            _loc3_ = param1 as String;
         }
         else if(param1)
         {
            _loc3_ = JSON.stringify(param1);
         }
         this._offlineResponse = _loc3_;
         this._offlineResponseStatus = param2;
         this.offlineTimer = new Timer(100,1);
         this.offlineTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.offlineTimerHandler);
         this.offlineTimer.start();
      }
      
      protected function offlineTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:Boolean = this._offlineResponseStatus >= 200 && this._offlineResponseStatus < 300;
         this.onResponseReceived(this._offlineResponse,_loc2_,this._offlineResponseStatus);
         this.offlineTimer = null;
      }
      
      public function get offlineResponse() : String
      {
         return this._offlineResponse;
      }
      
      public function get overrideCallback() : Function
      {
         return this._overrideCallback;
      }
      
      public function set overrideCallback(param1:Function) : void
      {
         this._overrideCallback = param1;
      }
      
      public function get communicator() : HttpCommunicator
      {
         return this._communicator;
      }
      
      public function set communicator(param1:HttpCommunicator) : void
      {
         this._communicator = param1;
      }
      
      public function get canRetry() : Boolean
      {
         if(this.received && !this.success && !this.isMaintenance)
         {
            return this.responseCode == 0 || this.responseCode == 404 || this.responseCode >= 500;
         }
         return false;
      }
      
      public function get isMaintenance() : Boolean
      {
         if(this.responseCode == 503)
         {
            return this.response.indexOf("Offline for Maintenance") >= 0 || this.response.indexOf("game_rebooting") >= 0;
         }
         return false;
      }
   }
}
